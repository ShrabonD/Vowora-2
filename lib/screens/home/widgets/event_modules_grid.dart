import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/vowora_theme.dart';
import '../../../providers/wedding_wizard_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/vowora_cached_image.dart';

class EventModulesGrid extends StatelessWidget {
  final BoxConstraints constraints;

  const EventModulesGrid({super.key, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event Categories',
              style: GoogleFonts.playfairDisplay(
                color: VoworaColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: VoworaColors.champagneGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
              ),
              child: Text(
                '6 Categories',
                style: GoogleFonts.plusJakartaSans(
                  color: VoworaColors.champagneGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.94,
          children: [
            // 1. Wedding
            GlassEventCategoryCard(
              title: 'Wedding',
              subtitle: 'Bespoke ceremony',
              icon: Icons.favorite_rounded,
              accentColor: VoworaColors.champagneGold,
              route: AppRoutes.weddingManager,
              bgImageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552',
              onCustomTap: () {
                final provider = Provider.of<WeddingWizardProvider>(context, listen: false);
                if (provider.booking.isConfirmed) {
                  Navigator.pushNamed(context, AppRoutes.weddingDashboard);
                } else {
                  Navigator.pushNamed(context, AppRoutes.weddingManager);
                }
              },
            ),
            // 2. Birthday
            GlassEventCategoryCard(
              title: 'Birthday',
              subtitle: 'Milestone parties',
              icon: Icons.cake_rounded,
              accentColor: VoworaColors.mutedRoseGold,
              route: AppRoutes.birthdayStudio,
              bgImageUrl: 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d',
            ),
            // 3. Anniversary
            GlassEventCategoryCard(
              title: 'Anniversary',
              subtitle: 'Celebrating love',
              icon: Icons.celebration_rounded,
              accentColor: VoworaColors.softIvory,
              route: AppRoutes.weddingSetup,
              bgImageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622',
            ),
            // 4. Gatherings
            GlassEventCategoryCard(
              title: 'Gatherings',
              subtitle: 'Private galas',
              icon: Icons.groups_rounded,
              accentColor: const Color(0xFF6FCFB0),
              route: AppRoutes.weddingSetup,
              bgImageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
            ),
            // 5. Conference
            GlassEventCategoryCard(
              title: 'Conference',
              subtitle: 'Corporate summits',
              icon: Icons.business_center_rounded,
              accentColor: const Color(0xFF9B8FE0),
              route: AppRoutes.cLandingPage,
              bgImageUrl: 'assets/conference/c_logo.png',
              isAsset: true,
            ),
            // 6. Custom Event
            GlassEventCategoryCard(
              title: 'Custom Event',
              subtitle: 'Tailored luxury',
              icon: Icons.dashboard_customize_rounded,
              accentColor: const Color(0xFF5EC8C4),
              route: AppRoutes.weddingSetup,
              bgImageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3',
            ),
          ],
        ),
      ],
    );
  }
}

class GlassEventCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String route;
  final String bgImageUrl;
  final bool isAsset;
  final VoidCallback? onCustomTap;

  const GlassEventCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.route,
    required this.bgImageUrl,
    this.isAsset = false,
    this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onCustomTap ?? () => Navigator.pushNamed(context, route),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                // Pure frosted glass look with see-through blurred background
                color: Colors.black.withValues(alpha: 0.42),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    accentColor.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.45),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Category Icon & Arrow Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.45),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(icon, color: accentColor, size: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 9,
                          color: VoworaColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Center: Beautiful Centered Circular Image (~58px diameter) with gold ring
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: VoworaColors.champagneGold.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: VoworaCachedImage(
                        imageUrl: bgImageUrl,
                        contextSize: ImageContextSize.thumbnail,
                        fit: BoxFit.cover,
                        width: 58,
                        height: 58,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Bottom: Category Name & Subtitle
                  Column(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.playfairDisplay(
                          color: VoworaColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: VoworaColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
