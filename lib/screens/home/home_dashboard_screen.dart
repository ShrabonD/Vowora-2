import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wedding_ecosystem_provider.dart';
import '../../providers/wedding_provider.dart';
import '../../providers/wedding_wizard_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/guest_gate_dialog.dart';
import '../../widgets/vowora_cached_image.dart';
import 'widgets/event_countdown_card.dart';
import 'widgets/event_modules_grid.dart';
import 'widgets/inspiration_callout_banner.dart';
import 'widgets/quick_actions_section.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VoworaImagePreloader.preloadImages(context, const [
        'https://images.unsplash.com/photo-1519741497674-611481863552',
        'https://images.unsplash.com/photo-1530103862676-de8c9debad1d',
        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622',
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
        'assets/conference/c_logo.png',
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3',
      ]);
    });
  }

  void _showNotificationsCenterModal(BuildContext context) {
    final ecosystemProvider = Provider.of<WeddingEcosystemProvider>(context, listen: false);
    final wizardProvider = Provider.of<WeddingWizardProvider>(context, listen: false);
    final booking = wizardProvider.booking;

    final clientNotifications = ecosystemProvider.clientNotifications;
    final daysLeft = booking.daysUntilWedding;

    final allNotifications = [
      if (booking.brideName.isNotEmpty && booking.isConfirmed)
        WeddingNotificationModel(
          id: 'n_countdown',
          title: 'Ceremony Countdown 💍',
          message: '${booking.brideName} & ${booking.groomName} wedding is in $daysLeft days!',
          time: DateTime.now(),
          icon: Icons.favorite_rounded,
        ),
      ...clientNotifications,
      WeddingNotificationModel(
        id: 'n_welcome',
        title: 'Welcome to Vowora ✨',
        message: 'Explore luxury wedding packages, catering, decor & guest management.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.auto_awesome,
      ),
      WeddingNotificationModel(
        id: 'n_security',
        title: 'Security Preference Active 🔐',
        message: 'Two-Step Verification (TOTP MFA) is available to protect your events.',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        icon: Icons.security_rounded,
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VoworaColors.darkCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: VoworaColors.champagneGold, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Notifications Center 🔔',
                        style: GoogleFonts.playfairDisplay(
                          color: VoworaColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: VoworaColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 340,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: allNotifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = allNotifications[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: VoworaColors.champagneGold.withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon, color: VoworaColors.champagneGold, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.message,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 11.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.champagneGold,
                    foregroundColor: VoworaColors.darkBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    'Close Notifications',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final weddingProvider = Provider.of<WeddingProvider>(context);

    final userName = authProvider.userProfile?.fullName.split(' ').first ?? 'Planner';
    final activeEvent = weddingProvider.weddingProfile;
    final greeting = _getDynamicGreeting();

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),
        ),
        title: Row(
          children: [
            // Profile Avatar with Gold Border
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: VoworaColors.champagneGold, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: VoworaColors.darkCardBackground,
                  backgroundImage: authProvider.userProfile?.avatarUrl != null &&
                          authProvider.userProfile!.avatarUrl!.isNotEmpty
                      ? NetworkImage(authProvider.userProfile!.avatarUrl!) as ImageProvider
                      : null,
                  child: authProvider.userProfile?.avatarUrl == null ||
                          authProvider.userProfile!.avatarUrl!.isEmpty
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                          style: GoogleFonts.playfairDisplay(
                            color: VoworaColors.champagneGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $userName ♡',
                    style: GoogleFonts.playfairDisplay(
                      color: VoworaColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Let's curate your extraordinary celebration.",
                    style: GoogleFonts.plusJakartaSans(
                      color: VoworaColors.textSecondary,
                      fontSize: 10.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (authProvider.isGuest)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ActionChip(
                backgroundColor: VoworaColors.champagneGold.withValues(alpha: 0.2),
                side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.45)),
                label: Text(
                  'Guest Mode',
                  style: GoogleFonts.plusJakartaSans(
                    color: VoworaColors.champagneGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                  ),
                ),
                onPressed: () {
                  GuestGateDialog.show(
                    context,
                    onCreateAccount: () => Navigator.pushNamed(context, AppRoutes.signup),
                  );
                },
              ),
            ),
          // Notification Icon with Unread Badge Indicator
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: VoworaColors.textPrimary, size: 22),
                onPressed: () => _showNotificationsCenterModal(context),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: VoworaColors.champagneGold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Luxury Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/wedding_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Sophisticated Dark Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Scrollable Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth > 600 ? 32 : 20,
                    vertical: 16,
                  ).copyWith(bottom: 110 + MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // A. Featured Event — Hero Section (Countdown Card)
                      RepaintBoundary(child: EventCountdownCard(activeEvent: activeEvent)),
                      const SizedBox(height: 24),

                      // C. Quick Action Section
                      const RepaintBoundary(child: QuickActionsSection()),
                      const SizedBox(height: 28),

                      // D. Event Categories — Main Feature
                      RepaintBoundary(child: EventModulesGrid(constraints: constraints)),
                      const SizedBox(height: 28),

                      // E. Explore Event Inspirations
                      const RepaintBoundary(child: InspirationCalloutBanner()),
                      const SizedBox(height: 100), // Bottom padding for floating nav bar
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // F. Premium Floating Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, 12 + MediaQuery.of(context).padding.bottom),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Home', () {
                    setState(() => _currentIndex = 0);
                  }),
                  _buildNavItem(1, Icons.explore_rounded, 'Explore', () {
                    setState(() => _currentIndex = 1);
                    Navigator.pushNamed(context, AppRoutes.inspiration);
                  }),
                  _buildNavItem(2, Icons.event_available_rounded, 'My Events', () {
                    setState(() => _currentIndex = 2);
                    Navigator.pushNamed(context, AppRoutes.myEvents);
                  }),
                  _buildNavItem(3, Icons.person_rounded, 'Profile', () {
                    setState(() => _currentIndex = 3);
                    Navigator.pushNamed(context, AppRoutes.profile);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, VoidCallback onTap) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? VoworaColors.champagneGold.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? VoworaColors.champagneGold.withValues(alpha: 0.5) : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? VoworaColors.champagneGold : VoworaColors.textSecondary,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: VoworaColors.champagneGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
