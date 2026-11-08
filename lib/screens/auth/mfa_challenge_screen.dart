import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class MfaChallengeScreen extends StatefulWidget {
  const MfaChallengeScreen({super.key});

  @override
  State<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends State<MfaChallengeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isNavigating = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _handleVerifyCode() async {
    if (_isNavigating) return;
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit authenticator code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyMfaChallenge(code);

    if (!mounted || _isNavigating) return;

    if (success && authProvider.isAuthenticated) {
      _isNavigating = true;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      if (authProvider.isUnauthenticated) {
        _isNavigating = true;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Your login session has expired. Please sign in again.'),
            backgroundColor: VoworaColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = authProvider.errorMessage ?? 'Incorrect authenticator code. Please try again.';
        });
      }
    }
  }

  Future<void> _handleCancel() async {
    if (_isNavigating) return;
    _isNavigating = true;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Security Verification',
          style: GoogleFonts.playfairDisplay(
            color: VoworaColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/wedding_background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.78),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: VoworaColors.champagneGold, width: 2.0),
                      ),
                      child: const Icon(Icons.security_rounded, color: VoworaColors.champagneGold, size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Two-Factor Authentication 🔐',
                      style: GoogleFonts.playfairDisplay(
                        color: VoworaColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 6-digit code from Google Authenticator or Authy to complete sign in.',
                      style: GoogleFonts.plusJakartaSans(
                        color: VoworaColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            color: VoworaColors.darkCardBackground.withValues(alpha: 0.75),
                            border: Border.all(
                              color: VoworaColors.champagneGold.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                style: GoogleFonts.playfairDisplay(
                                  color: VoworaColors.champagneGold,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 8.0,
                                ),
                                textAlign: TextAlign.center,
                                onChanged: (_) => _clearError(),
                                decoration: InputDecoration(
                                  labelText: 'Enter 6-Digit Code',
                                  labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, letterSpacing: 0),
                                  hintText: '000000',
                                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white24, letterSpacing: 8.0),
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.08),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  _errorMessage!,
                                  style: GoogleFonts.plusJakartaSans(color: VoworaColors.error, fontSize: 12.5),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleVerifyCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: VoworaColors.champagneGold,
                                    foregroundColor: VoworaColors.darkBackground,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: VoworaColors.darkBackground),
                                        )
                                      : Text(
                                          'Verify Code & Sign In',
                                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _isLoading ? null : _handleCancel,
                                child: Text(
                                  'Cancel & Sign Out',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: VoworaColors.textSecondary,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
