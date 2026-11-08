import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/vowora_constants.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_ecosystem_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wedding_ecosystem_provider.dart';
import '../../providers/wedding_provider.dart';
import '../../providers/wedding_wizard_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/support_card.dart';
import '../../widgets/vowora_cached_image.dart';
import '../conference/conference_events_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _localAvatarPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final wizardProvider = Provider.of<WeddingWizardProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.userProfile != null) {
        wizardProvider.loadUserWeddingFromSupabase(authProvider.userProfile!.id);
      }
    });
  }

  Future<void> _pickAvatarImage(AuthProvider authProvider) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _localAvatarPath = image.path;
        });
        await authProvider.uploadAvatar(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully! 📸'),
              backgroundColor: VoworaColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar selected locally: ${e.toString()}'),
            backgroundColor: VoworaColors.champagneGold,
          ),
        );
      }
    }
  }

  void _showEditProfileModal(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.userProfile;
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final locationCtrl = TextEditingController(text: user?.location ?? '');

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
                  Text(
                    'Edit Profile Details 👤',
                    style: GoogleFonts.playfairDisplay(
                      color: VoworaColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: VoworaColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Location / City',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.updateProfile(
                      fullName: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      location: locationCtrl.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully! ✨'),
                          backgroundColor: VoworaColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.champagneGold,
                    foregroundColor: VoworaColors.darkBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    'Save Profile Changes',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VoworaColors.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: VoworaColors.champagneGold),
            const SizedBox(width: 8),
            Text(
              'Sign Out?',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of Vowora?',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final wizardProvider = Provider.of<WeddingWizardProvider>(context, listen: false);
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              authProvider.logout();
              wizardProvider.resetForNewUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VoworaColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Sign Out', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final wizardProvider = Provider.of<WeddingWizardProvider>(context);
    final ecosystemProvider = Provider.of<WeddingEcosystemProvider>(context);
    final weddingProvider = Provider.of<WeddingProvider>(context);

    final user = authProvider.userProfile;
    final booking = wizardProvider.booking;
    final activeRole = ecosystemProvider.activeRole;
    final isGuest = authProvider.isGuest;

    final eventsCreatedCount = booking.isConfirmed && booking.brideName.isNotEmpty ? 1 : 0;
    final upcomingEventsCount = booking.isConfirmed && booking.daysUntilWedding >= 0 ? 1 : 0;
    final savedInspirationsCount = weddingProvider.inspirationItems.where((i) => i.isFavorite).length;

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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
        title: Text(
          'My Profile 👤',
          style: GoogleFonts.playfairDisplay(
            color: VoworaColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: VoworaColors.champagneGold, size: 22),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          const SizedBox(width: 8),
        ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Premium Profile Header Card (Glassmorphic)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
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
                          children: [
                            GestureDetector(
                              onTap: () => isGuest ? null : _pickAvatarImage(authProvider),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 92,
                                    height: 92,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: VoworaColors.champagneGold, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: VoworaColors.champagneGold.withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: isGuest
                                          ? const Icon(Icons.person_rounded, size: 52, color: VoworaColors.champagneGold)
                                          : _buildAvatarImage(user?.avatarUrl),
                                    ),
                                  ),
                                  if (!isGuest)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: VoworaColors.champagneGold,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt_rounded, color: VoworaColors.darkBackground, size: 16),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isGuest
                                  ? 'Guest User'
                                  : (user?.fullName.isNotEmpty == true ? user!.fullName : 'Wedding Planner'),
                              style: GoogleFonts.playfairDisplay(
                                color: VoworaColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                isGuest ? '✨ Guest Exploration Mode' : '👑 ${_getRoleName(activeRole)}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: VoworaColors.champagneGold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isGuest ? 'Sign in to sync your wedding plans & bookings' : (user?.email ?? 'planner@vowora.app'),
                              style: GoogleFonts.plusJakartaSans(
                                color: VoworaColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (!isGuest && (user?.phone.isNotEmpty == true || user?.location.isNotEmpty == true))
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '📍 ${user?.location ?? 'Dhaka'} • 📞 ${user?.phone ?? ''}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: VoworaColors.champagneGold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            if (isGuest)
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VoworaColors.champagneGold,
                                  foregroundColor: VoworaColors.darkBackground,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                icon: const Icon(Icons.login_rounded, size: 16),
                                label: Text('Sign In / Register', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.personalInformation),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: VoworaColors.champagneGold,
                                  side: const BorderSide(color: VoworaColors.champagneGold, width: 1.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 15),
                                label: Text('Edit Profile', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12.5)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Personal Event Dashboard Stats (3 Compact Glass Cards)
                  _sectionHeader('CELEBRATION STATISTICS'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Events Created', '$eventsCreatedCount', Icons.event_available_rounded, VoworaColors.champagneGold),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard('Upcoming', '$upcomingEventsCount', Icons.upcoming_rounded, VoworaColors.mutedRoseGold),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard('Saved Ideas', '$savedInspirationsCount', Icons.favorite_rounded, VoworaColors.softIvory),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Active Celebration Summary
                  _sectionHeader('ACTIVE CELEBRATION SUMMARY'),
                  const SizedBox(height: 10),
                  if (booking.isConfirmed && booking.brideName.trim().isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: VoworaColors.darkCardBackground.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.35)),
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
                                      style: GoogleFonts.playfairDisplay(color: VoworaColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      booking.weddingId,
                                      style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '📍 ${booking.selectedVenue?.name ?? 'Venue Selected'} • 📅 ${booking.daysUntilWedding} Days Remaining',
                                style: GoogleFonts.plusJakartaSans(color: VoworaColors.textSecondary, fontSize: 11.5),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.pushNamed(context, AppRoutes.weddingDashboard),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: VoworaColors.champagneGold,
                                        foregroundColor: VoworaColors.darkBackground,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      icon: const Icon(Icons.dashboard_rounded, size: 16),
                                      label: Text('Dashboard', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.joinWedding),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: VoworaColors.textPrimary,
                                      side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.5), width: 1.2),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                                    label: Text('Join Event', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: VoworaColors.darkCardBackground.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No Active Event Created Yet 💍', style: GoogleFonts.playfairDisplay(color: VoworaColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Start planning your dream celebration in 9 easy steps.', style: GoogleFonts.plusJakartaSans(color: VoworaColors.textSecondary, fontSize: 11.5)),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    wizardProvider.startNewBookingWizard();
                                    Navigator.pushNamed(context, AppRoutes.weddingManager);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: VoworaColors.champagneGold,
                                    foregroundColor: VoworaColors.darkBackground,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  ),
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                                  label: Text('+ Create Your Wedding', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 4. Quick Action Menu Rows
                  _sectionHeader('QUICK NAVIGATION & ACTIONS'),
                  const SizedBox(height: 10),

                  _settingMenuTile(
                    icon: Icons.storefront_rounded,
                    title: 'Vendor Marketplace & Bookings',
                    subtitle: 'Browse photographers, caterers & decorators',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.serviceProviderMarketplace),
                  ),
                  _settingMenuTile(
                    icon: Icons.photo_library_outlined,
                    title: 'Wedding Photo Gallery',
                    subtitle: 'View albums & manage guest moment uploads',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.weddingGallery),
                  ),
                  _settingMenuTile(
                    icon: Icons.access_time_filled_rounded,
                    title: 'Event Schedule & Timeline',
                    subtitle: 'View ceremony timeline milestones',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.weddingSchedule),
                  ),
                  _settingMenuTile(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Saved Inspirations',
                    subtitle: 'View your favorite bookmarked luxury ideas',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.inspiration),
                  ),
                  _settingMenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings & Preferences',
                    subtitle: 'Appearance, notifications & language',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                  ),
                  _settingMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & 24/7 Support Hotline',
                    subtitle: 'Get instant assistance for your event',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: VoworaColors.darkCardBackground,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (context) => const Padding(
                          padding: EdgeInsets.all(24),
                          child: SupportCard(isDark: true),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const ConferenceEventsSection(),
                  const SizedBox(height: 24),

                  // 5. Sign Out Button
                  _settingMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Log out of your Vowora account',
                    isDestructive: true,
                    onTap: () => _showLogoutDialog(context),
                  ),
                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      '${VoworaConstants.appName}  ·  v1.0.0 (Luxury Edition)',
                      style: GoogleFonts.plusJakartaSans(color: VoworaColors.textSecondary, fontSize: 11, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String? avatarUrl) {
    if (_localAvatarPath != null && _localAvatarPath!.isNotEmpty) {
      return Image.file(File(_localAvatarPath!), fit: BoxFit.cover);
    }
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      if (avatarUrl.startsWith('http')) {
        return VoworaCachedImage(
          imageUrl: avatarUrl,
          contextSize: ImageContextSize.thumbnail,
          fit: BoxFit.cover,
        );
      } else {
        return Image.file(File(avatarUrl), fit: BoxFit.cover);
      }
    }
    return const Icon(Icons.person_rounded, size: 52, color: VoworaColors.champagneGold);
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.bold,
        color: VoworaColors.champagneGold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color accentColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: VoworaColors.darkCardBackground.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.1),
          ),
          child: Column(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                  color: VoworaColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: VoworaColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? VoworaColors.error : VoworaColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: VoworaColors.darkCardBackground.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDestructive ? VoworaColors.error.withValues(alpha: 0.4) : VoworaColors.champagneGold.withValues(alpha: 0.25),
                width: 1.1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isDestructive ? VoworaColors.error.withValues(alpha: 0.2) : VoworaColors.champagneGold.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isDestructive ? VoworaColors.error : VoworaColors.champagneGold,
                  ),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: VoworaColors.textSecondary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: VoworaColors.textSecondary,
                ),
                onTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.client: return 'Client Host';
      case UserRole.guest: return 'Guest User';
      case UserRole.serviceProvider: return 'Service Provider';
      case UserRole.admin: return 'Administrator';
    }
  }
}
