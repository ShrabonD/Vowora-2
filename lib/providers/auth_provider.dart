import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/storage_service.dart';
import '../core/services/supabase_service.dart';
import '../models/user_profile.dart';

enum AuthStatus {
  uninitialized,
  unauthenticated,
  mfaPending,
  authenticated,
  guest,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;
  String? _savedEmail;
  StreamSubscription<AuthState>? _authSubscription;

  // TOTP MFA Verification Session State
  bool _needsMfaVerification = false;
  String? _mfaFactorId;
  bool _isEnrollingMfa = false;

  AuthStatus get status => _status;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  String? get savedEmail => _savedEmail;
  bool get isGuest => _status == AuthStatus.guest;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isMfaPending => _status == AuthStatus.mfaPending || _needsMfaVerification;
  bool get isUnauthenticated => _status == AuthStatus.unauthenticated;
  bool get needsMfaVerification => _status == AuthStatus.mfaPending || _needsMfaVerification;
  String? get mfaFactorId => _mfaFactorId;
  bool get isEnrollingMfa => _isEnrollingMfa;

  bool get isOAuthUser {
    if (!SupabaseService.isInitialized || SupabaseService.currentUser == null) return false;
    final provider = SupabaseService.currentUser!.appMetadata['provider'];
    return provider != null && provider != 'email';
  }

  AuthProvider() {
    _init();
    _listenToAuthChanges();
  }

