import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/vowora_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/conference_booking_service.dart';
import '../../conference/conference_events_section.dart';

class MyEventsSection extends StatelessWidget {
  const MyEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userProfile;
    final categories = [
      _EventCategory(
        title: 'Conference',
        category: 'conference',
        icon: Icons.business_center,
        color: const Color(0xFF9B8FE0),
      ),
      _EventCategory(
        title: 'Wedding',
        category: 'wedding',
        icon: Icons.favorite,
        color: VoworaColors.dustyRose,
      ),
      _EventCategory(
        title: 'Gathering',
        category: 'gathering',
        icon: Icons.groups,
        color: const Color(0xFF6FCFB0),
      ),
      _EventCategory(
        title: 'Birthday',
        category: 'birthday',
        icon: Icons.cake,
        color: VoworaColors.champagneGold,
      ),
    ];

    return Card(
      color: VoworaColors.darkCardBackground.withValues(alpha: 0.94),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: VoworaColors.champagneGold.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Events',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.7,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _EventCategoryTile(
                  category: category,
                  onTap: () {
                    if (category.category == 'conference') {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const _ConferenceCategoriesScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => _ConferenceBookingsListScreen(
                            category: category.category,
                            email: user?.email ?? '',
                            title: category.title,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCategory {
  const _EventCategory({
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
  });

  final String title;
  final String category;
  final IconData icon;
  final Color color;
}

class _EventCategoryTile extends StatelessWidget {
  const _EventCategoryTile({required this.category, required this.onTap});

  final _EventCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: category.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: category.color.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(category.icon, color: category.color, size: 24),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  category.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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

class _ConferenceCategoriesScreen extends StatelessWidget {
  const _ConferenceCategoriesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        title: const Text('Conference Bookings'),
        backgroundColor: VoworaColors.darkBackground,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [ConferenceEventsSection()],
      ),
    );
  }
}

class _ConferenceBookingsListScreen extends StatelessWidget {
  const _ConferenceBookingsListScreen({
    required this.category,
    required this.email,
    required this.title,
  });

  final String category;
  final String email;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: VoworaColors.darkBackground,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ConferenceBookingService.getUserBookings(email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load bookings: ${snapshot.error}',
                style: GoogleFonts.plusJakartaSans(color: VoworaColors.error),
              ),
            );
          }

          final bookings = (snapshot.data ?? const <Map<String, dynamic>>[])
              .where((booking) => booking['category'] == category)
              .toList();
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                'No bookings yet',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final name =
                  booking['hall_name'] ?? booking['service_name'] ?? title;
              final eventDate = booking['event_date']?.toString() ?? '';
              final status = booking['status']?.toString() ?? 'pending';
              return Card(
                color: VoworaColors.darkCardBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: VoworaColors.champagneGold.withValues(alpha: 0.25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name.toString(),
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(status),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: VoworaColors.champagneGold
                                .withValues(alpha: 0.18),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Event date: ${eventDate.isEmpty ? 'Not set' : eventDate}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
