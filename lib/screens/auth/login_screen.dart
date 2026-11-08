import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/vowora_constants.dart';
import '../../core/theme/vowora_theme.dart';
import '../../core/utils/vowora_validators.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/support_card.dart';
import '../../widgets/vowora_button.dart';
import '../../widgets/vowora_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _showSupportInfo = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.savedEmail != null && authProvider.savedEmail!.isNotEmpty) {
        _emailController.text = authProvider.savedEmail!;
        setState(() {
          _rememberMe = authProvider.rememberMe;
        });
      }
      authProvider.addListener(_onAuthChanged);
    });
  }

  void _onAuthChanged() {
    if (!mounted || _isNavigating) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.needsMfaVerification || authProvider.isMfaPending) {
      _isNavigating = true;
      authProvider.removeListener(_onAuthChanged);
      Navigator.pushReplacementNamed(context, AppRoutes.mfaChallenge);
    } else if (authProvider.isAuthenticated) {
      _isNavigating = true;
      authProvider.removeListener(_onAuthChanged);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.removeListener(_onAuthChanged);
    } catch (_) {}
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate() || _isNavigating) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );
    if (!mounted || _isNavigating) return;
    if (authProvider.needsMfaVerification || authProvider.isMfaPending) {
      _isNavigating = true;
      authProvider.removeListener(_onAuthChanged);
      Navigator.pushReplacementNamed(context, AppRoutes.mfaChallenge);
    } else if (success && authProvider.isAuthenticated) {
      _isNavigating = true;
      authProvider.removeListener(_onAuthChanged);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Sign in failed. Please check credentials.'),
          backgroundColor: VoworaColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleOAuthLogin(OAuthProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.loginWithOAuth(provider);
      if (!mounted) return;
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      _showOAuthInfoDialog(
        provider.name.toUpperCase()[0] + provider.name.substring(1),
        e.toString(),
      );
    }
  }

  void _showOAuthInfoDialog(String providerName, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: VoworaColors.champagneGold),
            const SizedBox(width: 8),
            Text(
              '$providerName Sign-In',
              style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          '$providerName sign-in is not configured yet. Please use email and password.',
          style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.plusJakartaSans(
                color: VoworaColors.champagneGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGuestLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.continueAsGuest();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(VoworaConstants.bgWeddingHero, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: VoworaColors.champagneGold.withValues(alpha: 0.9),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'V',
                            style: GoogleFonts.playfairDisplay(
                              color: VoworaColors.champagneGold,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        VoworaConstants.appName,
                        style: GoogleFonts.playfairDisplay(
                          color: VoworaColors.champagneGold,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 5.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        VoworaConstants.appTaglineSingleLine,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back ♥',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue planning your perfect day.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),
                          VoworaTextField(
                            controller: _emailController,
                            hintText: 'Email address',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: VoworaValidators.validateEmail,
                          ),
                          const SizedBox(height: 14),
                          VoworaTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: VoworaValidators.validateLoginPassword,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20, height: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                      activeColor: VoworaColors.champagneGold,
                                      checkColor: const Color(0xFF141210),
                                      side: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.forgotPassword);
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: VoworaColors.champagneGold,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                    decorationColor: VoworaColors.champagneGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          VoworaPrimaryButton(
                            text: 'Continue',
                            isLoading: authProvider.isLoading,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.2))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or continue with',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.2))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          VoworaSocialButton(
                            text: 'Continue with Google',
                            iconWidget: const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 26),
                            onPressed: () => _handleOAuthLogin(OAuthProvider.google),
                          ),
                          const SizedBox(height: 10),
                          VoworaSocialButton(
                            text: 'Continue with Apple',
                            iconWidget: const Icon(Icons.apple, color: Colors.white, size: 22),
                            onPressed: () => _handleOAuthLogin(OAuthProvider.apple),
                          ),
                          const SizedBox(height: 10),
                          VoworaSocialButton(
                            text: 'Continue with Facebook',
                            iconWidget: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
                            onPressed: () => _handleOAuthLogin(OAuthProvider.facebook),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New to Vowora? ',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                                  child: Text(
                                    'Create an account →',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: VoworaColors.champagneGold,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          VoworaOutlinedButton(
                            text: 'Continue as Guest',
                            icon: Icons.person_outline_rounded,
                            showArrow: true,
                            onPressed: _handleGuestLogin,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.termsPrivacy),
                              child: Column(
                                children: [
                                  Text(
                                    'By continuing, you agree to our',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    'Terms of Service & Privacy Policy',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: VoworaColors.champagneGold.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showSupportInfo = !_showSupportInfo;
                      });
                    },
                    icon: Icon(
                      _showSupportInfo ? Icons.close : Icons.headset_mic_outlined,
                      color: VoworaColors.champagneGold,
                      size: 18,
                    ),
                    label: Text(
                      _showSupportInfo ? 'Hide Support' : 'Need Help?',
                      style: GoogleFonts.plusJakartaSans(
                        color: VoworaColors.champagneGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (_showSupportInfo) ...[
                    const SizedBox(height: 12),
                    const SupportCard(isDark: true),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}