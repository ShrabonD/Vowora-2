import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_booking_model.dart';
import '../../providers/wedding_wizard_provider.dart';

class GuestManagementStepView extends StatefulWidget {
  const GuestManagementStepView({super.key});

  @override
  State<GuestManagementStepView> createState() => _GuestManagementStepViewState();
}

class _GuestManagementStepViewState extends State<GuestManagementStepView> {
  String _searchQuery = '';
  String _statusFilter = 'All'; // All, Confirmed, Pending, Declined

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeddingWizardProvider>(context);
    final guests = provider.booking.guestsList;

    final confirmedCount =
        guests.where((g) => g.rsvpStatus == RSVPStatus.confirmed).length;
    final pendingCount =
        guests.where((g) => g.rsvpStatus == RSVPStatus.pending).length;
    final declinedCount =
        guests.where((g) => g.rsvpStatus == RSVPStatus.declined).length;

    final filteredGuests = guests.where((g) {
      if (_statusFilter == 'Confirmed' && g.rsvpStatus != RSVPStatus.confirmed) return false;
      if (_statusFilter == 'Pending' && g.rsvpStatus != RSVPStatus.pending) return false;
      if (_statusFilter == 'Declined' && g.rsvpStatus != RSVPStatus.declined) return false;
      if (_searchQuery.isNotEmpty &&
          !g.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !g.phone.contains(_searchQuery)) {
        return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 6: Guest Management 👥',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage invitations & RSVP statuses.',
            style: GoogleFonts.plusJakartaSans(
              color: VoworaColors.champagneGold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Guest Overview Metrics Row
          Row(
            children: [
              _buildMetricTile('Total', '${guests.length}', Colors.white),
              const SizedBox(width: 8),
              _buildMetricTile('Confirmed', '$confirmedCount', const Color(0xFF6FCFB0)),
              const SizedBox(width: 8),
              _buildMetricTile('Pending', '$pendingCount', VoworaColors.champagneGold),
              const SizedBox(width: 8),
              _buildMetricTile('Declined', '$declinedCount', VoworaColors.error),
            ],
          ),
          const SizedBox(height: 16),

          // Search & Action Buttons
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search guests...',
                    prefixIcon: const Icon(Icons.search_rounded, color: VoworaColors.champagneGold),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showAddGuestModal(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VoworaColors.champagneGold,
                  foregroundColor: const Color(0xFF141210),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Guest List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredGuests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final guest = filteredGuests[index];
              Color statusColor = VoworaColors.champagneGold;
              if (guest.rsvpStatus == RSVPStatus.confirmed) statusColor = const Color(0xFF6FCFB0);
              if (guest.rsvpStatus == RSVPStatus.declined) statusColor = VoworaColors.error;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: VoworaColors.champagneGold.withValues(alpha: 0.2),
                      child: Text(
                        guest.name.isNotEmpty ? guest.name[0].toUpperCase() : 'G',
                        style: GoogleFonts.playfairDisplay(
                          color: VoworaColors.champagneGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                guest.name,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  guest.rsvpStatus.name.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${guest.groupFamily} • ${guest.numberOfGuests} Guests • ${guest.phone}',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 18),
                      onPressed: () => provider.deleteGuest(guest.id),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                provider.setStep(7); // Continue to Photography
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VoworaColors.champagneGold,
                foregroundColor: const Color(0xFF141210),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: Text(
                'Continue to Photography',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: GoogleFonts.plusJakartaSans(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showAddGuestModal(BuildContext context, WeddingWizardProvider provider) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final groupCtrl = TextEditingController(text: 'Family');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181513),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Guest', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Guest Name', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      provider.addGuest(
                        WeddingGuestModel(
                          id: 'g_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          email: 'guest@example.com',
                          groupFamily: groupCtrl.text.trim(),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.champagneGold,
                    foregroundColor: const Color(0xFF141210),
                  ),
                  child: Text('Add Guest', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
