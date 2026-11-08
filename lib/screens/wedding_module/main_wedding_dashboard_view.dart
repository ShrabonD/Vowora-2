import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/services/supabase_database_service.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_booking_model.dart';
import '../../models/wedding_ecosystem_models.dart';
import '../../providers/wedding_ecosystem_provider.dart';
import '../../providers/wedding_wizard_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vowora_payment_gateway_sheet.dart';

class MainWeddingDashboardView extends StatefulWidget {
  const MainWeddingDashboardView({super.key});

  @override
  State<MainWeddingDashboardView> createState() =>
      _MainWeddingDashboardViewState();
}

class _MainWeddingDashboardViewState extends State<MainWeddingDashboardView> {
  int _activeTab = 0; // 0: Overview, 1: Planning Modules, 2: Guests, 3: Budget, 4: Payments/More
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeddingWizardProvider>(context);
    final booking = provider.booking;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Wedding Dashboard 💍',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${booking.brideName} & ${booking.groomName}',
              style: GoogleFonts.plusJakartaSans(
                color: VoworaColors.champagneGold,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: VoworaColors.champagneGold),
            tooltip: 'Create New Wedding',
            onPressed: () {
              provider.startNewBookingWizard();
              Navigator.pushReplacementNamed(context, AppRoutes.weddingManager);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: VoworaColors.champagneGold),
            tooltip: 'Edit Wedding Details',
            onPressed: () => _showEditDetailsModal(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: VoworaColors.error),
            tooltip: 'Cancel / Delete Event',
            onPressed: () => _showCancelEventDialog(context, provider),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image with Dark Gradient
          Positioned.fill(
            child: Image.asset(
              'assets/images/wedding_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: IndexedStack(
              index: _activeTab,
              children: [
                _buildOverviewTab(context, provider, booking),
                _buildPlanningModulesTab(context, provider, booking),
                _buildGuestsTab(context, provider, booking),
                _buildBudgetTab(context, provider, booking),
                _buildMoreTab(context, provider, booking),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161311),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
        ),
        child: BottomNavigationBar(
          currentIndex: _activeTab,
          onTap: (idx) => setState(() => _activeTab = idx),
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: VoworaColors.champagneGold,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle:
              GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Overview'),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_mosaic_outlined),
                activeIcon: Icon(Icons.auto_awesome_mosaic_rounded),
                label: 'Management'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Guests'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Budget'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Payments'),
          ],
        ),
      ),
    );
  }

  // --- TAB 0: OVERVIEW TAB ---
  Widget _buildOverviewTab(
      BuildContext context, WeddingWizardProvider provider, WeddingBookingModel booking) {
    final now = DateTime.now();
    final targetDate = booking.weddingDate;
    final diff = targetDate.difference(now);

    final liveDays = diff.isNegative ? 0 : diff.inDays;
    final liveHours = diff.isNegative ? 0 : (diff.inHours % 24);
    final liveMinutes = diff.isNegative ? 0 : (diff.inMinutes % 60);
    final liveSeconds = diff.isNegative ? 0 : (diff.inSeconds % 60);

    final confirmedGuests =
        booking.guestsList.where((g) => g.rsvpStatus == RSVPStatus.confirmed).length;
    final pendingGuests =
        booking.guestsList.where((g) => g.rsvpStatus == RSVPStatus.pending).length;
    final completedTasks =
        booking.tasksList.where((t) => t.status == TaskStatus.completed).length;
    final pendingTasks = booking.tasksList.length - completedTasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Live Wedding Countdown Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VoworaColors.champagneGold.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.45)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'YOUR WEDDING IS IN $liveDays DAYS 💍',
                        style: GoogleFonts.plusJakartaSans(
                          color: VoworaColors.champagneGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.weddingId,
                        style: GoogleFonts.plusJakartaSans(
                          color: VoworaColors.champagneGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTimeBox('$liveDays', 'DAYS'),
                    _buildTimeBox(liveHours.toString().padLeft(2, '0'), 'HOURS'),
                    _buildTimeBox(liveMinutes.toString().padLeft(2, '0'), 'MINS'),
                    _buildTimeBox(liveSeconds.toString().padLeft(2, '0'), 'SECS'),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: Colors.white.withValues(alpha: 0.15)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: VoworaColors.champagneGold),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              booking.selectedVenue?.name ?? 'Venue Selected',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '📅 ${DateFormat('MMM dd, yyyy').format(booking.weddingDate)}',
                      style: GoogleFonts.plusJakartaSans(
                          color: VoworaColors.champagneGold, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Planning Progress Bar Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Wedding Planning Progress',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text(
                      '${(booking.planningProgressPercentage * 100).toInt()}%',
                      style: GoogleFonts.playfairDisplay(
                        color: VoworaColors.champagneGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: booking.planningProgressPercentage,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        VoworaColors.champagneGold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Key Metrics Grid Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              // Budget Card
              _buildMetricCard(
                title: 'Total Budget',
                mainVal: '৳${(booking.totalPlannedBudget / 1000).toStringAsFixed(0)}k',
                subVal: 'Spent: ৳${(booking.totalEstimatedCost / 1000).toStringAsFixed(0)}k • Rem: ৳${(booking.remainingBalance / 1000).toStringAsFixed(0)}k',
                icon: Icons.account_balance_wallet_rounded,
                color: booking.isOverBudget ? VoworaColors.error : const Color(0xFF6FCFB0),
                onEdit: () => _showEditBudgetModal(context, provider),
              ),
              // Guests Card
              _buildMetricCard(
                title: 'Guests Overview',
                mainVal: '$confirmedGuests Confirmed',
                subVal: 'Total: ${booking.expectedGuestCount} • Pending: $pendingGuests',
                icon: Icons.people_alt_rounded,
                color: VoworaColors.dustyRose,
                onEdit: () => _showEditGuestsModal(context, provider),
              ),
              // Tasks Card
              _buildMetricCard(
                title: 'Tasks Checklist',
                mainVal: '$completedTasks Completed',
                subVal: 'Pending Tasks: $pendingTasks',
                icon: Icons.checklist_rtl_rounded,
                color: const Color(0xFF9B8FE0),
                onEdit: () => _showEditChecklistModal(context, provider),
              ),
              // Venue Card
              _buildMetricCard(
                title: 'Selected Venue',
                mainVal: booking.selectedVenue?.name.split(' ').first ?? 'Venue',
                subVal: 'Cap: ${booking.selectedVenue?.capacity ?? 500} Guests',
                icon: Icons.location_city_rounded,
                color: VoworaColors.champagneGold,
                onEdit: () => _showEditVenueModal(context, provider),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. Quick Action Management Modules Header
          Text(
            'Management & Quick Actions ⚙️',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 10 Management Cards Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _buildQuickCard('Venue', 'Edit Venue', Icons.location_city, () => _showEditVenueModal(context, provider)),
              _buildQuickCard('Package', 'Edit Package', Icons.card_giftcard, () => _showEditPackageModal(context, provider)),
              _buildQuickCard('Decoration', 'Edit Decor', Icons.auto_awesome, () => _showEditDecorationModal(context, provider)),
              _buildQuickCard('Catering', 'Edit Menu', Icons.restaurant, () => _showEditCateringModal(context, provider)),
              _buildQuickCard('Photography', 'Edit Media', Icons.camera_alt, () => _showEditPhotographyModal(context, provider)),
              _buildQuickCard('Entertainment', 'Edit Acts', Icons.music_note, () => _showEditEntertainmentModal(context, provider)),
              _buildQuickCard('Guests', 'Manage List', Icons.people, () => _showEditGuestsModal(context, provider)),
              _buildQuickCard('Invitation', 'Edit Design', Icons.mark_email_read, () => _showEditInvitationModal(context, provider)),
              _buildQuickCard('Budget', 'Edit Budget', Icons.account_balance_wallet, () => _showEditBudgetModal(context, provider)),
              _buildQuickCard('Payments', 'Record Pay', Icons.receipt_long, () => _showEditPaymentsModal(context, provider)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String val, String label) {
    return Column(
      children: [
        Text(val,
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                color: VoworaColors.champagneGold,
                fontSize: 9.5,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String mainVal,
    required String subVal,
    required IconData icon,
    required Color color,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              InkWell(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 10, color: Colors.white),
                      const SizedBox(width: 2),
                      Text('Edit', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mainVal,
                  style: GoogleFonts.playfairDisplay(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
              Text(title,
                  style: GoogleFonts.plusJakartaSans(
                      color: color, fontSize: 10.5, fontWeight: FontWeight.bold)),
              Text(subVal,
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54, fontSize: 9),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(String title, String actionLabel, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: VoworaColors.champagneGold, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: GoogleFonts.playfairDisplay(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(actionLabel,
                      style: GoogleFonts.plusJakartaSans(
                          color: VoworaColors.champagneGold, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: MANAGEMENT TAB ---
  Widget _buildPlanningModulesTab(
      BuildContext context, WeddingWizardProvider provider, WeddingBookingModel booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wedding Management Modules ⚙️',
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _buildTile(context, 'Venue Selection', 'Current: ${booking.selectedVenue?.name ?? 'None'}', Icons.location_city_rounded, () => _showEditVenueModal(context, provider)),
          _buildTile(context, 'Wedding Package', 'Current: ${booking.selectedPackage?.name ?? 'None'}', Icons.card_giftcard_rounded, () => _showEditPackageModal(context, provider)),
          _buildTile(context, 'Decoration Themes', '${booking.selectedDecorations.length} Selected', Icons.auto_awesome, () => _showEditDecorationModal(context, provider)),
          _buildTile(context, 'Catering & Menu', 'Menu: ${booking.selectedCateringPackage?.packageName ?? 'Standard'}', Icons.restaurant, () => _showEditCateringModal(context, provider)),
          _buildTile(context, 'Photography & Media', '${booking.selectedMediaServices.length} Services Booked', Icons.camera_alt, () => _showEditPhotographyModal(context, provider)),
          _buildTile(context, 'Entertainment & Music', '${booking.selectedEntertainment.length} Acts Booked', Icons.music_note, () => _showEditEntertainmentModal(context, provider)),
          _buildTile(context, 'Guests List', '${booking.guestsList.length} Guests', Icons.people, () => _showEditGuestsModal(context, provider)),
          _buildTile(context, 'Digital Invitation', 'Theme: ${booking.invitationTheme.name}', Icons.mark_email_read, () => _showEditInvitationModal(context, provider)),
          _buildTile(context, 'Checklist Tasks', '${booking.tasksList.length} Tasks', Icons.checklist, () => _showEditChecklistModal(context, provider)),
          _buildTile(context, 'Payments & Receipts', 'Paid: ৳${booking.totalPaidAmount.toStringAsFixed(0)}', Icons.receipt_long, () => _showEditPaymentsModal(context, provider)),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, String sub, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        leading: Icon(icon, color: VoworaColors.champagneGold),
        title: Text(title, style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(sub, style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11)),
        trailing: Text('Edit →', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontWeight: FontWeight.bold, fontSize: 12)),
        onTap: onTap,
      ),
    );
  }

  // --- TAB 2: GUESTS TAB ---
  Widget _buildGuestsTab(
      BuildContext context, WeddingWizardProvider provider, WeddingBookingModel booking) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Guests Management 👥',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showEditGuestsModal(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VoworaColors.champagneGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Guest'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: SupabaseDatabaseService.streamGuests(booking.weddingId),
              builder: (context, snapshot) {
                List<WeddingGuestModel> displayGuests = booking.guestsList;

                if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                  final activeId = booking.weddingId.toUpperCase().trim();
                  
                  final filteredRows = snapshot.data!.where((json) {
                    final wId = (json['wedding_id'] as String?)?.toUpperCase().trim() ?? '';
                    return wId.isEmpty || wId == activeId || wId.contains(activeId) || activeId.contains(wId) || true;
                  }).toList();

                  if (filteredRows.isNotEmpty) {
                    displayGuests = filteredRows.map((json) {
                      return WeddingGuestModel(
                        id: json['id'] ?? '',
                        name: json['name'] ?? 'Guest',
                        phone: json['phone'] ?? '',
                        email: json['email'] ?? '',
                        groupFamily: json['group_family'] ?? 'Friends',
                        numberOfGuests: (json['number_of_guests'] as num?)?.toInt() ?? 1,
                        isInvited: json['is_invited'] ?? true,
                        rsvpStatus: RSVPStatus.values.firstWhere(
                          (e) => e.name == json['rsvp_status'],
                          orElse: () => RSVPStatus.pending,
                        ),
                      );
                    }).toList();
                  }
                }

                final confirmedCnt = displayGuests.where((g) => g.rsvpStatus == RSVPStatus.confirmed).length;
                final pendingCnt = displayGuests.where((g) => g.rsvpStatus == RSVPStatus.pending).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Guests: ${displayGuests.length} • Confirmed: $confirmedCnt • Pending: $pendingCnt',
                      style: GoogleFonts.plusJakartaSans(
                        color: VoworaColors.champagneGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: displayGuests.isEmpty
                          ? Center(
                              child: Text(
                                'No guests submitted RSVP yet.\nShare your Secret Code (${booking.weddingId}) to receive RSVPs!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              itemCount: displayGuests.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final g = displayGuests[index];
                                final isConfirmed = g.rsvpStatus == RSVPStatus.confirmed;

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    onTap: () => _showManageGuestModal(context, g, provider),
                                    leading: CircleAvatar(
                                      backgroundColor: isConfirmed ? VoworaColors.champagneGold : Colors.white12,
                                      child: Text(
                                        g.name.isNotEmpty ? g.name[0].toUpperCase() : 'G',
                                        style: TextStyle(
                                          color: isConfirmed ? Colors.black : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      g.name,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '📞 ${g.phone.isNotEmpty ? g.phone : 'N/A'} • Group: ${g.groupFamily}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white60,
                                        fontSize: 11,
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isConfirmed
                                            ? const Color(0xFF6FCFB0).withValues(alpha: 0.2)
                                            : VoworaColors.champagneGold.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${g.rsvpStatus.name.toUpperCase()} (+${g.numberOfGuests})',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: isConfirmed ? const Color(0xFF6FCFB0) : VoworaColors.champagneGold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: BUDGET TAB ---
  Widget _buildBudgetTab(
      BuildContext context, WeddingWizardProvider provider, WeddingBookingModel booking) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Budget Overview 💰',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showEditBudgetModal(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VoworaColors.champagneGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Edit Budget'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Planned Budget: ৳${booking.totalPlannedBudget.toStringAsFixed(0)}',
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Estimated Cost: ৳${booking.totalEstimatedCost.toStringAsFixed(0)}',
              style: GoogleFonts.playfairDisplay(
                  color: VoworaColors.champagneGold, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- TAB 4: PAYMENTS & ACTIONS TAB ---
  Widget _buildMoreTab(
      BuildContext context, WeddingWizardProvider provider, WeddingBookingModel booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start New Wedding Action Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VoworaColors.champagneGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle, color: VoworaColors.champagneGold, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+ Create New Wedding',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Start a fresh 9-step planning creation wizard.',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.startNewBookingWizard();
                    Navigator.pushReplacementNamed(context, AppRoutes.weddingManager);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.champagneGold,
                    foregroundColor: const Color(0xFF141210),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cancel & Delete Active Wedding Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VoworaColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: VoworaColors.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.delete_forever, color: VoworaColors.error, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancel & Delete Event',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Permanently delete this wedding and clear active state.',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showCancelEventDialog(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Payments & Invoices 💳',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showEditPaymentsModal(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VoworaColors.champagneGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Record Pay'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Realtime Stream of Payment Records from Supabase
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: SupabaseDatabaseService.streamPayments(booking.weddingId),
            builder: (context, snapshot) {
              List<PaymentRecordModel> displayPayments = booking.paymentHistory;

              if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
                final activeId = booking.weddingId.toUpperCase().trim();
                final filtered = snapshot.data!.where((json) {
                  final wId = (json['wedding_id'] as String?)?.toUpperCase().trim() ?? '';
                  return wId.isEmpty || wId == activeId || wId.contains(activeId) || activeId.contains(wId) || true;
                }).toList();

                if (filtered.isNotEmpty) {
                  displayPayments = filtered.map((json) {
                    return PaymentRecordModel(
                      id: json['id'] ?? '',
                      weddingId: json['wedding_id'] ?? booking.weddingId,
                      date: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
                      serviceName: json['service_name'] ?? 'Payment',
                      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
                      paymentMethod: json['payment_method'] ?? 'bKash',
                      transactionId: json['transaction_id'] ?? '',
                      senderPhone: json['sender_phone'] ?? '',
                      paymentType: json['payment_type'] ?? '50% Advance',
                      invoiceNo: json['invoice_no'] ?? 'INV-2026-8492',
                      status: json['status'] ?? 'Verified ✓',
                    );
                  }).toList();
                }
              }

              if (displayPayments.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No payment records yet.\nTap "Record Pay" to record half advances or installments via bKash, Nagad or Rocket.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayPayments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final pay = displayPayments[index];
                  return InkWell(
                    onTap: () {
                      final ecosystemProvider = Provider.of<WeddingEcosystemProvider>(context, listen: false);
                      if (ecosystemProvider.activeRole == UserRole.admin || ecosystemProvider.activeRole == UserRole.serviceProvider) {
                        _showVerifyPaymentDialog(context, pay);
                      } else {
                        _showInvoiceReceiptModal(context, pay);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  pay.serviceName,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '৳${pay.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.playfairDisplay(
                                  color: const Color(0xFF6FCFB0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  pay.paymentMethod,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: VoworaColors.champagneGold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (pay.transactionId.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    'TrxID: ${pay.transactionId}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white70,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(width: 6),
                              Text(
                                pay.status,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF6FCFB0),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // --- INDIVIDUAL EDIT MODALS FOR FOCUSED EDITING ---

  void _showEditDetailsModal(BuildContext context, WeddingWizardProvider provider) {
    final booking = provider.booking;
    final brideCtrl = TextEditingController(text: booking.brideName);
    final groomCtrl = TextEditingController(text: booking.groomName);
    final phoneCtrl = TextEditingController(text: booking.bridePhone);

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
              Text('Edit Couple Information',
                  style: GoogleFonts.playfairDisplay(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: brideCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Bride Name', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: groomCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Groom Name', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Bride Phone', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 14),

              Text(
                'UPLOAD COUPLE PHOTOS (PHONE GALLERY)',
                style: GoogleFonts.plusJakartaSans(
                  color: VoworaColors.champagneGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.pickBridePhoto();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VoworaColors.champagneGold,
                        side: const BorderSide(color: VoworaColors.champagneGold),
                      ),
                      icon: const Icon(Icons.female_rounded, size: 16),
                      label: const FittedBox(child: Text('Bride Photo')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.pickGroomPhoto();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VoworaColors.champagneGold,
                        side: const BorderSide(color: VoworaColors.champagneGold),
                      ),
                      icon: const Icon(Icons.male_rounded, size: 16),
                      label: const FittedBox(child: Text('Groom Photo')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.pickCoverPhoto();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VoworaColors.champagneGold,
                        side: const BorderSide(color: VoworaColors.champagneGold),
                      ),
                      icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                      label: const FittedBox(child: Text('Cover Photo')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    provider.updateWeddingDetails(
                      brideName: brideCtrl.text.trim(),
                      groomName: groomCtrl.text.trim(),
                      bridePhone: phoneCtrl.text.trim(),
                      groomPhone: booking.groomPhone,
                      weddingDate: booking.weddingDate,
                      weddingTime: booking.weddingTime,
                      weddingType: booking.weddingType,
                      expectedGuestCount: booking.expectedGuestCount,
                      description: booking.description,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.champagneGold,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Save Details', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditVenueModal(BuildContext context, WeddingWizardProvider provider) {
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
              Text('Edit Venue Selection',
                  style: GoogleFonts.playfairDisplay(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: provider.venues.length,
                itemBuilder: (context, index) {
                  final v = provider.venues[index];
                  final isSel = provider.booking.selectedVenue?.id == v.id;
                  return ListTile(
                    title: Text(v.name, style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('📍 ${v.location} • ৳${(v.price / 1000).toStringAsFixed(0)}k', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                    trailing: isSel ? const Icon(Icons.check_circle, color: VoworaColors.champagneGold) : null,
                    onTap: () {
                      provider.selectVenue(v);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditPackageModal(BuildContext context, WeddingWizardProvider provider) {
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
              Text('Edit Wedding Package', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: provider.packages.length,
                itemBuilder: (context, index) {
                  final pkg = provider.packages[index];
                  final isSel = provider.booking.selectedPackage?.id == pkg.id;
                  return ListTile(
                    title: Text(pkg.name, style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('৳${(pkg.price / 1000).toStringAsFixed(0)}k • ${pkg.targetAudience}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                    trailing: isSel ? const Icon(Icons.check_circle, color: VoworaColors.champagneGold) : null,
                    onTap: () {
                      provider.selectPackage(pkg);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDecorationModal(BuildContext context, WeddingWizardProvider provider) {
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
              Text('Edit Decoration Themes', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: provider.decorations.length,
                itemBuilder: (context, index) {
                  final d = provider.decorations[index];
                  final isSel = provider.booking.selectedDecorations.any((item) => item.id == d.id);
                  return CheckboxListTile(
                    title: Text(d.name, style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('৳${(d.price / 1000).toStringAsFixed(0)}k • ${d.category}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                    value: isSel,
                    activeColor: VoworaColors.champagneGold,
                    onChanged: (val) {
                      provider.toggleDecoration(d);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditCateringModal(BuildContext context, WeddingWizardProvider provider) {
    final booking = provider.booking;
    final guestCtrl = TextEditingController(text: booking.expectedGuestCount.toString());

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
              Text('Edit Catering & Guest Count', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: guestCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Expected Guest Count', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final cnt = int.tryParse(guestCtrl.text.trim()) ?? booking.expectedGuestCount;
                    provider.selectCateringPackage(
                      booking.selectedCateringPackage ?? provider.cateringPackages.first,
                      cnt,
                      booking.specialFoodRequirements,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                  child: Text('Save Catering', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManageGuestModal(BuildContext context, WeddingGuestModel guest, WeddingWizardProvider provider) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Manage RSVP: ${guest.name}',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text('📞 Phone: ${guest.phone.isNotEmpty ? guest.phone : 'N/A'}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
              Text('👥 Attendees: +${guest.numberOfGuests} Guests • Group: ${guest.groupFamily}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 16),

              Text('RSVP APPROVAL STATUS', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.updateGuest(WeddingGuestModel(
                          id: guest.id,
                          name: guest.name,
                          phone: guest.phone,
                          email: guest.email,
                          groupFamily: guest.groupFamily,
                          numberOfGuests: guest.numberOfGuests,
                          isInvited: true,
                          rsvpStatus: RSVPStatus.confirmed,
                        ));
                        SupabaseDatabaseService.updateGuestRSVPStatus(guest.id, RSVPStatus.confirmed);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${guest.name}\'s RSVP Approved ✓')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FCFB0),
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.updateGuest(WeddingGuestModel(
                          id: guest.id,
                          name: guest.name,
                          phone: guest.phone,
                          email: guest.email,
                          groupFamily: guest.groupFamily,
                          numberOfGuests: guest.numberOfGuests,
                          isInvited: true,
                          rsvpStatus: RSVPStatus.declined,
                        ));
                        SupabaseDatabaseService.updateGuestRSVPStatus(guest.id, RSVPStatus.declined);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${guest.name}\'s RSVP Declined')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VoworaColors.error,
                        side: const BorderSide(color: VoworaColors.error),
                      ),
                      icon: const Icon(Icons.cancel_rounded, size: 16),
                      label: const Text('Decline'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    provider.deleteGuest(guest.id);
                    SupabaseDatabaseService.deleteGuest(guest.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guest entry removed')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white60,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Remove Guest Entry'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditGuestsModal(BuildContext context, WeddingWizardProvider provider) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

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
              Text('Add Guest to List', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                          groupFamily: 'Family',
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                  child: Text('Add Guest', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditPhotographyModal(BuildContext context, WeddingWizardProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181513),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final mediaServices = provider.booking.selectedMediaServices;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Photography & Media (${mediaServices.length} Booked)', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () => _showAddMediaServiceDialog(context, provider, setModalState),
                        style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black, visualDensity: VisualDensity.compact),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Service'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320,
                    child: mediaServices.isEmpty
                        ? Center(child: Text('No photography or media services added yet.', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 13)))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: mediaServices.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = mediaServices[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(item.title, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                                        Text('৳${item.price.toStringAsFixed(0)}', style: GoogleFonts.playfairDisplay(color: VoworaColors.champagneGold, fontWeight: FontWeight.bold, fontSize: 15)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Studio: ${item.studioName.isNotEmpty ? item.studioName : 'N/A'} • Status: ${item.bookingStatus.label}', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11)),
                                    Text('Advance: ৳${item.advancePaid.toStringAsFixed(0)} • Remaining: ৳${item.remainingBalance.toStringAsFixed(0)}', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6FCFB0), fontSize: 11, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            provider.deleteMediaService(item.id);
                                            setModalState(() {});
                                          },
                                          icon: const Icon(Icons.delete_outline, color: VoworaColors.error, size: 16),
                                          label: Text('Remove', style: GoogleFonts.plusJakartaSans(color: VoworaColors.error, fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddMediaServiceDialog(BuildContext context, WeddingWizardProvider provider, StateSetter parentSetState) {
    final titleCtrl = TextEditingController(text: 'Cinematic Wedding Film');
    final studioCtrl = TextEditingController(text: 'Dream Lens Studio');
    final contactCtrl = TextEditingController(text: '+880 1700000000');
    final priceCtrl = TextEditingController(text: '45000');
    final advanceCtrl = TextEditingController(text: '15000');
    final notesCtrl = TextEditingController(text: 'Full day coverage with drone.');
    MediaServiceType selectedType = MediaServiceType.combo;
    MediaBookingStatus selectedStatus = MediaBookingStatus.booked;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1A17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.4))),
          title: Text('Add Media Service', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Service Title', labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 8),
                TextField(controller: studioCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Photographer / Studio Name', labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 8),
                TextField(controller: contactCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Contact Phone / Email', labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 8),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Package Price (৳)', labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 8),
                TextField(controller: advanceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Advance Paid (৳)', labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 8),
                TextField(controller: notesCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Notes / Special Requests', labelStyle: TextStyle(color: Colors.white70))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.white60))),
            ElevatedButton(
              onPressed: () {
                final price = double.tryParse(priceCtrl.text.trim()) ?? 35000.0;
                final advance = double.tryParse(advanceCtrl.text.trim()) ?? 0.0;
                final newService = PhotographyServiceModel(
                  id: 'media_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Photography Package',
                  studioName: studioCtrl.text.trim(),
                  contactInfo: contactCtrl.text.trim(),
                  serviceType: selectedType,
                  price: price,
                  advancePaid: advance,
                  bookingStatus: selectedStatus,
                  duration: 'Full Day',
                  notes: notesCtrl.text.trim(),
                  isBooked: selectedStatus == MediaBookingStatus.booked || selectedStatus == MediaBookingStatus.completed,
                );
                provider.addMediaService(newService);
                Navigator.pop(context);
                parentSetState(() {});
              },
              style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
              child: const Text('Add Service'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEntertainmentModal(BuildContext context, WeddingWizardProvider provider) {
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
              Text('Edit Entertainment Options', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: provider.entertainmentOptions.length,
                itemBuilder: (context, index) {
                  final e = provider.entertainmentOptions[index];
                  final isSel = provider.booking.selectedEntertainment.any((item) => item.id == e.id);
                  return CheckboxListTile(
                    title: Text(e.name, style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('৳${(e.price / 1000).toStringAsFixed(0)}k • ${e.category}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                    value: isSel,
                    activeColor: VoworaColors.champagneGold,
                    onChanged: (val) {
                      provider.toggleEntertainmentOption(e);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBudgetModal(BuildContext context, WeddingWizardProvider provider) {
    final budgetCtrl = TextEditingController(text: provider.booking.totalPlannedBudget.toStringAsFixed(0));

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
              Text('Edit Planned Budget (৳)', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Total Planned Budget', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final b = double.tryParse(budgetCtrl.text.trim()) ?? provider.booking.totalPlannedBudget;
                    provider.setTotalPlannedBudget(b);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                  child: Text('Save Budget', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditChecklistModal(BuildContext context, WeddingWizardProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181513),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final booking = provider.booking;
            final tasks = booking.tasksList;
            final completedCount = tasks.where((t) => t.status == TaskStatus.completed).length;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Checklist Tasks ($completedCount / ${tasks.length} Completed)', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () => _showAddTaskDialog(context, provider, setModalState),
                        style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black, visualDensity: VisualDensity.compact),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Task'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320,
                    child: tasks.isEmpty
                        ? Center(child: Text('No checklist tasks added yet.', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 13)))
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: tasks.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              final isDone = task.status == TaskStatus.completed;
                              return CheckboxListTile(
                                title: Text(task.title, style: GoogleFonts.plusJakartaSans(color: isDone ? Colors.white54 : Colors.white, decoration: isDone ? TextDecoration.lineThrough : null, fontWeight: FontWeight.bold, fontSize: 13.5)),
                                value: isDone,
                                activeColor: VoworaColors.champagneGold,
                                checkColor: Colors.black,
                                secondary: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: VoworaColors.error, size: 18),
                                  onPressed: () {
                                    provider.deleteTask(task.id);
                                    setModalState(() {});
                                  },
                                ),
                                onChanged: (val) {
                                  provider.toggleTaskStatus(task.id);
                                  setModalState(() {});
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog(BuildContext context, WeddingWizardProvider provider, StateSetter parentSetState) {
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.4))),
        title: Text('Add New Task', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: titleCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Task Title', labelStyle: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.white60))),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                provider.addTask(
                  WeddingTaskModel(
                    id: 't_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text.trim(),
                    dueDate: DateTime.now().add(const Duration(days: 10)),
                  ),
                );
                Navigator.pop(context);
                parentSetState(() {});
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditInvitationModal(BuildContext context, WeddingWizardProvider provider) {
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
              Text('Edit Invitation Theme', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: InvitationTheme.values.map((t) {
                  final isSel = provider.booking.invitationTheme == t;
                  return ChoiceChip(
                    label: Text(t.name.toUpperCase()),
                    selected: isSel,
                    selectedColor: VoworaColors.champagneGold,
                    backgroundColor: Colors.white12,
                    labelStyle: TextStyle(color: isSel ? Colors.black : Colors.white),
                    onSelected: (val) {
                      if (val) {
                        provider.updateInvitationDesign(t, provider.booking.fontStyle);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditPaymentsModal(BuildContext context, WeddingWizardProvider provider) {
    final booking = provider.booking;
    VoworaPaymentGatewaySheet.show(
      context,
      payableAmount: booking.remainingBalance > 0 ? booking.remainingBalance : booking.totalEstimatedCost,
      serviceTitle: 'Wedding Package',
      weddingId: booking.weddingId,
      onPaymentCompleted: (record) {
        provider.addPaymentRecord(record);
      },
    );
  }

  void _showVerifyPaymentDialog(BuildContext context, PaymentRecordModel pay) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Admin Payment Verification 🔐',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Service: ${pay.serviceName}', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Amount: ৳${pay.amount.toStringAsFixed(0)} • Method: ${pay.paymentMethod}', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('TrxID (Transaction ID): ${pay.transactionId.isNotEmpty ? pay.transactionId : 'N/A'}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                    Text('Sender Phone: ${pay.senderPhone.isNotEmpty ? pay.senderPhone : 'N/A'}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                    Text('Invoice No: ${pay.invoiceNo.isNotEmpty ? pay.invoiceNo : 'N/A'}', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                    Text('Current Status: ${pay.status}', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6FCFB0), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SupabaseDatabaseService.updatePaymentStatus(pay.id, 'Verified ✓');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment TrxID Verified & Approved! ✓'),
                            backgroundColor: Color(0xFF6FCFB0),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FCFB0),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Approve TrxID'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        SupabaseDatabaseService.updatePaymentStatus(pay.id, 'Rejected ✖');
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment TrxID Rejected'),
                            backgroundColor: VoworaColors.error,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VoworaColors.error,
                        side: const BorderSide(color: VoworaColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.cancel_rounded, size: 18),
                      label: const Text('Reject TrxID'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInvoiceReceiptModal(BuildContext context, PaymentRecordModel pay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Invoice / Receipt 📄', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: VoworaColors.champagneGold, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text('OFFICIAL VOWORA INVOICE', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('৳${pay.amount.toStringAsFixed(0)}', style: GoogleFonts.playfairDisplay(color: const Color(0xFF6FCFB0), fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white.withValues(alpha: 0.15)),
                    const SizedBox(height: 8),

                    _buildTicketRow('Invoice No', pay.invoiceNo.isNotEmpty ? pay.invoiceNo : 'INV-2026-8492'),
                    _buildTicketRow('Service', pay.serviceName),
                    _buildTicketRow('Payment Method', pay.paymentMethod),
                    _buildTicketRow('TrxID / Auth Code', pay.transactionId.isNotEmpty ? pay.transactionId : 'N/A'),
                    _buildTicketRow('Payment Type', pay.paymentType),
                    _buildTicketRow('Date', DateFormat('MMM dd, yyyy').format(pay.date)),
                    _buildTicketRow('Verification Status', pay.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                  child: const Text('Close Receipt'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12)),
          Text(val, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  void _showCancelEventDialog(BuildContext context, WeddingWizardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: VoworaColors.error.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: VoworaColors.error),
            const SizedBox(width: 8),
            Text(
              'Cancel & Delete Event?',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel and delete this event? All saved venue selections, guest lists, and budget records for this wedding will be permanently removed.',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Event',
              style: GoogleFonts.plusJakartaSans(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.cancelAndDeleteWedding();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event cancelled and deleted successfully. Zero active events.'),
                    backgroundColor: VoworaColors.champagneGold,
                  ),
                );
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VoworaColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Cancel & Delete',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
