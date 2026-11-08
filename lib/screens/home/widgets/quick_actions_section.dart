import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/vowora_theme.dart';
import '../../../routes/app_routes.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Actions',
              style: GoogleFonts.playfairDisplay(
                color: VoworaColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Fast Access',
              style: GoogleFonts.plusJakartaSans(
                color: VoworaColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                title: 'Create Event',
                subtitle: 'Start planning',
                icon: Icons.add_rounded,
                accentColor: VoworaColors.champagneGold,
                onTap: () => Navigator.pushNamed(context, AppRoutes.weddingManager),
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                title: 'Join Event',
                subtitle: 'Use Code / QR',
                icon: Icons.qr_code_scanner_rounded,
                accentColor: VoworaColors.mutedRoseGold,
                onTap: () => Navigator.pushNamed(context, AppRoutes.joinWedding),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                title: 'My Events',
                subtitle: 'All bookings',
                icon: Icons.event_note_rounded,
                accentColor: VoworaColors.softIvory,
                onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                title: 'Explore Ideas',
                subtitle: 'Luxury themes',
                icon: Icons.lightbulb_outline_rounded,
                accentColor: VoworaColors.lightGold,
                onTap: () => Navigator.pushNamed(context, AppRoutes.inspiration),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: accentColor.withValues(alpha: 0.2),
            highlightColor: accentColor.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isPrimary
                    ? VoworaColors.champagneGold.withValues(alpha: 0.18)
                    : VoworaColors.darkCardBackground.withValues(alpha: 0.8),
                border: Border.all(
                  color: accentColor.withValues(alpha: isPrimary ? 0.5 : 0.25),
                  width: isPrimary ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.playfairDisplay(
                            color: VoworaColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            color: VoworaColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
