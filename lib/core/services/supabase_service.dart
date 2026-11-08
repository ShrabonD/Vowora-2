import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/vowora_constants.dart';

class SupabaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception(
          'Supabase is not initialized. Please configure credentials in vowora_constants.dart.');
    }
    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    try {
      if (VoworaConstants.supabaseUrl.contains('YOUR_SUPABASE') ||
          VoworaConstants.supabaseAnonKey.contains('YOUR_SUPABASE')) {
        if (kDebugMode) {
          print('Supabase credentials are placeholder values. Operating in local/demo mode.');
        }
        _isInitialized = false;
        return;
      }

      await Supabase.initialize(
        url: VoworaConstants.supabaseUrl,
        publishableKey: VoworaConstants.supabaseAnonKey,
      );
      _isInitialized = true;

      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Supabase: $e');
      }
      _isInitialized = false;
    }
  }

  // ===== Auth Getters =====
  static User? get currentUser {
    if (!_isInitialized) return null;
    return client.auth.currentUser;
  }

  static Session? get currentSession {
    if (!_isInitialized) return null;
    return client.auth.currentSession;
  }

  // ===== Email/Password Auth =====
  static Future<AuthResponse?> signInWithEmail(
      String email, String password) async {
    if (!_isInitialized) return null;
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Incorrect email or password. Please try again.');
    } catch (e) {
      throw Exception(
          'Unable to sign in. Please check your network connection.');
    }
  }

  static Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    if (!_isInitialized) return null;
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
          'Unable to create account. Please check your network connection.');
    }
  }

  // ===== OAuth (Google / Facebook) =====
  static Future<void> signInWithOAuth(OAuthProvider provider) async {
    if (!_isInitialized) {
      final providerName =
          provider.name.toUpperCase()[0] + provider.name.substring(1);
      throw OAuthNotConfiguredException(
        '$providerName sign-in is not configured yet. Please use email and password.',
      );
    }

    try {
      await client.auth.signInWithOAuth(
        provider,
        redirectTo: VoworaConstants.redirectUrl,
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
      );
    } on AuthException catch (e) {
      final providerName =
          provider.name.toUpperCase()[0] + provider.name.substring(1);
      throw OAuthNotConfiguredException(
        '$providerName sign-in error: ${e.message}. Please use email and password.',
      );
    } catch (e) {
      final providerName =
          provider.name.toUpperCase()[0] + provider.name.substring(1);
      throw OAuthNotConfiguredException(
        '$providerName sign-in is not configured yet. Please use email and password.',
      );
    }
  }

  // ===== Password Reset =====
  static Future<void> resetPassword(String email) async {
    if (!_isInitialized) return;
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: VoworaConstants.redirectUrl,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
          'Unable to send password reset email. Please try again.');
    }
  }

  // ===== Sign Out =====
  static Future<void> signOut() async {
    if (!_isInitialized) return;
    if (kDebugMode) {
      print('🚪 SupabaseService.signOut() invoked from:\n${StackTrace.current}');
    }
    try {
      await client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error during SupabaseService.signOut(): $e');
      }
    }
  }

  // ===== Avatar Upload =====
  /// ইউজারের avatar আপলোড করে public URL ফেরত দেয়
  static Future<String?> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    if (!_isInitialized) {
      throw Exception('Supabase is not initialized.');
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/avatar_$timestamp.jpg';

      final bytes = await File(filePath).readAsBytes();

      await client.storage.from('avatars').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

      final publicUrl = client.storage.from('avatars').getPublicUrl(fileName);

      await client
          .from('users')
          .update({'avatar_url': publicUrl}).eq('id', userId);

      return publicUrl;
    } on StorageException catch (e) {
      throw Exception('Avatar upload failed: ${e.message}');
    } catch (e) {
      throw Exception('Avatar upload failed. Please try again.');
    }
  }

  // ===== Fetch user from database =====
  /// Supabase-এর users টেবিল থেকে সম্পূর্ণ প্রোফাইল আনে
  static Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    if (!_isInitialized) return null;
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching profile: ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching profile: $e');
      }
      return null;
    }
  }

  // ===== TOTP MFA (Two-Factor Authentication) Services =====

  /// Checks current session Authenticator Assurance Level (aal1 vs aal2)
  static AuthMFAGetAuthenticatorAssuranceLevelResponse? getAuthenticatorAssuranceLevel() {
    if (!_isInitialized || client.auth.currentSession == null) return null;
    try {
      final mfaRes = client.auth.mfa.getAuthenticatorAssuranceLevel();
      return mfaRes;
    } catch (_) {
      return null;
    }
  }

  /// Reauthenticates current user password before sensitive actions
  static Future<bool> reauthenticateUser(String password) async {
    if (!_isInitialized || currentUser?.email == null) return false;
    try {
      final res = await client.auth.signInWithPassword(
        email: currentUser!.email!,
        password: password,
      );
      return res.user != null;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('Reauthentication failed. Please check your password.');
    }
  }

  /// Unenrolls all unverified TOTP factors to ensure fresh enrollment
  static Future<void> cleanUnverifiedTotpFactors() async {
    if (!_isInitialized || client.auth.currentSession == null) return;
    try {
      final factors = await client.auth.mfa.listFactors();
      for (final factor in factors.totp) {
        if (factor.status == FactorStatus.unverified) {
          await client.auth.mfa.unenroll(factor.id);
        }
      }
    } catch (_) {}
  }

  /// Gets list of active verified TOTP factors
  static Future<List<Factor>> getVerifiedTotpFactors() async {
    if (!_isInitialized || client.auth.currentSession == null) return [];
    try {
      final factors = await client.auth.mfa.listFactors();
      return factors.totp.where((f) => f.status == FactorStatus.verified).toList();
    } catch (_) {
      return [];
    }
  }

  /// Enrolls a brand new TOTP factor with a fresh secret
  static Future<AuthMFAEnrollResponse?> enrollTotpMfa() async {
    if (!_isInitialized) return null;
    try {
      await cleanUnverifiedTotpFactors();
      final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
      final res = await client.auth.mfa.enroll(
        factorType: FactorType.totp,
        issuer: 'VOWORA',
        friendlyName: 'Vowora Event Planner ($timestamp)',
      );
      return res;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to enroll 2FA factor: $e');
    }
  }

  /// Challenges and verifies 6-digit TOTP code
  static Future<bool> challengeAndVerifyTotpMfa({
    required String factorId,
    required String code,
  }) async {
    if (!_isInitialized) return false;

    final session = client.auth.currentSession;
    if (session == null || currentUser == null) {
      throw Exception('Your login session has expired. Please sign in again.');
    }

    if (kDebugMode) {
      final mfaLevel = getAuthenticatorAssuranceLevel();
      print('🔍 MFA Diagnostic — User ID: ${currentUser?.id}, Factor ID: $factorId, Current AAL: ${mfaLevel?.currentLevel}, Next AAL: ${mfaLevel?.nextLevel}');
    }

    try {
      final challengeRes = await client.auth.mfa.challenge(factorId: factorId);
      final verifyRes = await client.auth.mfa.verify(
        factorId: factorId,
        challengeId: challengeRes.id,
        code: code,
      );
      return verifyRes.accessToken.isNotEmpty;
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('❌ Supabase MFA AuthException — Code: ${e.code}, StatusCode: ${e.statusCode}, Message: ${e.message}');
      }
      final msg = e.message.toLowerCase();
      final errCode = e.code?.toLowerCase() ?? '';

      final isOtpError = errCode == 'mfa_verification_failed' ||
          errCode == 'mfa_verification_rejected' ||
          errCode == 'invalid_grant' ||
          errCode == 'bad_code' ||
          errCode == 'invalid_code' ||
          errCode == 'invalid_credentials' ||
          errCode == 'bad_code_verifier' ||
          msg.contains('invalid code') ||
          msg.contains('incorrect code') ||
          msg.contains('invalid totp') ||
          msg.contains('invalid otp') ||
          msg.contains('bad code') ||
          msg.contains('verification failed') ||
          msg.contains('mfa_challenge_failed') ||
          msg.contains('code is invalid') ||
          msg.contains('invalid verification code') ||
          msg.contains('totp code') ||
          msg.contains('wrong code');

      if (isOtpError) {
        throw Exception('Incorrect verification code. Please try again.');
      } else if (errCode == 'mfa_challenge_expired' || msg.contains('challenge expired')) {
        throw Exception('The 2FA challenge expired. Please enter a fresh 6-digit code from your app.');
      } else if (errCode == 'mfa_factor_not_found' || errCode == 'factor_not_found' || msg.contains('factor not found')) {
        throw Exception('The 2FA enrollment factor was not found. Please tap Generate 2FA QR Code again.');
      } else if (errCode == 'session_expired' || errCode == 'jwt_expired' || msg.contains('jwt expired') || msg.contains('session expired') || msg.contains('session_expired')) {
        throw Exception('Your login session has expired. Please sign in again.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Verification failed. Incorrect code or network error.');
    }
  }

  /// Unenrolls a TOTP factor
  static Future<void> unenrollTotpFactor(String factorId) async {
    if (!_isInitialized) return;
    try {
      await client.auth.mfa.unenroll(factorId);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('Failed to disable Two-Factor Authentication.');
    }
  }
}

class OAuthNotConfiguredException implements Exception {
  final String message;
  OAuthNotConfiguredException(this.message);

  @override
  String toString() => message;
}
