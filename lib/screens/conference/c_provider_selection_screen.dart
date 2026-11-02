import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'c_hall_explore_screen.dart';
// Import all other pages here
import 'c_food_page.dart';
import 'c_sound_page.dart';
import 'c_decoration_page.dart';
import 'c_photography_page.dart';
// import 'c_transport_page.dart'; // Add when ready
import 'c_transport_page.dart';

class ProviderSelectionScreen extends StatelessWidget {
  const ProviderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF8F1EA);
    const Color textColor = Color(0xFF3E2C26);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
        title: Text(
          'Choose Providers',
          style: GoogleFonts.playfairDisplay(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- HORIZONTAL PROGRESS BAR (Fits 6 items) ---
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: const Color(0xFFF0E6DD).withValues(alpha: 0.3),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildStep(1, 'Hall', true),
                  _buildLine(true),
                  _buildStep(2, 'Food', false),
                  _buildLine(false),
                  _buildStep(3, 'Sound', false),
                  _buildLine(false),
                  _buildStep(4, 'Decor', false),
                  _buildLine(false),
                  _buildStep(5, 'Photo', false),
                  _buildLine(false),
                  _buildStep(6, 'Trans.', false),
                  _buildProviderTile(
                    context,
                    'Transportation',
                    Icons.directions_car_filled_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConferenceTransportPage(),
                      ),
                    ), // Changed from SnackBar
                  ),
                ],
              ),
            ),

            // --- SKIP BUTTON ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step 1 of 6: Halls',
                    style: GoogleFonts.plusJakartaSans(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Go to next provider (Food)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConferenceFoodPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Skip >',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFB88A68),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFEADBC8), height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  Text(
                    'Choose best Providers of your city',
                    style: GoogleFonts.playfairDisplay(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildProviderTile(
                    context,
                    'Halls -> Explore and Book',
                    Icons.roofing_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HallExploreScreen(),
                      ),
                    ),
                  ),
                  _buildProviderTile(
                    context,
                    'Restaurant and Food',
                    Icons.restaurant_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConferenceFoodPage(),
                      ),
                    ),
                  ),
                  _buildProviderTile(
                    context,
                    'Sounds and Screens',
                    Icons.volume_up_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConferenceSoundPage(),
                      ),
                    ),
                  ),
                  _buildProviderTile(
                    context,
                    'Decorations',
                    Icons.local_florist_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConferenceDecorationPage(),
                      ),
                    ),
                  ),
                  _buildProviderTile(
                    context,
                    'Photography',
                    Icons.camera_alt_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConferencePhotographyPage(),
                      ),
                    ),
                  ),
                  _buildProviderTile(
                    context,
                    'Transportation',
                    Icons.directions_car_filled_rounded,
                    onTap: () {
                      // Add Transport Page later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transportation Coming Soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step, String title, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive
              ? const Color(0xFFB88A68)
              : const Color(0xFFEADBC8),
          child: Text(
            '$step',
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF8A7A75),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFFB88A68) : const Color(0xFF8A7A75),
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      color: isActive ? const Color(0xFFB88A68) : const Color(0xFFEADBC8),
    );
  }

  Widget _buildProviderTile(
    BuildContext context,
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0E6DD)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFB88A68), size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF3E2C26),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF8A7A75)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
