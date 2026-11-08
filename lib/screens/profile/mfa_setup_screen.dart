import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/vowora_theme.dart';
import '../../core/services/supabase_service.dart';

enum MfaSetupStep { reauthenticate, scanQrAndVerify, success }

class MfaSetupScreen extends StatefulWidget {
  const MfaSetupScreen({super.key});

  @override
  State<MfaSetupScreen> createState() => _MfaSetupScreenState();
}

class _MfaSetupScreenState extends State<MfaSetupScreen> {
  MfaSetupStep _currentStep = MfaSetupStep.reauthenticate;
  bool _isLoading = false;
  String? _errorMessage;

  // Step 1: Reauthentication
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Step 2: TOTP Enrollment Transient State (NOT stored or logged permanently)
  String? _factorId;
  String? _secret;
  String? _qrSvgString;
  final TextEditingController _totpCodeController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _totpCodeController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  // ===== Step 1: Handle Recent Reauthentication =====
  Future<void> _handleReauthentication() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password to continue.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAuthSuccess = await SupabaseService.reauthenticateUser(password);
      if (!isAuthSuccess) {
        throw Exception('Reauthentication failed. Invalid password.');
      }

      // Automatically proceed to TOTP enrollment after successful reauthentication
      await _startTotpEnrollment();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // ===== Step 2: Start TOTP Enrollment =====
  Future<void> _startTotpEnrollment() async {
    try {
      final enrollRes = await SupabaseService.enrollTotpMfa();
      if (enrollRes == null || enrollRes.totp == null) {
        throw Exception('Unable to generate TOTP enrollment parameters.');
      }

      setState(() {
        _factorId = enrollRes.id;
        _secret = enrollRes.totp!.secret;
        _qrSvgString = enrollRes.totp!.qrCode;
        _currentStep = MfaSetupStep.scanQrAndVerify;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // ===== Step 3: Challenge and Verify 6-digit TOTP Code =====
  Future<void> _handleVerifyTotpCode() async {
    final code = _totpCodeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a valid 6-digit code from your authenticator app.');
      return;
    }

    if (_factorId == null) {
      setState(() => _errorMessage = 'Enrollment session expired. Please try again.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final verified = await SupabaseService.challengeAndVerifyTotpMfa(
        factorId: _factorId!,
        code: code,
      );

      if (verified) {
        setState(() {
          _isLoading = false;
          _currentStep = MfaSetupStep.success;
        });
      } else {
        throw Exception('Verification failed. Invalid code.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: VoworaColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Two-Step Verification',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case MfaSetupStep.reauthenticate:
        return _buildReauthenticateStep();
      case MfaSetupStep.scanQrAndVerify:
        return _buildScanAndVerifyStep();
      case MfaSetupStep.success:
        return _buildSuccessStep();
    }
  }

  // ===== Step 1 View: Reauthentication =====
  Widget _buildReauthenticateStep() {
    return Column(
      key: const ValueKey('step_reauth'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          stepNumber: '1',
          title: 'Confirm Password',
          subtitle: 'For your security, re-enter your account password before setting up Two-Step Verification.',
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: VoworaColors.darkCardBackground.withValues(alpha: 0.7),
                border: Border.all(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.35),
                  width: 1.1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    onChanged: (_) => _clearError(),
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: VoworaColors.champagneGold),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: Colors.white60,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.plusJakartaSans(color: VoworaColors.error, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleReauthentication,
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
                              'Verify & Continue',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Step 2 View: Scan QR Code & Enter TOTP Token =====
  Widget _buildScanAndVerifyStep() {
    return Column(
      key: const ValueKey('step_scan_verify'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          stepNumber: '2',
          title: 'Link Authenticator App',
          subtitle: 'Scan the QR code below or enter the manual key in Google Authenticator, Authy, or 1Password.',
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: VoworaColors.darkCardBackground.withValues(alpha: 0.7),
                border: Border.all(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.35),
                  width: 1.1,
                ),
              ),
              child: Column(
                children: [
                  // QR Code Container
                  if (_qrSvgString != null && _qrSvgString!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: VoworaColors.champagneGold, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: VoworaColors.champagneGold.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: SvgQrWidget(svgString: _qrSvgString!),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Manual Secret Key Box
                  if (_secret != null && _secret!.isNotEmpty) ...[
                    Text(
                      'Manual Setup Key:',
                      style: GoogleFonts.plusJakartaSans(color: VoworaColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              _secret!,
                              style: GoogleFonts.firaCode(
                                color: VoworaColors.champagneGold,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, color: VoworaColors.champagneGold, size: 18),
                            tooltip: 'Copy Secret Key',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _secret!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Secret key copied to clipboard', style: GoogleFonts.plusJakartaSans()),
                                  backgroundColor: VoworaColors.darkCardBackground,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 6-digit Code Verification Field
                  TextField(
                    controller: _totpCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: GoogleFonts.playfairDisplay(
                      color: VoworaColors.champagneGold,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6.0,
                    ),
                    textAlign: TextAlign.center,
                    onChanged: (_) => _clearError(),
                    decoration: InputDecoration(
                      labelText: 'Enter 6-Digit Authenticator Code',
                      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, letterSpacing: 0),
                      hintText: '000000',
                      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white24, letterSpacing: 6.0),
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.plusJakartaSans(color: VoworaColors.error, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleVerifyTotpCode,
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
                              'Verify & Complete Setup',
                              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Step 3 View: Success Confirmation =====
  Widget _buildSuccessStep() {
    return Column(
      key: const ValueKey('step_success'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: VoworaColors.champagneGold.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: VoworaColors.champagneGold, width: 2.0),
          ),
          child: const Icon(Icons.verified_user_rounded, color: VoworaColors.champagneGold, size: 54),
        ),
        const SizedBox(height: 20),
        Text(
          'Two-Step Verification Active ✨',
          style: GoogleFonts.playfairDisplay(
            color: VoworaColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Your account is now securely protected with Two-Step Verification (TOTP MFA).',
          style: GoogleFonts.plusJakartaSans(
            color: VoworaColors.textSecondary,
            fontSize: 13,
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: VoworaColors.champagneGold,
              foregroundColor: VoworaColors.darkBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            ),
            child: Text(
              'Return to Settings',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepHeader({
    required String stepNumber,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: VoworaColors.champagneGold,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: GoogleFonts.plusJakartaSans(
                color: VoworaColors.darkBackground,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  color: VoworaColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  color: VoworaColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== Lightweight Custom SVG QR Painter =====
class SvgQrWidget extends StatelessWidget {
  final String svgString;

  const SvgQrWidget({super.key, required this.svgString});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SvgQrPainter(svgString),
      child: const SizedBox.expand(),
    );
  }
}

class _SvgQrPainter extends CustomPainter {
  final String svgString;

  _SvgQrPainter(this.svgString);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Parse rect elements from SVG
    final rectRegex = RegExp(
      r'<rect[^>]*x=["\']([^"\']+)["\'][^>]*y=["\']([^"\']+)["\'][^>]*width=["\']([^"\']+)["\'][^>]*height=["\']([^"\']+)["\']',
      caseSensitive: false,
    );

    double viewBoxWidth = 100;
    double viewBoxHeight = 100;

    final viewBoxRegex = RegExp(r'viewBox=["\']0 0 ([0-9.]+) ([0-9.]+)["\']');
    final viewBoxMatch = viewBoxRegex.firstMatch(svgString);
    if (viewBoxMatch != null) {
      viewBoxWidth = double.tryParse(viewBoxMatch.group(1) ?? '100') ?? 100;
      viewBoxHeight = double.tryParse(viewBoxMatch.group(2) ?? '100') ?? 100;
    }

    final scaleX = size.width / viewBoxWidth;
    final scaleY = size.height / viewBoxHeight;

    final matches = rectRegex.allMatches(svgString);
    bool foundRects = false;

    for (final match in matches) {
      final x = double.tryParse(match.group(1) ?? '0') ?? 0;
      final y = double.tryParse(match.group(2) ?? '0') ?? 0;
      final w = double.tryParse(match.group(3) ?? '0') ?? 0;
      final h = double.tryParse(match.group(4) ?? '0') ?? 0;

      // Skip white background rect if it matches viewBox size
      if (x == 0 && y == 0 && w >= viewBoxWidth && h >= viewBoxHeight) {
        continue;
      }

      foundRects = true;
      canvas.drawRect(
        Rect.fromLTWH(x * scaleX, y * scaleY, w * scaleX, h * scaleY),
        paint,
      );
    }

    // Fallback if SVG uses path instead of rect
    if (!foundRects) {
      final pathRegex = RegExp(r'd=["\']([^"\']+)["\']');
      final pathMatch = pathRegex.firstMatch(svgString);
      if (pathMatch != null) {
        final dStr = pathMatch.group(1) ?? '';
        final commandRegex = RegExp(r'M\s*([0-9.]+)[,\s]+([0-9.]+)\s*h\s*([0-9.]+)\s*v\s*([0-9.]+)\s*h\s*-([0-9.]+)\s*z', caseSensitive: false);
        final cmdMatches = commandRegex.allMatches(dStr);
        for (final cm in cmdMatches) {
          final x = double.tryParse(cm.group(1) ?? '0') ?? 0;
          final y = double.tryParse(cm.group(2) ?? '0') ?? 0;
          final w = double.tryParse(cm.group(3) ?? '0') ?? 0;
          final h = double.tryParse(cm.group(4) ?? '0') ?? 0;
          canvas.drawRect(
            Rect.fromLTWH(x * scaleX, y * scaleY, w * scaleX, h * scaleY),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SvgQrPainter oldDelegate) {
    return oldDelegate.svgString != svgString;
  }
}
