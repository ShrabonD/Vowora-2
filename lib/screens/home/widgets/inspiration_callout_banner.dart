import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/vowora_theme.dart';
import '../../../routes/app_routes.dart';

class InspirationCalloutBanner extends StatelessWidget {
  const InspirationCalloutBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: VoworaColors.champagneGold.withValues(alpha: 0.12),
            border: Border.all(
              color: VoworaColors.champagneGold.withValues(alpha: 0.35),
              width: 1.2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                VoworaColors.champagneGold.withValues(alpha: 0.18),
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: VoworaColors.champagneGold, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Event Inspirations',
                      style: GoogleFonts.playfairDisplay(
                        color: VoworaColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover luxury editorial themes, floral designs, stage setups, and decor.',
                      style: GoogleFonts.plusJakartaSans(
                        color: VoworaColors.textSecondary,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.inspiration),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VoworaColors.champagneGold,
                  foregroundColor: VoworaColors.darkBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  'Explore',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
