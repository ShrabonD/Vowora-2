import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/birthday_provider.dart';
import '../../providers/wedding_provider.dart';
import '../../providers/wedding_wizard_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/conference_booking_service.dart';
import '../../widgets/vowora_button.dart';

class MyEventsScreen extends StatefulWidget {
  final bool showAppBar;
  const MyEventsScreen({super.key, this.showAppBar = true});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  String _selectedCategory = 'All'; // 'All', 'Wedding', 'Birthday', 'Conference'

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

  void _showCreateEventModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: VoworaColors.darkCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Celebration 🎉',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select the category of celebration you want to plan.',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              _buildCreateOptionTile(
                icon: Icons.favorite_rounded,
                color: VoworaColors.champagneGold,
                title: 'Wedding Celebration 💍',
                subtitle: 'Plan venue, catering, decor & guest invitations',
                onTap: () {
                  Navigator.pop(context);
                  final wizardProvider = Provider.of<WeddingWizardProvider>(context, listen: false);
                  wizardProvider.startNewBookingWizard();
                  Navigator.pushNamed(context, AppRoutes.weddingManager);
                },
              ),
              const SizedBox(height: 10),
              _buildCreateOptionTile(
                icon: Icons.cake_rounded,
                color: VoworaColors.dustyRose,
                title: 'Birthday Party 🎂',
                subtitle: 'Cake studio, theme designer & memory vault',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.birthdayStudio);
                },
              ),
              const SizedBox(height: 10),
              _buildCreateOptionTile(
                icon: Icons.business_center_rounded,
                color: const Color(0xFF9B8FE0),
                title: 'Conference & Corporate Event 💼',
                subtitle: 'Book convention halls, sound & transportation',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.conferenceCreate);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final wizardProvider = Provider.of<WeddingWizardProvider>(context);
    final birthdayProvider = Provider.of<BirthdayProvider>(context);
    final user = authProvider.userProfile;
    final booking = wizardProvider.booking;

    final hasWedding = booking.isConfirmed && booking.brideName.trim().isNotEmpty;
    final hasBirthday = birthdayProvider.event.hostName.isNotEmpty;

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: widget.showAppBar
          ? AppBar(
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
                'My Celebrations',
                style: GoogleFonts.playfairDisplay(
                  color: VoworaColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: VoworaColors.champagneGold, size: 24),
                  tooltip: 'Create Event',
                  onPressed: () => _showCreateEventModal(context),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
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
                  Text(
                    'Manage & track your curated events.',
                    style: GoogleFonts.plusJakartaSans(
                      color: VoworaColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Events', _selectedCategory == 'All', () => setState(() => _selectedCategory = 'All')),
                        _buildFilterChip('Weddings 💍', _selectedCategory == 'Wedding', () => setState(() => _selectedCategory = 'Wedding')),
                        _buildFilterChip('Birthdays 🎂', _selectedCategory == 'Birthday', () => setState(() => _selectedCategory = 'Birthday')),
                        _buildFilterChip('Conferences 💼', _selectedCategory == 'Conference', () => setState(() => _selectedCategory = 'Conference')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Wedding Card Section
                  if ((_selectedCategory == 'All' || _selectedCategory == 'Wedding')) ...[
                    if (hasWedding) ...[
                      _buildWeddingCard(context, booking),
                      const SizedBox(height: 18),
                    ] else if (_selectedCategory == 'Wedding') ...[
                      _buildCategoryEmptyState(
                        title: 'No Wedding Event Found 💍',
                        subtitle: 'Plan your dream wedding with luxury venues, catering, decor & custom invitations.',
                        buttonText: '+ Create Wedding Event',
                        onTap: () {
                          wizardProvider.startNewBookingWizard();
                          Navigator.pushNamed(context, AppRoutes.weddingManager);
                        },
                      ),
                    ],
                  ],

                  // Birthday Card Section
                  if ((_selectedCategory == 'All' || _selectedCategory == 'Birthday')) ...[
                    if (hasBirthday) ...[
                      _buildBirthdayCard(context, birthdayProvider),
                      const SizedBox(height: 18),
                    ] else if (_selectedCategory == 'Birthday') ...[
                      _buildCategoryEmptyState(
                        title: 'No Birthday Event Found 🎂',
                        subtitle: 'Design custom cakes, themes, guest lists and memory vaults for birthdays.',
                        buttonText: '+ Create Birthday Party',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.birthdayStudio),
                      ),
                    ],
                  ],

                  // Conference Bookings Section
                  if (_selectedCategory == 'All' || _selectedCategory == 'Conference') ...[
                    _buildConferenceSection(context, user?.email ?? ''),
                  ],

                  // Global Empty State if user has no events at all
                  if (_selectedCategory == 'All' && !hasWedding && !hasBirthday) ...[
                    _buildCategoryEmptyState(
                      title: 'No Celebrations Created Yet ✨',
                      subtitle: 'Start curating your extraordinary wedding, birthday party, or conference event.',
                      buttonText: '+ Create New Event',
                      onTap: () => _showCreateEventModal(context),
                    ),
                  ],

                  const SizedBox(height: 100), // Bottom padding for floating navigation bar
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: VoworaColors.champagneGold,
        foregroundColor: VoworaColors.darkBackground,
        onPressed: () => _showCreateEventModal(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('Create Event', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? VoworaColors.champagneGold
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? VoworaColors.champagneGold
                  : Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? VoworaColors.darkBackground : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeddingCard(BuildContext context, WeddingBookingModel booking) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: VoworaColors.darkCardBackground.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: VoworaColors.champagneGold.withValues(alpha: 0.4),
              width: 1.2,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: VoworaColors.champagneGold, size: 13),
                        const SizedBox(width: 5),
                        Text('WEDDING CELEBRATION', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: booking.weddingId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Secret Code "${booking.weddingId}" copied to clipboard!', style: GoogleFonts.plusJakartaSans()),
                          backgroundColor: VoworaColors.darkCardBackground,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Text('Code: ${booking.weddingId}', style: GoogleFonts.firaCode(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy_rounded, color: VoworaColors.champagneGold, size: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${booking.brideName} & ${booking.groomName}',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: VoworaColors.textSecondary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${booking.weddingDate.day}/${booking.weddingDate.month}/${booking.weddingDate.year} • ${booking.daysUntilWedding} Days Remaining',
                    style: GoogleFonts.plusJakartaSans(color: VoworaColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: VoworaColors.textSecondary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    booking.selectedVenue?.name ?? 'Venue Selected',
                    style: GoogleFonts.plusJakartaSans(color: VoworaColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.weddingDashboard),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VoworaColors.champagneGold,
                        foregroundColor: VoworaColors.darkBackground,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.dashboard_rounded, size: 16),
                      label: Text('Open Dashboard', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.weddingManager),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.5), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: Text('Steps', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdayCard(BuildContext context, BirthdayProvider provider) {
    final event = provider.event;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: VoworaColors.darkCardBackground.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: VoworaColors.dustyRose.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: VoworaColors.dustyRose.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: VoworaColors.dustyRose.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cake_rounded, color: VoworaColors.dustyRose, size: 13),
                    const SizedBox(width: 5),
                    Text('BIRTHDAY CELEBRATION', style: GoogleFonts.plusJakartaSans(color: VoworaColors.dustyRose, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${event.hostName}\'s Birthday Bash 🎂',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Theme: ${event.selectedThemeName.isEmpty ? 'Luxury Studio' : event.selectedThemeName}',
                style: GoogleFonts.plusJakartaSans(color: VoworaColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.birthdayStudio),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.dustyRose,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.cake_outlined, size: 16),
                  label: Text('Open Birthday Studio', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConferenceSection(BuildContext context, String userEmail) {
    if (userEmail.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ConferenceBookingService.getUserBookings(userEmail),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final bookings = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CONFERENCE HALL BOOKINGS', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final b = bookings[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: VoworaColors.darkCardBackground.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF9B8FE0).withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.business_center_rounded, color: Color(0xFF9B8FE0), size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b['hall_name'] ?? b['service_name'] ?? 'Conference Event',
                              style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text('Date: ${b['event_date'] ?? 'Upcoming'} • Status: ${b['status'] ?? 'Confirmed'}', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
          ],
        );
      },
    );
  }

  Widget _buildCategoryEmptyState({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: VoworaColors.darkCardBackground.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_available_rounded, color: VoworaColors.champagneGold, size: 36),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.champagneGold,
                    foregroundColor: VoworaColors.darkBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(buttonText, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
