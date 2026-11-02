import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/conference/conference_seed_data.dart';
import 'c_others/booking_bottom_sheet.dart';

class ConferenceTransportPage extends StatelessWidget {
  const ConferenceTransportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(backgroundColor: const Color(0xFFF8F1EA), elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF3E2C26)), title: Text('Transportation', style: GoogleFonts.playfairDisplay(color: const Color(0xFF3E2C26), fontWeight: FontWeight.bold)), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: ConferenceSeedData.transport.length,
        itemBuilder: (context, index) {
          final transport = ConferenceSeedData.transport[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Material(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransportDetailsScreen(transport: transport))),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF0E6DD))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(transport['image'], height: 160, width: double.infinity, fit: BoxFit.cover)),
                      Padding(padding: const EdgeInsets.all(16.0), child: Text(transport['name'], style: GoogleFonts.playfairDisplay(color: const Color(0xFF3E2C26), fontSize: 18, fontWeight: FontWeight.bold))),
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

class TransportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> transport;
  const TransportDetailsScreen({super.key, required this.transport});

  @override
  Widget build(BuildContext context) {
    final cars = transport['cars'] as List;
    final basePrice = cars.isNotEmpty ? cars.first['price_per_day'].toString() : '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(backgroundColor: const Color(0xFFF8F1EA), elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF3E2C26))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(transport['image'], height: 250, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transport['name'], style: GoogleFonts.playfairDisplay(color: const Color(0xFF3E2C26), fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Text('Available Vehicles', style: GoogleFonts.playfairDisplay(color: const Color(0xFF3E2C26), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...cars.map((car) => Container(
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
                              Text(car['name'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF3E2C26))),
                              Text('Capacity: ${car['capacity']} persons', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF8A7A75), fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('${car['price_per_day']} BDT/day', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFFB88A68))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () => showBookingSheet(context, transport['name'], basePrice),
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