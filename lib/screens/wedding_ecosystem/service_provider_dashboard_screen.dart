import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_ecosystem_models.dart';
import '../../providers/wedding_ecosystem_provider.dart';
import '../../routes/app_routes.dart';

class ServiceProviderDashboardScreen extends StatelessWidget {
  const ServiceProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeddingEcosystemProvider>(context);
    final requests = provider.bookingRequests;
    final pendingReqs = requests.where((b) => b.status == BookingRequestStatus.pending).toList();
    final acceptedReqs = requests.where((b) => b.status == BookingRequestStatus.accepted).toList();

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
        title: Text(
          '📸 Vendor Dashboard',
          style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Stat Metrics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard('New Requests', '${pendingReqs.length}', Icons.notifications_active_rounded, VoworaColors.champagneGold),
                  _buildStatCard('Upcoming Weddings', '${acceptedReqs.length}', Icons.event_available_rounded, const Color(0xFF6FCFB0)),
                  _buildStatCard('Completed Events', '24', Icons.task_alt_rounded, VoworaColors.dustyRose),
                  _buildStatCard('Total Earnings', '৳250k', Icons.payments_rounded, const Color(0xFF9B8FE0)),
                ],
              ),
              const SizedBox(height: 24),

              // Booking Requests Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('New Booking Requests', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${pendingReqs.length} Pending', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),

              if (pendingReqs.isEmpty)
                Text('No new pending booking requests.', style: GoogleFonts.plusJakartaSans(color: Colors.white54))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingReqs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final req = pendingReqs[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(req.clientName, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('৳${req.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.playfairDisplay(color: VoworaColors.champagneGold, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Event: ${req.weddingName} (${req.weddingId})', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 11)),
                          Text('📍 Venue: ${req.venueName} • 📅 Date: ${DateFormat('MMM dd, yyyy').format(req.weddingDate)}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => provider.acceptBookingRequest(req.id),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6FCFB0), foregroundColor: Colors.black),
                                  child: const Text('Accept Booking'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => provider.rejectBookingRequest(req.id),
                                style: OutlinedButton.styleFrom(foregroundColor: VoworaColors.error, side: const BorderSide(color: VoworaColors.error)),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Confirmed Events & Upload Photos to Wedding ID Tool
              Text('Confirmed Events & Photo Upload', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: acceptedReqs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final req = acceptedReqs[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF6FCFB0).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(req.weddingName, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFF6FCFB0).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                              child: Text('ACCEPTED ✓', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6FCFB0), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        Text('Wedding ID: ${req.weddingId} • Date: ${DateFormat('MMM dd, yyyy').format(req.weddingDate)}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 12),

                        // Action: Upload Event Photos
                        ElevatedButton.icon(
                          onPressed: () => _showUploadPhotosModal(context, provider, req.weddingId),
                          style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                          icon: const Icon(Icons.add_a_photo, size: 16),
                          label: const Text('Upload Event Photos'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(title, style: GoogleFonts.plusJakartaSans(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _showUploadPhotosModal(BuildContext context, WeddingEcosystemProvider provider, String weddingId) {
    final urlCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1519741497674-611481863552');
    String selectedAlbum = 'Ceremony';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181513),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Photos to $weddingId', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedAlbum,
                dropdownColor: const Color(0xFF181513),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Select Album'),
                items: ['Pre-Wedding', 'Ceremony', 'Couple', 'Family', 'Guests', 'Reception', 'Candid']
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedAlbum = val;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Photo Image URL', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (urlCtrl.text.trim().isNotEmpty) {
                      provider.uploadPhotoToWedding(
                        weddingId: weddingId,
                        albumName: selectedAlbum,
                        imageUrl: urlCtrl.text.trim(),
                        uploaderName: 'Dream Lens Studio (Vendor)',
                        uploaderRole: UserRole.serviceProvider,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Photo uploaded directly to $weddingId Gallery! 📸')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                  child: Text('Publish to Wedding Gallery', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
