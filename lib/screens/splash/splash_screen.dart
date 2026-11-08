import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/vowora_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/vowora_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final onboardingDone = await StorageService.isOnboardingCompleted();
    if (!mounted) return;

    if (authProvider.needsMfaVerification) {
      Navigator.pushReplacementNamed(context, AppRoutes.mfaChallenge);
    } else if (authProvider.isAuthenticated || authProvider.isGuest) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (onboardingDone) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Wedding Imagery
          Positioned.fill(
            child: Image.asset(
              VoworaConstants.bgWeddingHero,
              fit: BoxFit.cover,
            ),
          ),
          // Elegant Dark Glass Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),
          // Logo & Slogan Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Monogram Icon / Flourish
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: VoworaColors.champagneGold, width: 1.5),
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Text(
                          'V',
                          style: GoogleFonts.playfairDisplay(
                            color: VoworaColors.champagneGold,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      VoworaConstants.appName,
                      style: GoogleFonts.playfairDisplay(
                        color: VoworaColors.champagneGold,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      VoworaConstants.appTaglineSingleLine,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.0,
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
