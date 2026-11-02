import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/conference/conference_seed_data.dart';
import 'c_others/booking_bottom_sheet.dart';

class ConferencePhotographyPage extends StatelessWidget {
  const ConferencePhotographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(backgroundColor: const Color(0xFFF8F1EA), elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF3E2C26)), title: Text('Photography', style: GoogleFonts.playfairDisplay(color: const Color(0xFF3E2C26), fontWeight: FontWeight.bold)), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: ConferenceSeedData.photography.length,
        itemBuilder: (context, index) {
          final photo = ConferenceSeedData.photography[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Material(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotographyDetailsScreen(photo: photo))),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF0E6DD))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(photo['image'], height: 160, width: double.infinity, fit: BoxFit.cover)),
                      Padding(padding: const EdgeInsets.all(16.0), child: Text(photo['name'], style: GoogleFonts.playfairDisplay(color: const Color(0xFF3E2C26), fontSize: 18, fontWeight: FontWeight.bold))),
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

class PhotographyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> photo;
  const PhotographyDetailsScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    final packs = photo['packs'] as List;
    final basePrice = packs.isNotEmpty ? packs.first['price'].toString() : '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(backgroundColor: const Color(0xFFF8F1EA), elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF3E2C26))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(photo['image'], height: 250, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(photo['name'], style: GoogleFonts.playfairDisplay(color: const Color(0xFF3E2C26), fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  ...packs.map((pack) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF0E6DD))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pack['name'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF3E2C26))),
                              Text(pack['details'], style: GoogleFonts.plusJakartaSans(color: const Color(0xFF8A7A75), fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('${pack['price']} BDT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFFB88A68))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () => showBookingSheet(context, photo['name'], basePrice),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3E2C26), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Text('Book Now', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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