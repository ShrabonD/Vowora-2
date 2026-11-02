import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/birthday_theme.dart';
import '../../providers/birthday_provider.dart';
import '../../models/birthday/birthday_guest.dart';

class BirthdayGuestsScreen extends StatefulWidget {
  const BirthdayGuestsScreen({super.key});

  @override
  State<BirthdayGuestsScreen> createState() => _BirthdayGuestsScreenState();
}

class _BirthdayGuestsScreenState extends State<BirthdayGuestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Accepted', 'Pending', 'Declined'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayProvider>(
      builder: (context, provider, child) {
        final activeEvent = provider.activeEvent;

        return Scaffold(
          backgroundColor: BirthdayTheme.warmIvory,
          appBar: AppBar(
            backgroundColor: BirthdayTheme.warmIvory,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: BirthdayTheme.deepCocoa, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'Guest List & RSVP',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BirthdayTheme.deepCocoa,
                  ),
                ),
                if (activeEvent != null)
                  Text(
                    activeEvent.personName.isNotEmpty
                        ? "${activeEvent.personName}'s Celebration"
                        : activeEvent.theme,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            actions: [
              if (activeEvent != null)
                IconButton(
                  tooltip: 'Quick Info',
                  icon: const Icon(Icons.info_outline_rounded, color: BirthdayTheme.mutedGold),
                  onPressed: () => _showRsvpSummaryDialog(context, provider),
                ),
            ],
          ),
          floatingActionButton: activeEvent == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openGuestBottomSheet(context, provider: provider),
                  backgroundColor: BirthdayTheme.mutedGold,
                  foregroundColor: BirthdayTheme.softWhite,
                  elevation: 4,
                  icon: const Icon(Icons.person_add_rounded, size: 20),
                  label: Text(
                    'Add Guest',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
          body: activeEvent == null
              ? _buildNoEventState(context)
              : SafeArea(
                  child: Column(
                    children: [
                      // Stat Chips Summary Row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: _buildSummaryHeader(provider),
                      ),

                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _searchController,
                          style: BirthdayTheme.body,
                          decoration: BirthdayTheme.inputDecoration(
                            'Search guests',
                            hint: 'Search by name, phone, or email...',
                            icon: Icons.search_rounded,
                          ).copyWith(
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18, color: BirthdayTheme.deepCocoa),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // RSVP Filter Chips
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildFilterBar(provider),
                      ),

                      // Guests List
                      Expanded(
                        child: _buildGuestList(context, provider),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ================= SUMMARY HEADER =================
  Widget _buildSummaryHeader(BirthdayProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BirthdayTheme.cardDecoration,
      child: Row(
        children: [
          _buildStatCard(
            label: 'Total Invited',
            count: provider.totalInvited,
            color: BirthdayTheme.deepCocoa,
            bgColor: BirthdayTheme.champagneBeige.withValues(alpha: 0.35),
            icon: Icons.people_outline_rounded,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            label: 'Confirmed',
            count: provider.confirmedGuests,
            color: BirthdayTheme.successGreen,
            bgColor: BirthdayTheme.successGreen.withValues(alpha: 0.12),
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            label: 'Pending',
            count: provider.pendingGuests,
            color: BirthdayTheme.alertOrange,
            bgColor: BirthdayTheme.alertOrange.withValues(alpha: 0.12),
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            label: 'Declined',
            count: provider.declinedGuests,
            color: BirthdayTheme.errorRed,
            bgColor: BirthdayTheme.errorRed.withValues(alpha: 0.12),
            icon: Icons.highlight_off_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: BirthdayTheme.deepCocoa.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FILTER BAR =================
  Widget _buildFilterBar(BirthdayProvider provider) {
    final filters = [
      {'key': 'All', 'count': provider.totalInvited},
      {'key': 'Accepted', 'count': provider.confirmedGuests},
      {'key': 'Pending', 'count': provider.pendingGuests},
      {'key': 'Declined', 'count': provider.declinedGuests},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((item) {
          final key = item['key'] as String;
          final count = item['count'] as int;
          final isSelected = _selectedFilter == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    key,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? BirthdayTheme.softWhite : BirthdayTheme.deepCocoa,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? BirthdayTheme.softWhite.withValues(alpha: 0.25)
                          : BirthdayTheme.champagneBeige.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? BirthdayTheme.softWhite : BirthdayTheme.deepCocoa,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              selectedColor: BirthdayTheme.mutedGold,
              backgroundColor: BirthdayTheme.softWhite,
              side: BorderSide(
                color: isSelected ? BirthdayTheme.mutedGold : BirthdayTheme.subtleBorder,
                width: 0.8,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedFilter = key;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= GUEST LIST =================
  Widget _buildGuestList(BuildContext context, BirthdayProvider provider) {
    if (provider.guests.isEmpty) {
      return _buildEmptyGuestsState(context, provider);
    }

    final filteredGuests = provider.guests.where((guest) {
      // RSVP Filter
      final status = guest.rsvpStatus.trim().toLowerCase();
      final matchesFilter = switch (_selectedFilter) {
        'Accepted' => status == 'accepted',
        'Pending' => status == 'pending',
        'Declined' => status == 'declined',
        _ => true,
      };
      if (!matchesFilter) return false;

      // Search Query
      if (_searchQuery.isEmpty) return true;
      final nameMatches = guest.name.toLowerCase().contains(_searchQuery);
      final phoneMatches = guest.phone.toLowerCase().contains(_searchQuery);
      final emailMatches = guest.email.toLowerCase().contains(_searchQuery);
      return nameMatches || phoneMatches || emailMatches;
    }).toList();

    if (filteredGuests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: BirthdayTheme.champagneBeige.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_search_rounded, size: 32, color: BirthdayTheme.mutedGold),
              ),
              const SizedBox(height: 14),
              Text(
                'No matching guests found',
                style: BirthdayTheme.heading3,
              ),
              const SizedBox(height: 6),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No guests matching "$_searchQuery"'
                    : 'No guests found under "$_selectedFilter" RSVP status.',
                textAlign: TextAlign.center,
                style: BirthdayTheme.subtitle,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedFilter = 'All';
                  });
                },
                style: BirthdayTheme.secondaryButton,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset Filter & Search'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: filteredGuests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final guest = filteredGuests[index];
        return _buildGuestCard(context, guest, provider);
      },
    );
  }

  Widget _buildGuestCard(BuildContext context, BirthdayGuest guest, BirthdayProvider provider) {
    final statusColor = _getRsvpColor(guest.rsvpStatus);
    final statusLabel = _getRsvpLabel(guest.rsvpStatus);

    return Dismissible(
      key: ValueKey('guest_${guest.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: BirthdayTheme.errorRed,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_sweep_rounded, color: BirthdayTheme.softWhite, size: 24),
            const SizedBox(width: 8),
            Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                color: BirthdayTheme.softWhite,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor: BirthdayTheme.softWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.delete_outline_rounded, color: BirthdayTheme.errorRed, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Remove Guest',
                  style: BirthdayTheme.heading3,
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to remove "${guest.name}" from your guest list?',
              style: BirthdayTheme.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.plusJakartaSans(
                    color: BirthdayTheme.deepCocoa.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogCtx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BirthdayTheme.errorRed,
                  foregroundColor: BirthdayTheme.softWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await provider.deleteGuest(guest.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${guest.name} was removed from the guest list.'),
              backgroundColor: BirthdayTheme.deepCocoa,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: BirthdayTheme.mutedGold,
                onPressed: () {},
              ),
            ),
          );
        }
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openGuestBottomSheet(context, guest: guest, provider: provider),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BirthdayTheme.cardDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Circle with Initial
                _buildAvatar(guest.name),
                const SizedBox(width: 14),

                // Guest Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & RSVP Chip Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              guest.name,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: BirthdayTheme.deepCocoa,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildRsvpChip(statusLabel, statusColor),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Contact details (phone / email)
                      if (guest.phone.isNotEmpty || guest.email.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              if (guest.phone.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 13, color: BirthdayTheme.mutedGold),
                                    const SizedBox(width: 4),
                                    Text(
                                      guest.phone,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: BirthdayTheme.deepCocoa.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ),
                              if (guest.email.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.email_outlined, size: 13, color: BirthdayTheme.mutedGold),
                                    const SizedBox(width: 4),
                                    Text(
                                      guest.email,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: BirthdayTheme.deepCocoa.withValues(alpha: 0.75),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                      // Tags Row: Accompanied Guests + Dietary Preference
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // +N guests badge
                          if (guest.accompaningGuests > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: BirthdayTheme.champagneBeige.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: BirthdayTheme.mutedGold.withValues(alpha: 0.25),
                                  width: 0.7,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.group_outlined, size: 12, color: BirthdayTheme.mutedGold),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${guest.accompaningGuests} guest${guest.accompaningGuests > 1 ? 's' : ''} (Total: ${guest.totalHeadcount})',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: BirthdayTheme.deepCocoa,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Dietary preference badge
                          if (guest.dietaryPreference.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: BirthdayTheme.warmIvory,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: BirthdayTheme.subtleBorder,
                                  width: 0.7,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.restaurant_menu_rounded, size: 12, color: BirthdayTheme.mutedGold),
                                  const SizedBox(width: 4),
                                  Text(
                                    guest.dietaryPreference,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: BirthdayTheme.deepCocoa.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      // Notes preview if present
                      if (guest.notes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Note: "${guest.notes}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 4),
                // Edit chevron
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: BirthdayTheme.deepCocoa.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BirthdayTheme.champagneBeige,
            BirthdayTheme.roseBeige.withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: BirthdayTheme.deepCocoa.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BirthdayTheme.deepCocoa,
          ),
        ),
      ),
    );
  }

  Widget _buildRsvpChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRsvpColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'accepted':
        return BirthdayTheme.successGreen;
      case 'declined':
        return BirthdayTheme.errorRed;
      case 'pending':
      default:
        return BirthdayTheme.alertOrange;
    }
  }

  String _getRsvpLabel(String status) {
    switch (status.trim().toLowerCase()) {
      case 'accepted':
        return 'Confirmed';
      case 'declined':
        return 'Declined';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  // ================= EMPTY STATES =================
  Widget _buildNoEventState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BirthdayTheme.cardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: BirthdayTheme.champagneBeige.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cake_outlined, size: 36, color: BirthdayTheme.mutedGold),
              ),
              const SizedBox(height: 18),
              Text(
                'Create a birthday event first',
                textAlign: TextAlign.center,
                style: BirthdayTheme.heading2,
              ),
              const SizedBox(height: 10),
              Text(
                'To manage your invitations, guest headcounts, and RSVP tracking, please initialize an active birthday celebration first.',
                textAlign: TextAlign.center,
                style: BirthdayTheme.subtitle,
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                style: BirthdayTheme.primaryButton,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back to Birthday Studio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyGuestsState(BuildContext context, BirthdayProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: BirthdayTheme.champagneBeige.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_add_outlined, size: 40, color: BirthdayTheme.mutedGold),
            ),
            const SizedBox(height: 20),
            Text(
              'No guests added yet.\nStart building your guest list!',
              textAlign: TextAlign.center,
              style: BirthdayTheme.heading3,
            ),
            const SizedBox(height: 10),
            Text(
              'Invite your closest friends, family, and colleagues. Track RSVPs, plus-ones, and meal preferences effortlessly.',
              textAlign: TextAlign.center,
              style: BirthdayTheme.subtitle,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openGuestBottomSheet(context, provider: provider),
              style: BirthdayTheme.primaryButton,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add First Guest'),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ADD / EDIT BOTTOM SHEET =================
  void _openGuestBottomSheet(BuildContext context, {BirthdayGuest? guest, required BirthdayProvider provider}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _GuestFormBottomSheet(
        guest: guest,
        provider: provider,
      ),
    );
  }

  // ================= RSVP STATS DIALOG =================
  void _showRsvpSummaryDialog(BuildContext context, BirthdayProvider provider) {
    final activeEvent = provider.activeEvent;
    final totalExpected = activeEvent?.expectedGuestCount ?? 0;
    final totalHeadcount = provider.guests.fold<int>(0, (sum, g) => sum + g.totalHeadcount);
    final confirmedHeadcount = provider.guests
        .where((g) => g.rsvpStatus.toLowerCase() == 'accepted')
        .fold<int>(0, (sum, g) => sum + g.totalHeadcount);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BirthdayTheme.softWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.analytics_outlined, color: BirthdayTheme.mutedGold),
            const SizedBox(width: 10),
            Text('RSVP Overview', style: BirthdayTheme.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Planned Capacity', '$totalExpected guests'),
            const Divider(color: BirthdayTheme.subtleBorder, height: 16),
            _buildDialogRow('Total Invitations', '${provider.totalInvited} cards sent'),
            _buildDialogRow('Confirmed Guests', '${provider.confirmedGuests} invitations'),
            _buildDialogRow('Confirmed Headcount', '$confirmedHeadcount people (incl. +1s)'),
            _buildDialogRow('Pending Responses', '${provider.pendingGuests} awaiting'),
            _buildDialogRow('Declined', '${provider.declinedGuests} responses'),
            const Divider(color: BirthdayTheme.subtleBorder, height: 16),
            _buildDialogRow('Total In-List Headcount', '$totalHeadcount people'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: BirthdayTheme.primaryButton,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: BirthdayTheme.deepCocoa.withValues(alpha: 0.75),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: BirthdayTheme.deepCocoa,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= GUEST FORM BOTTOM SHEET =================
class _GuestFormBottomSheet extends StatefulWidget {
  final BirthdayGuest? guest;
  final BirthdayProvider provider;

  const _GuestFormBottomSheet({
    this.guest,
    required this.provider,
  });

  @override
  State<_GuestFormBottomSheet> createState() => _GuestFormBottomSheetState();
}

class _GuestFormBottomSheetState extends State<_GuestFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _accompanyingController;
  late TextEditingController _notesController;

  late String _rsvpStatus;
  late String _dietaryPreference;
  bool _isSaving = false;

  static const List<String> _dietaryOptions = [
    'Regular',
    'Vegetarian',
    'Vegan',
    'Halal',
    'Gluten-Free',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.guest;
    _nameController = TextEditingController(text: g?.name ?? '');
    _phoneController = TextEditingController(text: g?.phone ?? '');
    _emailController = TextEditingController(text: g?.email ?? '');
    _accompanyingController = TextEditingController(text: (g?.accompaningGuests ?? 0).toString());
    _notesController = TextEditingController(text: g?.notes ?? '');

    _rsvpStatus = g?.rsvpStatus ?? 'pending';
    _dietaryPreference = g != null && _dietaryOptions.contains(g.dietaryPreference)
        ? g.dietaryPreference
        : 'Regular';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _accompanyingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveGuest() async {
    if (!_formKey.currentState!.validate()) return;

    final activeEvent = widget.provider.activeEvent;
    if (activeEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active birthday event found.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final accompanying = int.tryParse(_accompanyingController.text.trim()) ?? 0;

    try {
      if (widget.guest == null) {
        // Add new guest
        final newGuest = BirthdayGuest(
          id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
          eventId: activeEvent.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          rsvpStatus: _rsvpStatus.toLowerCase(),
          accompaningGuests: accompanying,
          dietaryPreference: _dietaryPreference,
          notes: _notesController.text.trim(),
        );

        await widget.provider.addGuest(newGuest);
      } else {
        // Update existing guest
        final updatedGuest = widget.guest!;
        updatedGuest.name = _nameController.text.trim();
        updatedGuest.phone = _phoneController.text.trim();
        updatedGuest.email = _emailController.text.trim();
        updatedGuest.rsvpStatus = _rsvpStatus.toLowerCase();
        updatedGuest.accompaningGuests = accompanying;
        updatedGuest.dietaryPreference = _dietaryPreference;
        updatedGuest.notes = _notesController.text.trim();

        await widget.provider.updateGuest(updatedGuest);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.guest == null
                  ? '${_nameController.text.trim()} added to guest list! ✨'
                  : '${_nameController.text.trim()} updated successfully! ✨',
            ),
            backgroundColor: BirthdayTheme.deepCocoa,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save guest: $e'),
            backgroundColor: BirthdayTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.guest != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: BirthdayTheme.softWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom sheet drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: BirthdayTheme.champagneBeige,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Guest' : 'Add New Guest',
                    style: BirthdayTheme.heading2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: BirthdayTheme.deepCocoa),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Name Field (Required)
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: BirthdayTheme.body,
                decoration: BirthdayTheme.inputDecoration(
                  'Full Name *',
                  hint: 'E.g., Jane Cooper',
                  icon: Icons.person_outline_rounded,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter guest name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: BirthdayTheme.body,
                decoration: BirthdayTheme.inputDecoration(
                  'Phone Number',
                  hint: '01700-000000',
                  icon: Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 12),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: BirthdayTheme.body,
                decoration: BirthdayTheme.inputDecoration(
                  'Email Address',
                  hint: 'guest@example.com',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 16),

              // RSVP Status Choice Chips
              Text(
                'RSVP Status',
                style: BirthdayTheme.label,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRsvpChoiceChip('Pending', 'pending', BirthdayTheme.alertOrange),
                  const SizedBox(width: 8),
                  _buildRsvpChoiceChip('Accepted', 'accepted', BirthdayTheme.successGreen),
                  const SizedBox(width: 8),
                  _buildRsvpChoiceChip('Declined', 'declined', BirthdayTheme.errorRed),
                ],
              ),
              const SizedBox(height: 16),

              // Accompanying Guests (numeric input)
              TextFormField(
                controller: _accompanyingController,
                keyboardType: TextInputType.number,
                style: BirthdayTheme.body,
                decoration: BirthdayTheme.inputDecoration(
                  'Accompanying Guests (+N)',
                  hint: '0 for solo guest',
                  icon: Icons.group_add_outlined,
                ),
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    final parsed = int.tryParse(val.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid non-negative number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Dietary Preference Dropdown
              DropdownButtonFormField<String>(
                initialValue: _dietaryPreference,
                style: BirthdayTheme.body,
                dropdownColor: BirthdayTheme.softWhite,
                decoration: BirthdayTheme.inputDecoration(
                  'Dietary Preference',
                  icon: Icons.restaurant_menu_rounded,
                ),
                items: _dietaryOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(
                      opt,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: BirthdayTheme.deepCocoa,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _dietaryPreference = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: BirthdayTheme.body,
                decoration: BirthdayTheme.inputDecoration(
                  'Notes / Special Requests',
                  hint: 'Allergies, seating preference, arrival note...',
                  icon: Icons.notes_rounded,
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveGuest,
                style: BirthdayTheme.primaryButton,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(BirthdayTheme.softWhite),
                        ),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Add Guest',
                        style: BirthdayTheme.buttonText.copyWith(color: BirthdayTheme.softWhite),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRsvpChoiceChip(String label, String value, Color color) {
    final isSelected = _rsvpStatus.toLowerCase() == value.toLowerCase();

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _rsvpStatus = value;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.16) : BirthdayTheme.warmIvory,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : BirthdayTheme.subtleBorder,
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : BirthdayTheme.deepCocoa.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
