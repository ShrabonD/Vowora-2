import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/vowora_theme.dart';
import '../../../models/wedding_profile.dart';
import '../../../providers/wedding_wizard_provider.dart';
import '../../../routes/app_routes.dart';

class EventCountdownCard extends StatefulWidget {
  final WeddingProfile? activeEvent;

  const EventCountdownCard({super.key, this.activeEvent});

  @override
  State<EventCountdownCard> createState() => _EventCountdownCardState();
}

class _EventCountdownCardState extends State<EventCountdownCard> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wizardProvider = Provider.of<WeddingWizardProvider>(context);
    final booking = wizardProvider.booking;

    final bool hasUserCreatedWedding = booking.brideName.trim().isNotEmpty && booking.isConfirmed;

    if (!hasUserCreatedWedding) {
      // ===== LUXURY NEW USER WELCOME HERO CARD =====
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
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
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: VoworaColors.champagneGold.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      VoworaColors.champagneGold.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: VoworaColors.champagneGold, size: 16),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "LUXURY EVENT EXPERIENCE",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: VoworaColors.champagneGold,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: VoworaColors.champagneGold.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'Ready to Plan',
                            style: GoogleFonts.plusJakartaSans(
                              color: VoworaColors.champagneGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Curate Your Dream Celebration ♡',
                      style: GoogleFonts.playfairDisplay(
                        color: VoworaColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Begin your journey with our bespoke 9-step wedding planner or explore our curated luxury event categories below.',
                      style: GoogleFonts.plusJakartaSans(
                        color: VoworaColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              wizardProvider.startNewBookingWizard();
                              Navigator.pushNamed(context, AppRoutes.weddingManager);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VoworaColors.champagneGold,
                              foregroundColor: VoworaColors.darkBackground,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            icon: const Icon(Icons.favorite_rounded, size: 18),
                            label: Text(
                              'Create Your Event',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ===== LUXURY ACTIVE EVENT COUNTDOWN HERO CARD =====
    final days = booking.daysUntilWedding;
    final formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(booking.weddingDate);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
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
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.70),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${booking.brideName} & ${booking.groomName}',
                          style: GoogleFonts.playfairDisplay(
                            color: VoworaColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.45)),
                        ),
                        child: Text(
                          booking.weddingId,
                          style: GoogleFonts.plusJakartaSans(
                            color: VoworaColors.champagneGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        days > 0 ? '$days' : '0',
                        style: GoogleFonts.playfairDisplay(
                          color: VoworaColors.textPrimary,
                          fontSize: 58,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Text(
                          days == 1 ? 'Day Until The\nGrand Celebration' : 'Days Until The\nGrand Celebration',
                          style: GoogleFonts.playfairDisplay(
                            color: VoworaColors.champagneGold,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withValues(alpha: 0.15)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 15, color: VoworaColors.champagneGold),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                formattedDate,
                                style: GoogleFonts.plusJakartaSans(
                                  color: VoworaColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 15, color: VoworaColors.champagneGold),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                booking.selectedVenue?.name ?? 'Venue Selected',
                                style: GoogleFonts.plusJakartaSans(
                                  color: VoworaColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.weddingDashboard),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VoworaColors.champagneGold,
                        side: const BorderSide(color: VoworaColors.champagneGold, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.visibility_rounded, size: 16),
                      label: Text(
                        'View Event Details',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
