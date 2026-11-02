import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/conference/conference_seed_data.dart';
import 'c_others/booking_bottom_sheet.dart'; // Correct path based on your folder structure

class ConferenceFoodPage extends StatelessWidget {
  const ConferenceFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1EA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3E2C26)),
        title: Text(
          'Restaurant & Food',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF3E2C26),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: ConferenceSeedData.foods.length,
        itemBuilder: (context, index) {
          final food = ConferenceSeedData.foods[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodDetailsScreen(food: food),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF0E6DD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          food['image'],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food['name'],
                              style: GoogleFonts.playfairDisplay(
                                color: const Color(0xFF3E2C26),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Color(0xFF8A7A75),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  food['location'],
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF8A7A75),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FoodDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> food;
  const FoodDetailsScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    // Determine a rough price for the booking sheet (e.g., base menu price)
    final menuKeys = (food['packages'] as Map<String, dynamic>).keys.toList();
    final firstMenuItems = food['packages'][menuKeys.first] as List;
    final basePrice = firstMenuItems.isNotEmpty
        ? firstMenuItems.first['price'].toString()
        : '0';

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
              food['image'],
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
                    food['name'],
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFF3E2C26),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    food['location'],
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF8A7A75),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Menu Packages',
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFF3E2C26),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...((food['packages'] as Map<String, dynamic>).entries.map((
                    entry,
                  ) {
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color(0xFFF0E6DD)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          entry.key.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB88A68),
                          ),
                        ),
                        children: (entry.value as List)
                            .map(
                              (item) => ListTile(
                                title: Text(
                                  item['name'],
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF3E2C26),
                                  ),
                                ),
                                trailing: Text(
                                  '${item['price']} BDT',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    );
                  }).toList()),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => showBookingSheet(
                        context,
                        food['name'],
                        "Starting from $basePrice",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E2C26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
}
