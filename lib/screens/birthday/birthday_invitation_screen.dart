import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/birthday_theme.dart';
import '../../providers/birthday_provider.dart';

/// Template data structure
class _InvitationTemplateConfig {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color cardBackground;
  final Color textColor;
  final Color accentColor;
  final String fontType; // 'playfair' or 'jakarta'
  final IconData motifIcon;
  final String styleTag;
  final bool isDark;

  const _InvitationTemplateConfig({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.cardBackground,
    required this.textColor,
    required this.accentColor,
    required this.fontType,
    required this.motifIcon,
    required this.styleTag,
    this.isDark = false,
  });
}

class BirthdayInvitationScreen extends StatefulWidget {
  const BirthdayInvitationScreen({super.key});

  @override
  State<BirthdayInvitationScreen> createState() => _BirthdayInvitationScreenState();
}

class _BirthdayInvitationScreenState extends State<BirthdayInvitationScreen> {
  // 7 Templates defined as per specifications:
  // 1. Champagne Minimal - mutedGold + warmIvory
  // 2. Floral Ivory - roseBeige + softWhite
  // 3. Blush Elegance - Color(0xFFE8B4B8) + softWhite
  // 4. Modern Gold - Color(0xFFD4AF37) + Color(0xFF1C1C1C)
  // 5. Kids' Celebration - Color(0xFF5DADE2) + Color(0xFFF7DC6F)
  // 6. Black Tie - Color(0xFF1C1C1C) + Color(0xFFD4AF37)
  // 7. Garden Party - Color(0xFF82C785) + softWhite
  static final List<_InvitationTemplateConfig> _templates = [
    const _InvitationTemplateConfig(
      id: 'champagne_minimal',
      name: 'Champagne Minimal',
      primaryColor: BirthdayTheme.mutedGold,
      secondaryColor: BirthdayTheme.warmIvory,
      cardBackground: BirthdayTheme.warmIvory,
      textColor: BirthdayTheme.deepCocoa,
      accentColor: BirthdayTheme.mutedGold,
      fontType: 'playfair',
      motifIcon: Icons.auto_awesome_rounded,
      styleTag: 'Timeless & Refined',
    ),
    const _InvitationTemplateConfig(
      id: 'floral_ivory',
      name: 'Floral Ivory',
      primaryColor: BirthdayTheme.roseBeige,
      secondaryColor: BirthdayTheme.softWhite,
      cardBackground: BirthdayTheme.softWhite,
      textColor: BirthdayTheme.deepCocoa,
      accentColor: BirthdayTheme.roseBeige,
      fontType: 'playfair',
      motifIcon: Icons.local_florist_rounded,
      styleTag: 'Delicate & Soft',
    ),
    const _InvitationTemplateConfig(
      id: 'blush_elegance',
      name: 'Blush Elegance',
      primaryColor: Color(0xFFE8B4B8),
      secondaryColor: BirthdayTheme.softWhite,
      cardBackground: Color(0xFFFFF9F9),
      textColor: BirthdayTheme.deepCocoa,
      accentColor: Color(0xFFD2828D),
      fontType: 'playfair',
      motifIcon: Icons.favorite_rounded,
      styleTag: 'Romantic Pastel',
    ),
    const _InvitationTemplateConfig(
      id: 'modern_gold',
      name: 'Modern Gold',
      primaryColor: Color(0xFFD4AF37),
      secondaryColor: Color(0xFF1C1C1C),
      cardBackground: Color(0xFF1C1C1C),
      textColor: Color(0xFFFAF9F6),
      accentColor: Color(0xFFD4AF37),
      fontType: 'jakarta',
      motifIcon: Icons.diamond_outlined,
      styleTag: 'Bold Luxury',
      isDark: true,
    ),
    const _InvitationTemplateConfig(
      id: 'kids_celebration',
      name: "Kids' Celebration",
      primaryColor: Color(0xFF5DADE2),
      secondaryColor: Color(0xFFF7DC6F),
      cardBackground: Color(0xFFFDFAF0),
      textColor: Color(0xFF2C3E50),
      accentColor: Color(0xFFE67E22),
      fontType: 'jakarta',
      motifIcon: Icons.celebration_rounded,
      styleTag: 'Playful & Cheerful',
    ),
    const _InvitationTemplateConfig(
      id: 'black_tie',
      name: 'Black Tie',
      primaryColor: Color(0xFF1C1C1C),
      secondaryColor: Color(0xFFD4AF37),
      cardBackground: Color(0xFF141414),
      textColor: Color(0xFFF5F5F5),
      accentColor: Color(0xFFD4AF37),
      fontType: 'playfair',
      motifIcon: Icons.wine_bar_rounded,
      styleTag: 'Glamour Gala',
      isDark: true,
    ),
    const _InvitationTemplateConfig(
      id: 'garden_party',
      name: 'Garden Party',
      primaryColor: Color(0xFF82C785),
      secondaryColor: BirthdayTheme.softWhite,
      cardBackground: Color(0xFFF6FBF7),
      textColor: Color(0xFF2E4034),
      accentColor: Color(0xFF5A9E5D),
      fontType: 'jakarta',
      motifIcon: Icons.park_rounded,
      styleTag: 'Lush Botanical',
    ),
  ];