  void startMfaEnrollmentMode() {
    _isEnrollingMfa = true;
    _needsMfaVerification = false;
    if (_userProfile != null) {
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  void completeMfaEnrollmentMode() {
    _isEnrollingMfa = false;
    _needsMfaVerification = false;
    if (_userProfile != null) {
      _status = AuthStatus.authenticated;
    }
    _refreshProfileInBackground();
    notifyListeners();
  }

  void cancelMfaEnrollmentMode() {
    _isEnrollingMfa = false;
    _needsMfaVerification = false;
    if (_userProfile != null) {
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  void _listenToAuthChanges() {
    if (!SupabaseService.isInitialized) return;
    _authSubscription =
        SupabaseService.client.auth.onAuthStateChange.listen((data) async {
          final session = data.session;
          final event = data.event;
          
          if (kDebugMode) {
            print('🔐 AuthStateChange Event: $event | Session active: ${session != null} | Status before: $_status');
          }

          if (event == AuthChangeEvent.signedOut || session == null || SupabaseService.currentSession == null) {
            _userProfile = null;
            _needsMfaVerification = false;
            _isEnrollingMfa = false;
            _mfaFactorId = null;
            _status = AuthStatus.unauthenticated;
            notifyListeners();
            return;
          }

          if (session != null) {
            _userProfile = _profileFromSupabaseUser(session.user);
            
            // Only re-verify MFA requirement on initial session, signedIn, or if currently unauthenticated
            if (_status == AuthStatus.unauthenticated ||
                event == AuthChangeEvent.signedIn ||
                event == AuthChangeEvent.initialSession) {
              await _checkMfaRequirement();
            }

            notifyListeners();
            if (!_needsMfaVerification && !_isEnrollingMfa && _status == AuthStatus.authenticated) {
              _refreshProfileInBackground();
            }
          }
        });
  }

  UserProfile _profileFromSupabaseUser(User user) {
    final meta = user.userMetadata ?? {};
    final avatarUrl = (meta['avatar_url'] ?? meta['picture'] ?? meta['avatar']) as String?;
    final name = (meta['full_name'] as String?) ??
        (meta['name'] as String?) ??
        (user.email != null ? user.email!.split('@').first : 'Planner');
    final email = user.email ?? (meta['email'] as String?) ?? '';

    return UserProfile(
      id: user.id,
      fullName: name,
      email: email,
      phone: (meta['phone'] as String?) ?? '',
      location: (meta['location'] as String?) ?? '',
      avatarUrl: avatarUrl,
      role: (meta['role'] as String?) ?? 'normal_user',
    );
  }

  Future<void> _checkMfaRequirement() async {
    final session = SupabaseService.currentSession;
    final user = SupabaseService.currentUser;

    if (!SupabaseService.isInitialized || session == null || user == null) {
      _needsMfaVerification = false;
      _mfaFactorId = null;
      _status = AuthStatus.unauthenticated;
      if (kDebugMode) {
        print('📊 MFA Requirement Check — No active session. Status: $_status');
      }
      return;
    }

    // Do NOT trigger login MFA challenge when user is actively enrolling in Settings
    if (_isEnrollingMfa) {
      _needsMfaVerification = false;
      _status = AuthStatus.authenticated;
      return;
    }

    try {
      final mfaLevel = SupabaseService.getAuthenticatorAssuranceLevel();
      if (mfaLevel != null &&
          mfaLevel.currentLevel == AuthenticatorAssuranceLevels.aal1 &&
          mfaLevel.nextLevel == AuthenticatorAssuranceLevels.aal2) {
        final verifiedFactors = await SupabaseService.getVerifiedTotpFactors();

        // Re-check session existence after await call
        if (SupabaseService.currentSession == null || SupabaseService.currentUser == null) {
          _needsMfaVerification = false;
          _mfaFactorId = null;
          _status = AuthStatus.unauthenticated;
          return;
        }

        if (verifiedFactors.isNotEmpty) {
          _mfaFactorId = verifiedFactors.first.id;
          _needsMfaVerification = true;
          _status = AuthStatus.mfaPending;
          
          try {
            SupabaseService.client.auth.stopAutoRefresh();
          } catch (_) {}

          if (kDebugMode) {
            print('📊 MFA Required — Session AAL: AAL1 (AAL2 Pending) | Verified Factor ID: $_mfaFactorId | Status: $_status');
          }
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ MFA requirement check exception: $e');
      }
    }

    if (SupabaseService.currentSession != null && SupabaseService.currentUser != null) {
      _needsMfaVerification = false;
      _mfaFactorId = null;
      _status = AuthStatus.authenticated;
      
      try {
        SupabaseService.client.auth.startAutoRefresh();
      } catch (_) {}

      if (kDebugMode) {
        print('📊 MFA Not Required / Satisfied — Status: $_status');
      }
    } else {
      _needsMfaVerification = false;
      _mfaFactorId = null;
      _status = AuthStatus.unauthenticated;
      
      try {
        SupabaseService.client.auth.startAutoRefresh();
      } catch (_) {}
      if (kDebugMode) {
        print('📊 Session lost during MFA check — Status: $_status');
      }
    }
  }

  Future<void> _init() async {
    _rememberMe = await StorageService.getRememberMeStatus();
    _savedEmail = await StorageService.getSavedEmail();
    final isGuest = await StorageService.isGuestMode();

    if (isGuest) {
      _status = AuthStatus.guest;
      _needsMfaVerification = false;
      _userProfile = UserProfile(
        id: 'guest_user',
        fullName: 'Guest User',
        email: 'guest@vowora.app',
        phone: '+880 1700000000',
        location: 'Dhaka, Bangladesh',
      );
      notifyListeners();
      return;
    }

    if (SupabaseService.isInitialized && SupabaseService.currentUser != null) {
      _userProfile = _profileFromSupabaseUser(SupabaseService.currentUser!);
      await _checkMfaRequirement();
      if (!_needsMfaVerification) {
        _refreshProfileInBackground();
      }
    } else {
      _status = AuthStatus.unauthenticated;
      _needsMfaVerification = false;
    }
    notifyListeners();
  }

  Future<void> _refreshProfileInBackground() async {
    if (_userProfile == null) return;
    if (!SupabaseService.isInitialized) return;
    try {
      final data = await SupabaseService.fetchUserProfile(_userProfile!.id);
      if (data != null) {
        _userProfile = UserProfile.fromJson(data);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _setLoading(true);
    _clearError();
    _isEnrollingMfa = false;
    try {
      if (SupabaseService.isInitialized) {
        try {
          final response = await SupabaseService.signInWithEmail(email, password);
          if (response?.user != null) {
            _userProfile = _profileFromSupabaseUser(response!.user!);
            await _checkMfaRequirement();
            if (!_needsMfaVerification) {
              _refreshProfileInBackground();
            }
          } else {
            throw Exception('Login failed. Please check your credentials.');
          }
        } catch (e) {
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('socketexception') ||
              errStr.contains('failed host lookup') ||
              errStr.contains('clientexception') ||
              errStr.contains('network') ||
              errStr.contains('connection')) {
            _userProfile = UserProfile(
              id: 'user_demo_${email.split('@').first}',
              fullName: email.split('@').first,
              email: email,
              phone: '+880 1700000000',
              location: 'Dhaka, Bangladesh',
            );
            _status = AuthStatus.authenticated;
            _needsMfaVerification = false;
          } else {
            rethrow;
          }
        }
      } else {
        _userProfile = UserProfile(
          id: 'user_demo_${email.split('@').first}',
          fullName: email.split('@').first,
          email: email,
          phone: '+880 1700000000',
          location: 'Dhaka, Bangladesh',
        );
        _status = AuthStatus.authenticated;
        _needsMfaVerification = false;
      }

      await StorageService.setRememberMe(rememberMe, email);
      await StorageService.setGuestMode(false);
      _rememberMe = rememberMe;
      _savedEmail = rememberMe ? email : null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyMfaChallenge(String code) async {
    if (_mfaFactorId == null) {
      try {
        final verifiedFactors = await SupabaseService.getVerifiedTotpFactors();
        if (verifiedFactors.isNotEmpty) {
          _mfaFactorId = verifiedFactors.first.id;
        }
      } catch (_) {}
    }

    if (_mfaFactorId == null) {
      _errorMessage = 'No verified 2FA factor found. Please sign in again or set up 2FA.';
      _needsMfaVerification = false;
      _status = AuthStatus.unauthenticated;
      _userProfile = null;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();
    try {
      final verified = await SupabaseService.challengeAndVerifyTotpMfa(
        factorId: _mfaFactorId!,
        code: code,
      );

      if (verified) {
        _needsMfaVerification = false;
        _status = AuthStatus.authenticated;
        
        try {
          SupabaseService.client.auth.startAutoRefresh();
        } catch (_) {}

        _refreshProfileInBackground();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        throw Exception('Incorrect verification code. Please try again.');
      }
    } catch (e) {
      final errStr = e.toString().replaceAll('Exception: ', '');

      if (errStr.contains('session has expired') ||
          errStr.contains('session_expired') ||
          errStr.contains('JWT expired')) {
        _needsMfaVerification = false;
        _mfaFactorId = null;
        _status = AuthStatus.unauthenticated;
        _userProfile = null;
      }

      _errorMessage = errStr;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String location,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    _isEnrollingMfa = false;
    try {
      final metadata = {
        'full_name': fullName,
        'phone': phone,
        'location': location,
      };

      if (SupabaseService.isInitialized) {
        try {
          final response = await SupabaseService.signUpWithEmail(
            email: email,
            password: password,
            data: metadata,
          );
          final user = response?.user;
          if (user != null) {
            _userProfile = _profileFromSupabaseUser(user);
            _status = AuthStatus.authenticated;
            _needsMfaVerification = false;
          } else {
            throw Exception('Signup failed. Please try again.');
          }
        } catch (e) {
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('socketexception') ||
              errStr.contains('failed host lookup') ||
              errStr.contains('clientexception') ||
              errStr.contains('network') ||
              errStr.contains('connection')) {
            _userProfile = UserProfile(
              id: 'user_demo_${DateTime.now().millisecondsSinceEpoch}',
              fullName: fullName,
              email: email,
              phone: phone,
              location: location,
            );
            _status = AuthStatus.authenticated;
            _needsMfaVerification = false;
          } else {
            rethrow;
          }
        }
      } else {
        _userProfile = UserProfile(
          id: 'user_demo_${DateTime.now().millisecondsSinceEpoch}',
          fullName: fullName,
          email: email,
          phone: phone,
          location: location,
        );
        _status = AuthStatus.authenticated;
        _needsMfaVerification = false;
      }

      await StorageService.setGuestMode(false);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> loginWithOAuth(OAuthProvider provider) async {
    _setLoading(true);
    _clearError();
    _isEnrollingMfa = false;
    try {
      await SupabaseService.signInWithOAuth(provider);
      _setLoading(false);
    } catch (e) {
      _errorMessage = e
          .toString()
          .replaceAll('OAuthNotConfiguredException: ', '')
          .replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> continueAsGuest() async {
    _status = AuthStatus.guest;
    _needsMfaVerification = false;
    _isEnrollingMfa = false;
    _userProfile = UserProfile(
      id: 'guest_user',
      fullName: 'Guest User',
      email: 'guest@vowora.app',
      phone: '+880 1700000000',
      location: 'Dhaka, Bangladesh',
    );
    await StorageService.setGuestMode(true);
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await SupabaseService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String location,
  }) async {
    if (_userProfile == null) return;
    _userProfile = _userProfile!.copyWith(
      fullName: fullName,
      phone: phone,
      location: location,
    );
    notifyListeners();
    if (SupabaseService.isInitialized) {
      try {
        await SupabaseService.client.from('users').update({
          'full_name': fullName,
          'phone': phone,
          'location': location,
        }).eq('id', _userProfile!.id);
      } catch (_) {}
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    if (_userProfile == null) return false;
    if (!SupabaseService.isInitialized) return false;
    _setLoading(true);
    _clearError();
    try {
      final url = await SupabaseService.uploadAvatar(
        userId: _userProfile!.id,
        filePath: filePath,
      );
      if (url != null) {
        _userProfile = _userProfile!.copyWith(avatarUrl: url);
        notifyListeners();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    await _refreshProfileInBackground();
  }

  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();
    try {
      if (SupabaseService.isInitialized && SupabaseService.currentUser != null) {
        await SupabaseService.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _needsMfaVerification = false;
    _isEnrollingMfa = false;
    _mfaFactorId = null;
    await StorageService.setGuestMode(false);
    await StorageService.setRememberMe(false, '');
    await StorageService.clearSession();
    await SupabaseService.signOut();
    _status = AuthStatus.unauthenticated;
    _userProfile = null;
    _setLoading(false);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
