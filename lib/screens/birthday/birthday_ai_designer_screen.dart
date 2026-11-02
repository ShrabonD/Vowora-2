import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/birthday_theme.dart';
import '../../providers/birthday_provider.dart';

/// AI Birthday Designer - a template-based recommendation engine.
/// Synthesizes inputs into a 10-section birthday celebration blueprint.
class BirthdayAiDesignerScreen extends StatefulWidget {
  const BirthdayAiDesignerScreen({super.key});

  @override
  State<BirthdayAiDesignerScreen> createState() => _BirthdayAiDesignerScreenState();
}

class _BirthdayAiDesignerScreenState extends State<BirthdayAiDesignerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  final TextEditingController _ageController = TextEditingController(text: '25');
  final TextEditingController _interestsController = TextEditingController(
    text: 'Acoustic indie music, artisan coffee tasting, analog photography, cozy aesthetics',
  );
  final TextEditingController _budgetController = TextEditingController(text: '45000');
  final TextEditingController _guestCountController = TextEditingController(text: '25');

  // Dropdown selections
  static const List<String> _themes = [
    'Minimal Classy',
    'Champagne & Gold',
    'Blush & Ivory',
    'Garden Romance',
    'Pastel Dream',
    'Royal Celebration',
    'Black & Gold',
    'Floral Elegance',
    "Kids' Wonderland",
    'Gaming Party',
    'K-pop Inspired',
    'Tropical Summer',
  ];

  static const List<String> _venues = [
    'Indoor Banquet / Hall',
    'Rooftop Lounge',
    'Lush Garden / Lawn',
    'Cozy Home / Backyard',
    'Boutique Cafe / Restaurant',
    'Poolside Villa',
  ];

  static const List<String> _celebrationStyles = [
    'Understated & Classy',
    'Opulent & Luxurious',
    'Intimate & Heartfelt',
    'High-Energy & Fun',
    'Surprise Party',
    'Artistic & Aesthetic',
  ];

  String _selectedTheme = 'Champagne & Gold';
  String _selectedVenue = 'Indoor Banquet / Hall';
  String _selectedStyle = 'Understated & Classy';

  bool _isGenerating = false;
  Map<String, dynamic>? _generatedPlan;
  final Set<int> _checkedChecklistItems = {};
  bool _isInputExpanded = true;

  @override
  void dispose() {
    _ageController.dispose();
    _interestsController.dispose();
    _budgetController.dispose();
    _guestCountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrency(num amount) {
    final integerPart = amount.round().toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '৳$formatted';
  }

  Color _parseHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return BirthdayTheme.mutedGold;
    }
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isGenerating = true;
    });

    // Simulate local AI generation delay (500-600ms)
    await Future.delayed(const Duration(milliseconds: 650));

    final plan = _generatePlan();

    if (mounted) {
      setState(() {
        _generatedPlan = plan;
        _isGenerating = false;
        _isInputExpanded = false;
        _checkedChecklistItems.clear();
      });

      // Smooth scroll down to blueprint
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            450,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  /// Template-based local recommendation generator
  Map<String, dynamic> _generatePlan() {
    final ageText = _ageController.text.trim();
    final rawAge = int.tryParse(RegExp(r'\d+').stringMatch(ageText) ?? '') ?? 25;
    final budget = double.tryParse(_budgetController.text.replaceAll(',', '').trim()) ?? 45000.0;
    final guestCount = int.tryParse(_guestCountController.text.trim()) ?? 25;
    final interests = _interestsController.text.trim();

    // 1. Theme Rationale & Tagline
    String themeTitle = _selectedTheme;
    String themeTagline;
    String themeRationale;

    if (rawAge <= 12) {
      themeTagline = 'A whimsical, vibrant adventure filled with wonder and childhood laughter.';
      themeRationale = 'Tailored for an unforgettable young milestone with interactive magic and high joy.';
    } else if (rawAge <= 19) {
      themeTagline = 'Trendy, dynamic, and aesthetic celebration designed for memorable photos and close friends.';
      themeRationale = 'Focused on visual aesthetic, music energy, and interactive hangout zones.';
    } else if (rawAge >= 50) {
      themeTagline = 'A distinguished golden milestone honoring memories, cherished legacy, and loved ones.';
      themeRationale = 'Emphasizes warmth, elevated comfort, heartfelt speeches, and timeless grace.';
    } else {
      themeTagline = 'A sophisticated celebration balancing refined ambiance with joyful camaraderie.';
      themeRationale = 'Designed around your interest in "$interests", hosting $guestCount guests at a $_selectedVenue in $_selectedStyle fashion.';
    }

    // 2. Color Palette matching theme
    List<Map<String, String>> palette;
    switch (_selectedTheme) {
      case 'Minimal Classy':
        palette = [
          {'name': 'Warm Ivory', 'hex': '#F8F3EE'},
          {'name': 'Champagne Beige', 'hex': '#E8D8CC'},
          {'name': 'Muted Gold', 'hex': '#B28A63'},
          {'name': 'Deep Cocoa', 'hex': '#382923'},
        ];
        break;
      case 'Champagne & Gold':
        palette = [
          {'name': 'Champagne Gold', 'hex': '#F5E6AB'},
          {'name': 'Muted Gold', 'hex': '#B28A63'},
          {'name': 'Warm Pearl', 'hex': '#FAF6F0'},
          {'name': 'Antique Bronze', 'hex': '#8C6D46'},
        ];
        break;
      case 'Blush & Ivory':
        palette = [
          {'name': 'Soft Blush', 'hex': '#FAD2E1'},
          {'name': 'Warm Ivory', 'hex': '#FFFBF7'},
          {'name': 'Rose Beige', 'hex': '#D9B7A7'},
          {'name': 'Dusty Rose', 'hex': '#C47B89'},
        ];
        break;
      case 'Garden Romance':
        palette = [
          {'name': 'Sage Olive', 'hex': '#588157'},
          {'name': 'Moss Green', 'hex': '#3A5A40'},
          {'name': 'Warm Ivory', 'hex': '#F8F3EE'},
          {'name': 'Buttercream', 'hex': '#E9D8A6'},
        ];
        break;
      case 'Pastel Dream':
        palette = [
          {'name': 'Cloud Pink', 'hex': '#FFC8DD'},
          {'name': 'Baby Blue', 'hex': '#BDE0FE'},
          {'name': 'Lavender Mist', 'hex': '#CDB4DB'},
          {'name': 'Pastel Lemon', 'hex': '#FDFFB6'},
        ];
        break;
      case 'Royal Celebration':
        palette = [
          {'name': 'Royal Plum', 'hex': '#2B1E4A'},
          {'name': 'Opulent Gold', 'hex': '#D4AF37'},
          {'name': 'Velvet Navy', 'hex': '#141B41'},
          {'name': 'Silk Cream', 'hex': '#F4EBD9'},
        ];
        break;
      case 'Black & Gold':
        palette = [
          {'name': 'Noir Black', 'hex': '#121212'},
          {'name': 'Shimmer Gold', 'hex': '#D4AF37'},
          {'name': 'Slate Charcoal', 'hex': '#2E2E3A'},
          {'name': 'Ivory Silk', 'hex': '#F9F5EC'},
        ];
        break;
      case 'Floral Elegance':
        palette = [
          {'name': 'Vintage Mauve', 'hex': '#E5989B'},
          {'name': 'Petal Pink', 'hex': '#B5838D'},
          {'name': 'Warm Ivory', 'hex': '#F8F3EE'},
          {'name': 'Soft Moss', 'hex': '#6D6875'},
        ];
        break;
      case "Kids' Wonderland":
        palette = [
          {'name': 'Coral Red', 'hex': '#FF5964'},
          {'name': 'Sky Blue', 'hex': '#35A7FF'},
          {'name': 'Sunflower Yellow', 'hex': '#FFE74C'},
          {'name': 'Apple Green', 'hex': '#38B000'},
        ];
        break;
      case 'Gaming Party':
        palette = [
          {'name': 'Neon Cyan', 'hex': '#00F5D4'},
          {'name': 'Cyber Violet', 'hex': '#7B2CBF'},
          {'name': 'Neon Magenta', 'hex': '#F72585'},
          {'name': 'Dark Arcade', 'hex': '#0F0E17'},
        ];
        break;
      case 'K-pop Inspired':
        palette = [
          {'name': 'Lightstick Pink', 'hex': '#F72585'},
          {'name': 'Idol Purple', 'hex': '#7209B7'},
          {'name': 'Neon Cyan', 'hex': '#4CC9F0'},
          {'name': 'Stage White', 'hex': '#FFFFFF'},
        ];
        break;
      case 'Tropical Summer':
      default:
        palette = [
          {'name': 'Palm Teal', 'hex': '#06D6A0'},
          {'name': 'Sunset Amber', 'hex': '#FFD166'},
          {'name': 'Hibiscus Coral', 'hex': '#EF476F'},
          {'name': 'Ocean Breeze', 'hex': '#118AB2'},
        ];
        break;
    }

    // 3. Decoration Plan (bullet list)
    final decorationPlan = [
      'Statement organic balloon & floral installation tailored to $_selectedTheme hues framing the entry.',
      'Custom frosted acrylic welcome board with golden laser lettering set on a display easel.',
      'Fairy lights canopy with soft micro-LED warm illumination for cozy evening atmosphere.',
      'Curated table styling with linen runners, brass candle votives, and personalized name place cards.',
      'Dedicated Instagram-worthy photo wall with thematic floral accents and custom birthday neon signage.',
      'Ambient spotlighting accentuating the cake podium and memory gallery board.',
    ];

    // 4. Cake Recommendations
    Map<String, String> cake;
    if (rawAge <= 12) {
      cake = {
        'type': 'Whimsical 2-Tier Buttercream & Fondant Cake',
        'flavor': 'Vanilla Rainbow Confetti with White Chocolate Ganache',
        'size': '${(guestCount * 0.1).clamp(1.5, 5.0).toStringAsFixed(1)} kg ($guestCount portions)',
        'design': 'Topped with playful thematic figurine toppers, candy drips, and sparkler number candles.',
      };
    } else if (_selectedTheme == 'Black & Gold' || _selectedTheme == 'Royal Celebration') {
      cake = {
        'type': 'Multi-Tier Sculpted Ganache & Geode Cake',
        'flavor': 'Belgian Dark Chocolate Fudge with Salted Caramel & Roasted Almonds',
        'size': '${(guestCount * 0.1).clamp(1.5, 6.0).toStringAsFixed(1)} kg ($guestCount portions)',
        'design': 'Matte surface highlighted with edible 24k gold leaf streaks and subtle textured stone detailing.',
      };
    } else {
      cake = {
        'type': 'Semi-Naked Textured Buttercream Floral Cake',
        'flavor': 'Earl Grey Infused Sponge with Citrus Lemon Curd & Cream Cheese Frosting',
        'size': '${(guestCount * 0.1).clamp(1.5, 4.5).toStringAsFixed(1)} kg ($guestCount portions)',
        'design': 'Decorated with fresh organic spray roses, dried eucalyptus, and a custom acrylic gold topper.',
      };
    }

    // 5. Food & Catering Ideas (3-4 suggestions)
    final foodIdeas = [
      {
        'title': 'Canapés & Welcome Hors d\'œuvres',
        'desc': 'Mini smoked chicken bruschetta, truffled wild mushroom tarts, and glazed paneer skewers on arrival.',
      },
      {
        'title': 'Signature Mocktail & Beverage Station',
        'desc': 'Crafted Rosemary Citrus Fizz, Sparkling Lavender Lemonade, and Fresh Mint Mojitos served in crystal glassware.',
      },
      {
        'title': 'Main Celebration Feast',
        'desc': 'Saffron-infused mutton kacchi biryani, butter chicken with herb naan, garlic rosemary roast, and seasonal garden salad.',
      },
      {
        'title': 'Artisanal Dessert & Coffee Bar',
        'desc': 'Assorted French macarons, warm fudge brownie bites with gelato, and freshly brewed pour-over artisan coffee.',
      },
    ];

    // 6. Gift Suggestions (3-5 items based on age & interests)
    List<Map<String, String>> giftSuggestions;
    if (rawAge <= 12) {
      giftSuggestions = [
        {'title': 'Interactive STEM Robotic Kit', 'desc': 'Engaging, hands-on building & coding educational set.'},
        {'title': 'Illustrated Deluxe Storybook Anthology', 'desc': 'Hardcover personalized fantasy adventure collection.'},
        {'title': 'Instax Junior Instant Camera', 'desc': 'Child-friendly instant print camera with fun sticker film rolls.'},
        {'title': 'Themed Kids Smart Adventure Watch', 'desc': 'Fun game-enabled fitness and safety tracker watch.'},
      ];
    } else if (rawAge <= 20) {
      giftSuggestions = [
        {'title': 'Fujifilm Instax Mini Hybrid Camera', 'desc': 'Instant snapshot camera with custom leather strap & filters.'},
        {'title': 'Bose SoundLink Portable Speaker', 'desc': 'High-fidelity water-resistant Bluetooth audio for hangouts.'},
        {'title': 'Customized Aesthetic Vinyl Record Art', 'desc': 'Framed metallic record etched with favorite playlist tracklist.'},
        {'title': 'Premium Tech Desk / Gaming Mat & Earbuds', 'desc': 'Ergonomic accessories customized with initials.'},
      ];
    } else if (rawAge >= 50) {
      giftSuggestions = [
        {'title': 'Personalized Bound Leather Memory Album', 'desc': 'Archival gold-foiled photo book filled with family memories.'},
        {'title': 'Artisanal Cashmere / Silk Shawl', 'desc': 'Handwoven luxury warmth in timeless natural ivory tones.'},
        {'title': 'Premium Single-Origin Tea / Coffee Caddy Set', 'desc': 'Curated reserve teas paired with a handcrafted ceramic teapot.'},
        {'title': 'Custom Engraved Brass Timepiece', 'desc': 'Heirloom desk clock with commemorative anniversary inscription.'},
      ];
    } else {
      giftSuggestions = [
        {'title': 'Artisan Pour-Over Brewing Chemex Set', 'desc': 'Handcrafted glass dripper with single-origin specialty roast beans.'},
        {'title': 'Leather-Bound Commemorative Journal & Pen', 'desc': 'Full-grain vintage notebook engraved with initials and milestone date.'},
        {'title': 'Marshall Emberton II Vintage Bluetooth Speaker', 'desc': 'Iconic retro design delivering 360-degree immersive acoustic sound.'},
        {'title': 'Custom Star Map Night Sky Art Frame', 'desc': 'High-resolution astronomy chart depicting the exact night sky of their birth date.'},
        {'title': 'Curated Sensory Spa & Scented Candle Box', 'desc': 'Hand-poured soy candles, cedarwood bath salts, and botanical oils.'},
      ];
    }

    // 7. Entertainment Ideas (2-3 activities)
    final entertainment = [
      {
        'title': 'Acoustic Serenade & Curated Live Music',
        'desc': 'A 45-minute intimate live acoustic performance featuring the celebrant\'s favorite tracks and acoustic covers.',
      },
      {
        'title': 'Personalized Birthday Roast & Toast Trivia',
        'desc': 'A lighthearted interactive guest quiz via phone/trivia cards with nostalgic questions about the celebrant.',
      },
      {
        'title': 'Instant Polaroid Guestbook Station',
        'desc': 'Guests take candid instant snaps, stick them into a luxury guestbook, and write heartfelt handwritten notes.',
      },
    ];

    // 8. Shopping Checklist (10-12 items)
    final shoppingChecklist = [
      'Custom acrylic or fabric birthday backdrop banner',
      'Themed color balloon arch garland kit with pump',
      'Metallic numeral candles and safety ice sparklers',
      'Fairy string lights / LED ambient curtain warm lights',
      'Linen table runners & matching cloth napkins',
      'Ceramic / metallic dessert display stands and cake podium',
      'Biodegradable themed dessert plates, glasses, and gold cutlery',
      'Photo booth handheld props & polaroid photo frame cutout',
      'Polaroid film twin packs (minimum 40 exposures)',
      'Aesthetic guest sign-in book with metallic ink pens',
      'Personalized party favor gift bags & thank-you tags',
      'Setup emergency kit (heavy-duty tape, hooks, scissors & wire)',
    ];

    // 9. Estimated Cost Breakdown (per category)
    final decorShare = (budget * 0.28).roundToDouble();
    final cakeShare = (budget * 0.12).roundToDouble();
    final foodShare = (budget * 0.36).roundToDouble();
    final entertainmentShare = (budget * 0.14).roundToDouble();
    final favorsMiscShare = (budget - decorShare - cakeShare - foodShare - entertainmentShare);

    final costBreakdown = [
      {'category': 'Decor & Theme Styling', 'amount': decorShare, 'percent': '28%'},
      {'category': 'Catering & Beverages Feasts', 'amount': foodShare, 'percent': '36%'},
      {'category': 'Designer Birthday Cake & Sweets', 'amount': cakeShare, 'percent': '12%'},
      {'category': 'Entertainment & Audio/Visual', 'amount': entertainmentShare, 'percent': '14%'},
      {'category': 'Favors, Guestbook & Essentials', 'amount': favorsMiscShare, 'percent': '10%'},
    ];

    // 10. Event-Day Schedule (6-8 time slots)
    final schedule = [
      {'time': '02:30 PM', 'title': 'Venue Access & Decor Assembly', 'desc': 'Balloon styling, floral placement, and photo backdrop setup.'},
      {'time': '04:00 PM', 'title': 'Cake Delivery & Dessert Staging', 'desc': 'Safe temperature check, dessert table styling, and cake placement.'},
      {'time': '05:00 PM', 'title': 'Audio & Ambient Light Inspection', 'desc': 'Background playlist activation, warm lighting adjustment, and host readiness.'},
      {'time': '05:30 PM', 'title': 'Guest Arrival & Welcome Mocktails', 'desc': 'Welcome drinks served, polaroid guestbook snaps, and warm mingling.'},
      {'time': '06:45 PM', 'title': 'Interactive Birthday Trivia & Games', 'desc': 'Personalized trivia quiz and funny memory sharing with prizes.'},
      {'time': '07:30 PM', 'title': 'Grand Cake Cutting Ceremony', 'desc': 'Candle lighting, birthday chorus, cold sparklers, and photo moments.'},
      {'time': '08:00 PM', 'title': 'Buffet Dinner & Chill Acoustic Set', 'desc': 'Dinner buffet opens with soft acoustic background melodies.'},
      {'time': '09:30 PM', 'title': 'Favor Gift Bags & Warm Farewells', 'desc': 'Guests receive curated favors, group photos, and final warm toasts.'},
    ];

    return {
      'themeTitle': themeTitle,
      'themeTagline': themeTagline,
      'themeRationale': themeRationale,
      'palette': palette,
      'decorationPlan': decorationPlan,
      'cake': cake,
      'foodIdeas': foodIdeas,
      'giftSuggestions': giftSuggestions,
      'entertainment': entertainment,
      'shoppingChecklist': shoppingChecklist,
      'costBreakdown': costBreakdown,
      'schedule': schedule,
      'totalBudget': budget,
      'guestCount': guestCount,
    };
  }

  void _savePlanToProvider() {
    if (_generatedPlan == null) return;

    final provider = Provider.of<BirthdayProvider>(context, listen: false);
    final activeEvent = provider.activeEvent;

    if (activeEvent != null) {
      activeEvent.theme = _generatedPlan!['themeTitle'] as String;
      activeEvent.totalBudget = _generatedPlan!['totalBudget'] as double;
      provider.updateEvent(activeEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Birthday blueprint saved to "${activeEvent.personName}\'s Birthday"!',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: BirthdayTheme.mutedGold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Birthday Blueprint saved successfully! (No active event bound)',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: BirthdayTheme.mutedGold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BirthdayTheme.warmIvory,
      appBar: AppBar(
        backgroundColor: BirthdayTheme.warmIvory,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: BirthdayTheme.deepCocoa, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI Birthday Designer',
          style: BirthdayTheme.heading3,
        ),
        actions: [
          IconButton(
            tooltip: 'Designer Info',
            icon: const Icon(Icons.info_outline_rounded, color: BirthdayTheme.mutedGold),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: BirthdayTheme.cardBg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: BirthdayTheme.mutedGold, size: 24),
                      const SizedBox(width: 8),
                      Text('About AI Designer', style: BirthdayTheme.heading3),
                    ],
                  ),
                  content: Text(
                    'Our recommendation engine analyzes your milestone age, personal hobbies, preferred aesthetic, and budget to generate a full 10-point celebration blueprint right on your device.',
                    style: BirthdayTheme.body,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Got It', style: GoogleFonts.plusJakartaSans(color: BirthdayTheme.mutedGold, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroHeader(),
            const SizedBox(height: 16),
            _buildInputFormCard(),
            const SizedBox(height: 20),
            if (_isGenerating) _buildLoadingCard(),
            if (!_isGenerating && _generatedPlan != null) ...[
              _buildGeneratedBlueprintHeader(),
              const SizedBox(height: 16),
              _buildBlueprintSection1Theme(),
              const SizedBox(height: 14),
              _buildBlueprintSection2Palette(),
              const SizedBox(height: 14),
              _buildBlueprintSection3Decor(),
              const SizedBox(height: 14),
              _buildBlueprintSection4Cake(),
              const SizedBox(height: 14),
              _buildBlueprintSection5Food(),
              const SizedBox(height: 14),
              _buildBlueprintSection6Gifts(),
              const SizedBox(height: 14),
              _buildBlueprintSection7Entertainment(),
              const SizedBox(height: 14),
              _buildBlueprintSection8Checklist(),
              const SizedBox(height: 14),
              _buildBlueprintSection9CostBreakdown(),
              const SizedBox(height: 14),
              _buildBlueprintSection10Schedule(),
              const SizedBox(height: 24),
              _buildBottomActionButtons(),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BirthdayTheme.champagneBeige.withValues(alpha: 0.6),
            BirthdayTheme.roseBeige.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BirthdayTheme.subtleBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: BirthdayTheme.deepCocoa.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: BirthdayTheme.mutedGold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tailored Birthday Concept Engine',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: BirthdayTheme.deepCocoa,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Describe your milestone celebration to generate a complete styling and planning blueprint.',
                  style: BirthdayTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFormCard() {
    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isInputExpanded = !_isInputExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: BirthdayTheme.mutedGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Celebration Parameters',
                          style: BirthdayTheme.heading3.copyWith(fontSize: 17),
                        ),
                      ],
                    ),
                    Icon(
                      _isInputExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: BirthdayTheme.deepCocoa,
                    ),
                  ],
                ),
              ),
            ),
            if (_isInputExpanded) ...[
              const Divider(height: 24, color: BirthdayTheme.subtleBorder),
              const SizedBox(height: 4),
              // Age and Guest Count in a Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.text,
                      style: BirthdayTheme.body,
                      decoration: BirthdayTheme.inputDecoration(
                        'Age / Milestone',
                        hint: 'e.g. 25, 1st, 50th',
                        icon: Icons.cake_outlined,
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter age' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _guestCountController,
                      keyboardType: TextInputType.number,
                      style: BirthdayTheme.body,
                      decoration: BirthdayTheme.inputDecoration(
                        'Guest Count',
                        hint: 'e.g. 30',
                        icon: Icons.people_outline_rounded,
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter guests' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Total Budget with ৳
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                style: BirthdayTheme.body,
                decoration: InputDecoration(
                  labelText: 'Total Budget (৳)',
                  hintText: '45,000',
                  prefixText: '৳ ',
                  prefixStyle: GoogleFonts.plusJakartaSans(
                    color: BirthdayTheme.mutedGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: BirthdayTheme.mutedGold, size: 20),
                  labelStyle: GoogleFonts.plusJakartaSans(color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6), fontSize: 13),
                  hintStyle: GoogleFonts.plusJakartaSans(color: BirthdayTheme.deepCocoa.withValues(alpha: 0.3), fontSize: 14),
                  filled: true,
                  fillColor: BirthdayTheme.warmIvory,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: BirthdayTheme.subtleBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: BirthdayTheme.subtleBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: BirthdayTheme.mutedGold, width: 1.5),
                  ),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter budget' : null,
              ),
              const SizedBox(height: 14),
              // Personality & Interests (multiline)
              TextFormField(
                controller: _interestsController,
                minLines: 2,
                maxLines: 4,
                style: BirthdayTheme.body,
                decoration: BirthdayTheme.inputDecoration(
                  'Personality & Interests',
                  hint: 'e.g. Loves indie acoustic music, artisan coffee, polaroids, travel...',
                  icon: Icons.favorite_border_rounded,
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter some interests' : null,
              ),
              const SizedBox(height: 14),
              // Preferred Theme (Dropdown of 12 themes)
              DropdownButtonFormField<String>(
                initialValue: _selectedTheme,
                icon: const Icon(Icons.arrow_drop_down, color: BirthdayTheme.mutedGold),
                decoration: BirthdayTheme.inputDecoration(
                  'Preferred Theme',
                  icon: Icons.palette_outlined,
                ),
                dropdownColor: BirthdayTheme.cardBg,
                style: BirthdayTheme.body,
                items: _themes.map((theme) {
                  return DropdownMenuItem<String>(
                    value: theme,
                    child: Text(theme, style: BirthdayTheme.body),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTheme = val);
                },
              ),
              const SizedBox(height: 14),
              // Venue Type (Dropdown)
              DropdownButtonFormField<String>(
                initialValue: _selectedVenue,
                icon: const Icon(Icons.arrow_drop_down, color: BirthdayTheme.mutedGold),
                decoration: BirthdayTheme.inputDecoration(
                  'Venue Type',
                  icon: Icons.location_on_outlined,
                ),
                dropdownColor: BirthdayTheme.cardBg,
                style: BirthdayTheme.body,
                items: _venues.map((v) {
                  return DropdownMenuItem<String>(
                    value: v,
                    child: Text(v, style: BirthdayTheme.body),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedVenue = val);
                },
              ),
              const SizedBox(height: 14),
              // Celebration Style (Dropdown)
              DropdownButtonFormField<String>(
                initialValue: _selectedStyle,
                icon: const Icon(Icons.arrow_drop_down, color: BirthdayTheme.mutedGold),
                decoration: BirthdayTheme.inputDecoration(
                  'Celebration Style',
                  icon: Icons.celebration_outlined,
                ),
                dropdownColor: BirthdayTheme.cardBg,
                style: BirthdayTheme.body,
                items: _celebrationStyles.map((s) {
                  return DropdownMenuItem<String>(
                    value: s,
                    child: Text(s, style: BirthdayTheme.body),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStyle = val);
                },
              ),
              const SizedBox(height: 20),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _handleGenerate,
                  style: BirthdayTheme.primaryButton,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                  label: Text('Generate Birthday Plan', style: BirthdayTheme.buttonText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BirthdayTheme.cardDecoration,
      child: Column(
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(BirthdayTheme.mutedGold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Synthesizing Your Celebration Blueprint...',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: BirthdayTheme.deepCocoa,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Analyzing themes, guest proportions, menus, and shopping essentials',
            textAlign: TextAlign.center,
            style: BirthdayTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedBlueprintHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BirthdayTheme.mutedGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BirthdayTheme.mutedGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: BirthdayTheme.mutedGold, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI-Powered Suggestions (Generated locally based on your preferences)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: BirthdayTheme.deepCocoa,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader({required IconData icon, required String title, String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BirthdayTheme.champagneBeige.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: BirthdayTheme.mutedGold, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: BirthdayTheme.heading3),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: BirthdayTheme.bodySmall),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // 1. Suggested Party Theme
  Widget _buildBlueprintSection1Theme() {
    final themeTitle = _generatedPlan!['themeTitle'] as String;
    final themeTagline = _generatedPlan!['themeTagline'] as String;
    final themeRationale = _generatedPlan!['themeRationale'] as String;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.auto_awesome,
            title: '1. Recommended Party Theme',
            subtitle: 'Curated for your aesthetic & guest atmosphere',
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [BirthdayTheme.champagneBeige.withValues(alpha: 0.4), BirthdayTheme.roseBeige.withValues(alpha: 0.2)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BirthdayTheme.subtleBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.diamond_outlined, color: BirthdayTheme.mutedGold, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      themeTitle,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: BirthdayTheme.deepCocoa,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '"$themeTagline"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: BirthdayTheme.deepCocoa.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(themeRationale, style: BirthdayTheme.body),
        ],
      ),
    );
  }

  // 2. Color Palette
  Widget _buildBlueprintSection2Palette() {
    final palette = _generatedPlan!['palette'] as List<Map<String, String>>;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.palette_outlined,
            title: '2. Curated Color Palette',
            subtitle: 'Harmonious shades for linens, florals & lighting',
          ),
          const SizedBox(height: 14),
          Row(
            children: palette.map((item) {
              final color = _parseHex(item['hex']!);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: BirthdayTheme.subtleBorder, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: BirthdayTheme.deepCocoa.withValues(alpha: 0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['name']!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BirthdayTheme.deepCocoa,
                        ),
                      ),
                      Text(
                        item['hex']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 3. Decoration Plan
  Widget _buildBlueprintSection3Decor() {
    final decorationPlan = _generatedPlan!['decorationPlan'] as List<String>;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.yard_outlined,
            title: '3. Decoration & Styling Plan',
            subtitle: 'Key visual accents & environmental setup',
          ),
          const SizedBox(height: 12),
          ...decorationPlan.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4, right: 10),
                    child: Icon(Icons.check_circle_outline_rounded, color: BirthdayTheme.mutedGold, size: 16),
                  ),
                  Expanded(
                    child: Text(item, style: BirthdayTheme.body),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 4. Cake Recommendations
  Widget _buildBlueprintSection4Cake() {
    final cake = _generatedPlan!['cake'] as Map<String, String>;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.cake_outlined,
            title: '4. Cake & Confectionery Design',
            subtitle: 'Type, flavors, portioning and visual styling',
          ),
          const SizedBox(height: 14),
          _buildInfoRow('Cake Concept', cake['type']!),
          const SizedBox(height: 8),
          _buildInfoRow('Flavor Profile', cake['flavor']!),
          const SizedBox(height: 8),
          _buildInfoRow('Recommended Size', cake['size']!),
          const SizedBox(height: 8),
          _buildInfoRow('Artistic Topping', cake['design']!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: BirthdayTheme.warmIvory,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BirthdayTheme.subtleBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BirthdayTheme.mutedGold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: BirthdayTheme.body.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Food & Catering Ideas
  Widget _buildBlueprintSection5Food() {
    final foodIdeas = _generatedPlan!['foodIdeas'] as List<Map<String, String>>;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.restaurant_menu_rounded,
            title: '5. Food & Catering Concepts',
            subtitle: 'Menu courses tailored to your gathering style',
          ),
          const SizedBox(height: 12),
          ...foodIdeas.map((f) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BirthdayTheme.warmIvory,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BirthdayTheme.subtleBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dining_rounded, size: 16, color: BirthdayTheme.mutedGold),
                      const SizedBox(width: 8),
                      Text(
                        f['title']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: BirthdayTheme.deepCocoa,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(f['desc']!, style: BirthdayTheme.bodySmall),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 6. Gift Suggestions
  Widget _buildBlueprintSection6Gifts() {
    final gifts = _generatedPlan!['giftSuggestions'] as List<Map<String, String>>;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.card_giftcard_rounded,
            title: '6. Curated Gift Suggestions',
            subtitle: 'Thoughtful ideas aligned with interests and age',
          ),
          const SizedBox(height: 12),
          ...gifts.map((g) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: BirthdayTheme.champagneBeige.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.redeem_rounded, size: 14, color: BirthdayTheme.mutedGold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g['title']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: BirthdayTheme.deepCocoa,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(g['desc']!, style: BirthdayTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 7. Entertainment Ideas
  Widget _buildBlueprintSection7Entertainment() {
    final entertainment = _generatedPlan!['entertainment'] as List<Map<String, String>>;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.music_note_rounded,
            title: '7. Entertainment & Social Activities',
            subtitle: 'Memorable games, music & guest interaction',
          ),
          const SizedBox(height: 12),
          ...entertainment.map((e) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BirthdayTheme.warmIvory,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BirthdayTheme.subtleBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star_border_purple500_rounded, color: BirthdayTheme.mutedGold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e['title']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: BirthdayTheme.deepCocoa,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(e['desc']!, style: BirthdayTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 8. Shopping Checklist
  Widget _buildBlueprintSection8Checklist() {
    final checklist = _generatedPlan!['shoppingChecklist'] as List<String>;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildCardHeader(
                  icon: Icons.checklist_rounded,
                  title: '8. Shopping Checklist',
                  subtitle: '${_checkedChecklistItems.length} of ${checklist.length} items collected',
                ),
              ),
              if (_checkedChecklistItems.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _checkedChecklistItems.clear();
                    });
                  },
                  child: Text('Reset', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: BirthdayTheme.mutedGold)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: checklist.isEmpty ? 0 : (_checkedChecklistItems.length / checklist.length),
              backgroundColor: BirthdayTheme.champagneBeige.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(BirthdayTheme.mutedGold),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(checklist.length, (index) {
            final isChecked = _checkedChecklistItems.contains(index);
            final item = checklist[index];
            return InkWell(
              onTap: () {
                setState(() {
                  if (isChecked) {
                    _checkedChecklistItems.remove(index);
                  } else {
                    _checkedChecklistItems.add(index);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: isChecked ? BirthdayTheme.successGreen : BirthdayTheme.mutedGold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: BirthdayTheme.body.copyWith(
                          fontSize: 13,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked ? BirthdayTheme.deepCocoa.withValues(alpha: 0.4) : BirthdayTheme.deepCocoa,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 9. Cost Breakdown
  Widget _buildBlueprintSection9CostBreakdown() {
    final costBreakdown = _generatedPlan!['costBreakdown'] as List<Map<String, dynamic>>;
    final totalBudget = _generatedPlan!['totalBudget'] as double;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.pie_chart_outline_rounded,
            title: '9. Estimated Cost Breakdown',
            subtitle: 'Target distribution for ${_formatCurrency(totalBudget)}',
          ),
          const SizedBox(height: 14),
          ...costBreakdown.map((item) {
            final double amount = (item['amount'] as num).toDouble();
            final percent = item['percent'] as String;
            final double fraction = (totalBudget == 0) ? 0 : (amount / totalBudget).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['category'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: BirthdayTheme.deepCocoa,
                        ),
                      ),
                      Text(
                        '${_formatCurrency(amount)} ($percent)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: BirthdayTheme.mutedGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 6,
                      backgroundColor: BirthdayTheme.champagneBeige.withValues(alpha: 0.4),
                      valueColor: const AlwaysStoppedAnimation<Color>(BirthdayTheme.mutedGold),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 10. Event-Day Schedule
  Widget _buildBlueprintSection10Schedule() {
    final schedule = _generatedPlan!['schedule'] as List<Map<String, String>>;

    return Container(
      decoration: BirthdayTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.schedule_rounded,
            title: '10. Event-Day Schedule',
            subtitle: 'Optimized flow for seamless execution',
          ),
          const SizedBox(height: 14),
          ...List.generate(schedule.length, (idx) {
            final slot = schedule[idx];
            final isLast = idx == schedule.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline line & dot
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: BirthdayTheme.mutedGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: BirthdayTheme.champagneBeige,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Time badge & description
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: BirthdayTheme.champagneBeige.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              slot['time']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: BirthdayTheme.deepCocoa,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            slot['title']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: BirthdayTheme.deepCocoa,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            slot['desc']!,
                            style: BirthdayTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isGenerating ? null : _handleGenerate,
            style: BirthdayTheme.secondaryButton,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Regenerate Ideas'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _savePlanToProvider,
            style: BirthdayTheme.primaryButton,
            icon: const Icon(Icons.bookmark_added_rounded, size: 18),
            label: const Text('Save Plan'),
          ),
        ),
      ],
    );
  }
}
