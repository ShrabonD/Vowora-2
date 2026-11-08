import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/vowora_constants.dart';
import '../../core/theme/vowora_theme.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: VoworaColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Privacy Policy',
          style: GoogleFonts.playfairDisplay(
            color: VoworaColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Atmosphere
          Positioned.fill(
            child: Image.asset(
              'assets/images/wedding_background.png',
              fit: BoxFit.cover,
            ),
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                // Header Card
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
                          color: VoworaColors.champagneGold.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            VoworaColors.champagneGold.withValues(alpha: 0.18),
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, color: VoworaColors.champagneGold, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'VOWORA LEGAL & PRIVACY',
                                style: GoogleFonts.plusJakartaSans(
                                  color: VoworaColors.champagneGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Plan beautifully. Celebrate endlessly.',
                            style: GoogleFonts.playfairDisplay(
                              color: VoworaColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your trust and data privacy are at the core of our luxury event planning experience.',
                            style: GoogleFonts.plusJakartaSans(
                              color: VoworaColors.textSecondary,
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Terms of Service Section
                _buildGlassSection(
                  title: 'Terms of Service',
                  icon: Icons.gavel_rounded,
                  children: [
                    _buildSectionBody(
                      'Welcome to VOWORA. By using our smart luxury wedding and event management application, you agree to comply with and be bound by the following terms of service.',
                    ),
                    const SizedBox(height: 16),
                    _buildSubHeader('1. User Account & Data Privacy'),
                    _buildSectionBody(
                      'Your privacy is deeply important to us. Account profile information, wedding guest lists, budget details, and vendor contacts are stored securely in Supabase PostgreSQL database schemas with Row Level Security (RLS) enforcement.',
                    ),
                    const SizedBox(height: 16),
                    _buildSubHeader('2. Guest Mode & Authentication'),
                    _buildSectionBody(
                      'Vowora allows guest mode exploration. Data created in guest mode is cached locally. To ensure permanent data persistence across devices and cloud sync, users must register a free account.',
                    ),
                    const SizedBox(height: 16),
                    _buildSubHeader('3. Support & Project Ownership'),
                    _buildSectionBody(
                      'This software product is engineered as a premier luxury event management platform. For support inquiries, contact ${VoworaConstants.supportEmail}.',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Privacy Policy Section
                _buildGlassSection(
                  title: 'Privacy Policy',
                  icon: Icons.security_rounded,
                  children: [
                    _buildSectionBody(
                      'Vowora adheres strictly to global data protection standards. We do not sell, rent, or distribute personal information to third parties.',
                    ),
                    const SizedBox(height: 16),
                    _buildSubHeader('1. Secure OAuth & Authentication'),
                    _buildSectionBody(
                      'OAuth login integrations (Google, Apple, Facebook) process authentication securely through Supabase Auth, ensuring your credentials remain fully encrypted.',
                    ),
                    const SizedBox(height: 16),
                    _buildSubHeader('2. Local Storage & Encryption'),
                    _buildSectionBody(
                      'Sensitive session tokens and preferences are stored securely using encrypted local storage facilities on your device.',
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Close Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VoworaColors.champagneGold,
                      foregroundColor: VoworaColors.darkBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      'Got It',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: VoworaColors.darkCardBackground.withValues(alpha: 0.68),
            border: Border.all(
              color: VoworaColors.champagneGold.withValues(alpha: 0.35),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
                    ),
                    child: Icon(icon, color: VoworaColors.champagneGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      color: VoworaColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(
        color: VoworaColors.champagneGold,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: VoworaColors.textSecondary,
          fontSize: 13,
          height: 1.55,
        ),
      ),
    );
  }
}
