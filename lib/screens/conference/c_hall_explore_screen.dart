import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/conference/conference_seed_data.dart';
import '../conference/c_others/booking_bottom_sheet.dart';

class HallExploreScreen extends StatelessWidget {
  const HallExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (Keep your existing ListView and Card code here) ...
    // (If you need the full list code again, let me know, but I'm focusing on the Detail Page fix)

    // For brevity, assuming you have the ListView builder here.
    return Scaffold(
      body: ListView.builder(
        itemCount: ConferenceSeedData.halls.length,
        itemBuilder: (context, index) {
          final hall = ConferenceSeedData.halls[index];
          return ListTile(
            title: Text(hall['name']),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HallDetailsScreen(hall: hall)),
            ),
          );
        },
      ),
    );
  }
}

// --- HALL DETAILS PAGE (FIXED OVERFLOW) ---
class HallDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> hall;
  const HallDetailsScreen({super.key, required this.hall});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1EA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3E2C26)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              hall['image'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hall['name'],
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFF3E2C26),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 ${hall['location']}',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF8A7A75),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Amenities',
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFF3E2C26),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hall['ac']) _chip('AC'),
                      if (hall['wifi']) _chip('WiFi'),
                      if (hall['parking']) _chip('Parking'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- FIXED OVERFLOW BOTTOM CARD ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0E6DD)),
                    ),
                    child: Row(
                      children: [
                        // Flexible ensures text doesn't push the button off screen
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Price',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF8A7A75),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${hall['price_per_day']} BDT',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFB88A68),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // Prevents text overflow
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Opens the Bottom Sheet correctly
                            showBookingSheet(
                              context,
                              hall['name'],
                              hall['price_per_day'].toString(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E2C26),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6DD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF3E2C26),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