  // Selected Template
  int _selectedTemplateIndex = 0;

  // Color Override Swatches
  Color? _colorOverride;
  final List<Color?> _swatches = [
    null, // Default / template native
    const Color(0xFFB76E79), // Rose Gold
    const Color(0xFF2B3A67), // Royal Navy
    const Color(0xFF2D5A43), // Forest Emerald
    const Color(0xFF8B263E), // Burgundy Velvet
    const Color(0xFFC86D51), // Terracotta
    const Color(0xFF7B5294), // Royal Lavender
  ];

  // Customization Form Controllers
  late TextEditingController _titleController;
  late TextEditingController _nameController;
  late TextEditingController _dateTimeController;
  late TextEditingController _venueController;
  late TextEditingController _dressCodeController;
  late TextEditingController _rsvpController;
  late TextEditingController _messageController;

  final _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Birthday Celebration');
    _nameController = TextEditingController();
    _dateTimeController = TextEditingController(text: 'Saturday, Nov 15, 2026 • 7:00 PM');
    _venueController = TextEditingController(text: 'The Glasshouse Grand Lounge');
    _dressCodeController = TextEditingController(text: 'Smart Casual / Cocktail Attire');
    _rsvpController = TextEditingController(text: 'RSVP by Nov 5th • 01700-123456');
    _messageController = TextEditingController(
      text: 'Join us for an unforgettable evening of delicious dining, warm laughter, and celebration!',
    );

    // Listen to changes to trigger live preview rebuilds
    for (final controller in [
      _titleController,
      _nameController,
      _dateTimeController,
      _venueController,
      _dressCodeController,
      _rsvpController,
      _messageController,
    ]) {
      controller.addListener(() => setState(() {}));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final provider = Provider.of<BirthdayProvider>(context, listen: false);
      final activeEvent = provider.activeEvent;
      if (activeEvent != null) {
        if (_nameController.text.isEmpty) {
          _nameController.text = activeEvent.personName;
        }
        if (activeEvent.location.isNotEmpty) {
          _venueController.text = activeEvent.location;
        }
        final year = activeEvent.eventDate.year;
        final monthNames = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final month = monthNames[activeEvent.eventDate.month - 1];
        final day = activeEvent.eventDate.day;
        _dateTimeController.text = '$month $day, $year • 7:00 PM';

        if (activeEvent.age != null && activeEvent.age! > 0) {
          _titleController.text = "${activeEvent.age}th Birthday Celebration";
        }
      } else {
        if (_nameController.text.isEmpty) {
          _nameController.text = 'Sarah Jenkins';
        }
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _dateTimeController.dispose();
    _venueController.dispose();
    _dressCodeController.dispose();
    _rsvpController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  _InvitationTemplateConfig get _currentTemplate => _templates[_selectedTemplateIndex];

  Color get _activePrimaryColor => _colorOverride ?? _currentTemplate.primaryColor;
  Color get _activeAccentColor => _colorOverride ?? _currentTemplate.accentColor;

  // Composed text for sharing
  String _composeInvitationText() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "our special guest";
    final title = _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : "Birthday Celebration";
    final dateTime = _dateTimeController.text.trim();
    final venue = _venueController.text.trim();
    final dressCode = _dressCodeController.text.trim();
    final message = _messageController.text.trim();
    final rsvp = _rsvpController.text.trim();

    final buffer = StringBuffer();
    buffer.writeln("✨ You are invited to $name's $title! ✨");
    buffer.writeln();
    if (dateTime.isNotEmpty) buffer.writeln("📅 Date & Time: $dateTime");
    if (venue.isNotEmpty) buffer.writeln("📍 Venue: $venue");
    if (dressCode.isNotEmpty) buffer.writeln("👗 Dress Code: $dressCode");
    if (message.isNotEmpty) {
      buffer.writeln();
      buffer.writeln("\"$message\"");
    }
    if (rsvp.isNotEmpty) {
      buffer.writeln();
      buffer.writeln("RSVP: $rsvp");
    }
    buffer.writeln();
    buffer.writeln("We can't wait to celebrate together! 🥂🎂");
    return buffer.toString();
  }

  void _shareInvitation(BuildContext context) {
    final shareText = _composeInvitationText();
    Clipboard.setData(ClipboardData(text: shareText));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalCtx) => Container(
        decoration: const BoxDecoration(
          color: BirthdayTheme.softWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BirthdayTheme.successGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: BirthdayTheme.successGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invitation Copied to Clipboard!',
                        style: BirthdayTheme.heading3,
                      ),
                      Text(
                        'Ready to paste in WhatsApp, SMS, or Email',
                        style: BirthdayTheme.subtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BirthdayTheme.warmIvory,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BirthdayTheme.subtleBorder),
              ),
              child: Text(
                shareText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: BirthdayTheme.deepCocoa,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: shareText));
                      Navigator.of(modalCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied again to clipboard! 📋'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: BirthdayTheme.secondaryButton,
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(modalCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening Share Sheet / Ready to dispatch! 💌'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: BirthdayTheme.primaryButton,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invitation text copied to clipboard! 💌'),
        backgroundColor: BirthdayTheme.deepCocoa,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _saveDesign(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: BirthdayTheme.mutedGold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Invitation design "${_currentTemplate.name}" saved successfully! ✨',
                style: GoogleFonts.plusJakartaSans(
                  color: BirthdayTheme.softWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: BirthdayTheme.deepCocoa,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Preview',
          textColor: BirthdayTheme.mutedGold,
          onPressed: () => _showFullScreenPreview(context),
        ),
      ),
    );
  }

  void _showFullScreenPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            SingleChildScrollView(
              child: _buildLiveInvitationCard(isFullScreen: true),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: BirthdayTheme.deepCocoa.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: BirthdayTheme.softWhite, size: 20),
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: BirthdayTheme.mutedGold,
              onPrimary: BirthdayTheme.softWhite,
              onSurface: BirthdayTheme.deepCocoa,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 19, minute: 0),
        builder: (ctx, child) {
          return Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: BirthdayTheme.mutedGold,
                onPrimary: BirthdayTheme.softWhite,
                onSurface: BirthdayTheme.deepCocoa,
              ),
            ),
            child: child!,
          );
        },
      );

      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = monthNames[pickedDate.month - 1];
      final day = pickedDate.day;
      final year = pickedDate.year;

      String timeString = '7:00 PM';
      if (pickedTime != null) {
        final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
        final minute = pickedTime.minute.toString().padLeft(2, '0');
        final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
        timeString = '$hour:$minute $period';
      }

      setState(() {
        _dateTimeController.text = '$month $day, $year • $timeString';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayProvider>(
      builder: (context, provider, child) {
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
            title: Text(
              'Digital Invitation Studio',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: BirthdayTheme.deepCocoa,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Full Preview',
                icon: const Icon(Icons.fullscreen_rounded, color: BirthdayTheme.mutedGold, size: 24),
                onPressed: () => _showFullScreenPreview(context),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomActionBar(context),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Live Preview Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LIVE INVITATION CARD',
                          style: BirthdayTheme.label.copyWith(letterSpacing: 1.2),
                        ),
                        InkWell(
                          onTap: () => _showFullScreenPreview(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.zoom_in_rounded, size: 16, color: BirthdayTheme.mutedGold),
                                const SizedBox(width: 4),
                                Text(
                                  'Expand Card',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: BirthdayTheme.mutedGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // LIVE PREVIEW CARD
                    _buildLiveInvitationCard(),
                    const SizedBox(height: 24),

                    // SECTION 1: TEMPLATE SELECTOR (7 Templates)
                    Row(
                      children: [
                        const Icon(Icons.style_outlined, size: 18, color: BirthdayTheme.mutedGold),
                        const SizedBox(width: 8),
                        Text(
                          'Select Invitation Theme (7 Designs)',
                          style: BirthdayTheme.heading3.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTemplateSelector(),
                    const SizedBox(height: 20),

                    // SECTION 2: COLOR OVERRIDE SWATCHES
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined, size: 18, color: BirthdayTheme.mutedGold),
                        const SizedBox(width: 8),
                        Text(
                          'Accent Color Palette',
                          style: BirthdayTheme.heading3.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildColorSwatches(),
                    const SizedBox(height: 24),

                    // SECTION 3: CUSTOMIZATION FORM
                    Row(
                      children: [
                        const Icon(Icons.edit_note_rounded, size: 20, color: BirthdayTheme.mutedGold),
                        const SizedBox(width: 8),
                        Text(
                          'Customize Card Details',
                          style: BirthdayTheme.heading3.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCustomizationForm(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= LIVE INVITATION CARD =================
  Widget _buildLiveInvitationCard({bool isFullScreen = false}) {
    final template = _currentTemplate;
    final primary = _activePrimaryColor;
    final accent = _activeAccentColor;
    final cardBg = template.cardBackground;
    final textColor = template.textColor;
    final isPlayfair = template.fontType == 'playfair';

    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Birthday Star';
    final title = _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Birthday Celebration';
    final dateTime = _dateTimeController.text.trim().isNotEmpty ? _dateTimeController.text.trim() : 'Date & Time to be announced';
    final venue = _venueController.text.trim().isNotEmpty ? _venueController.text.trim() : 'Grand Celebration Hall';
    final dressCode = _dressCodeController.text.trim();
    final rsvp = _rsvpController.text.trim();
    final message = _messageController.text.trim();

    final textStyleTitle = isPlayfair
        ? GoogleFonts.playfairDisplay(
            fontSize: isFullScreen ? 28 : 22,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.5,
          )
        : GoogleFonts.plusJakartaSans(
            fontSize: isFullScreen ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.3,
          );

    final textStyleName = isPlayfair
        ? GoogleFonts.playfairDisplay(
            fontSize: isFullScreen ? 34 : 28,
            fontWeight: FontWeight.bold,
            color: primary,
            fontStyle: FontStyle.italic,
          )
        : GoogleFonts.plusJakartaSans(
            fontSize: isFullScreen ? 30 : 25,
            fontWeight: FontWeight.w800,
            color: primary,
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (template.isDark ? Colors.black : BirthdayTheme.deepCocoa).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle corner ornamental accents
          Positioned(
            top: 12,
            left: 12,
            child: Icon(template.motifIcon, size: 18, color: primary.withValues(alpha: 0.35)),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Icon(template.motifIcon, size: 18, color: primary.withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Icon(template.motifIcon, size: 18, color: primary.withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Icon(template.motifIcon, size: 18, color: primary.withValues(alpha: 0.35)),
          ),

          // Main Card Interior
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isFullScreen ? 28 : 20,
              vertical: isFullScreen ? 32 : 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top decorative badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(template.motifIcon, size: 14, color: primary),
                      const SizedBox(width: 6),
                      Text(
                        "YOU'RE CORDIALLY INVITED",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Event Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textStyleTitle,
                ),
                const SizedBox(height: 4),

                Text(
                  'IN HONOR OF',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),

                // Birthday Person's Name
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: textStyleName,
                ),
                const SizedBox(height: 12),

                // Ornamental Divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 1, color: primary.withValues(alpha: 0.4)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(template.motifIcon, size: 14, color: accent),
                    ),
                    Container(width: 40, height: 1, color: primary.withValues(alpha: 0.4)),
                  ],
                ),
                const SizedBox(height: 16),

                // Personal Message Box
                if (message.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: template.secondaryColor.withValues(alpha: template.isDark ? 0.08 : 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '"$message"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: textColor.withValues(alpha: 0.85),
                        height: 1.45,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Details Grid: Date & Venue
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: template.secondaryColor.withValues(alpha: template.isDark ? 0.06 : 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Date & Time
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.calendar_month_rounded, size: 16, color: primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DATE & TIME',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: primary,
                                  ),
                                ),
                                Text(
                                  dateTime,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Venue
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.location_on_rounded, size: 16, color: primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VENUE & LOCATION',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: primary,
                                  ),
                                ),
                                Text(
                                  venue,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Dress Code if provided
                      if (dressCode.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.checkroom_rounded, size: 16, color: primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DRESS CODE',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                      color: primary,
                                    ),
                                  ),
                                  Text(
                                    dressCode,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // RSVP Details at bottom
                if (rsvp.isNotEmpty)
                  Text(
                    'RSVP: $rsvp',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.75),
                      letterSpacing: 0.3,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TEMPLATE SELECTOR =================
  Widget _buildTemplateSelector() {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _templates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tmpl = _templates[index];
          final isSelected = _selectedTemplateIndex == index;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedTemplateIndex = index;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 135,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? BirthdayTheme.softWhite : BirthdayTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? tmpl.primaryColor : BirthdayTheme.subtleBorder,
                  width: isSelected ? 2 : 0.8,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: tmpl.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Color Swatch Pill
                      Container(
                        width: 32,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [tmpl.primaryColor, tmpl.secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: BirthdayTheme.subtleBorder, width: 0.5),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, size: 16, color: tmpl.primaryColor)
                      else
                        Icon(tmpl.motifIcon, size: 14, color: BirthdayTheme.deepCocoa.withValues(alpha: 0.4)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tmpl.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: BirthdayTheme.deepCocoa,
                        ),
                      ),
                      Text(
                        tmpl.styleTag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= COLOR OVERRIDE SWATCHES =================
  Widget _buildColorSwatches() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _swatches.map((color) {
          final isDefault = color == null;
          final isSelected = _colorOverride == color;
          final displayColor = color ?? _currentTemplate.primaryColor;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _colorOverride = color;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? displayColor.withValues(alpha: 0.15) : BirthdayTheme.softWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? displayColor : BirthdayTheme.subtleBorder,
                    width: isSelected ? 1.6 : 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: displayColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: BirthdayTheme.softWhite, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: isDefault
                          ? const Center(
                              child: Icon(Icons.auto_awesome, size: 9, color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDefault ? 'Template Default' : _getColorName(color),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: BirthdayTheme.deepCocoa,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == const Color(0xFFB76E79)) return 'Rose Gold';
    if (color == const Color(0xFF2B3A67)) return 'Royal Navy';
    if (color == const Color(0xFF2D5A43)) return 'Emerald';
    if (color == const Color(0xFF8B263E)) return 'Burgundy';
    if (color == const Color(0xFFC86D51)) return 'Terracotta';
    if (color == const Color(0xFF7B5294)) return 'Lavender';
    return 'Custom';
  }

  // ================= CUSTOMIZATION FORM =================
  Widget _buildCustomizationForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BirthdayTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Event Title
          TextFormField(
            controller: _titleController,
            style: BirthdayTheme.body,
            decoration: BirthdayTheme.inputDecoration(
              'Event Title',
              hint: 'e.g., 25th Birthday Celebration',
              icon: Icons.title_rounded,
            ),
          ),
          const SizedBox(height: 12),

          // Birthday Person Name
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: BirthdayTheme.body,
            decoration: BirthdayTheme.inputDecoration(
              "Birthday Person's Name",
              hint: 'e.g., Sarah Jenkins',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 12),

          // Date & Time Picker
          TextFormField(
            controller: _dateTimeController,
            style: BirthdayTheme.body,
            decoration: BirthdayTheme.inputDecoration(
              'Date & Time',
              hint: 'e.g., Saturday, Nov 15, 2026 • 7:00 PM',
              icon: Icons.access_time_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit_calendar_rounded, color: BirthdayTheme.mutedGold),
                tooltip: 'Select Date & Time',
                onPressed: () => _pickDateTime(context),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Venue
          TextFormField(
            controller: _venueController,
            style: BirthdayTheme.body,
            decoration: BirthdayTheme.inputDecoration(
              'Venue & Location',
              hint: 'e.g., The Glasshouse, Gulshan-2, Dhaka',
              icon: Icons.place_outlined,
            ),
          ),
          const SizedBox(height: 12),

          // Dress Code
          TextFormField(
            controller: _dressCodeController,
            style: BirthdayTheme.body,
            decoration: BirthdayTheme.inputDecoration(
              'Dress Code',
              hint: 'e.g., Smart Casual / Elegant Pastel',
              icon: Icons.checkroom_outlined,
            ),
          ),
          const SizedBox(height: 12),

          // RSVP Details
          TextFormField(
            controller: _rsvpController,
            style: BirthdayTheme.body,
            decoration: BirthdayTheme.inputDecoration(
              'RSVP Details',
              hint: 'e.g., RSVP by Nov 5th • 01700-000000',
              icon: Icons.mark_email_read_outlined,
            ),
          ),
          const SizedBox(height: 12),

          // Personal Message
          TextFormField(
            controller: _messageController,
            maxLines: 3,
            style: BirthdayTheme.body,
            decoration: BirthdayTheme.inputDecoration(
              'Personal Message / Note to Guests',
              hint: 'Share warm sentiments, expectations, or a joyful quote...',
              icon: Icons.format_quote_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BOTTOM ACTIONS BAR =================
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: BirthdayTheme.softWhite,
        border: const Border(top: BorderSide(color: BirthdayTheme.subtleBorder, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: BirthdayTheme.deepCocoa.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Share Invitation Button
            Expanded(
              flex: 5,
              child: OutlinedButton.icon(
                onPressed: () => _shareInvitation(context),
                style: BirthdayTheme.secondaryButton.copyWith(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Share Card'),
              ),
            ),
            const SizedBox(width: 12),

            // Save Design Button
            Expanded(
              flex: 6,
              child: ElevatedButton.icon(
                onPressed: () => _saveDesign(context),
                style: BirthdayTheme.primaryButton.copyWith(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                icon: const Icon(Icons.bookmark_added_rounded, size: 18),
                label: const Text('Save Design'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
