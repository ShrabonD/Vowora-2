import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/birthday_theme.dart';
import '../../providers/birthday_provider.dart';

/// Birthday Theme Studio - Theme gallery featuring 12 curated themes with detailed previews.
class BirthdayThemeStudioScreen extends StatefulWidget {
  const BirthdayThemeStudioScreen({super.key});

  @override
  State<BirthdayThemeStudioScreen> createState() => _BirthdayThemeStudioScreenState();
}

class _BirthdayThemeStudioScreenState extends State<BirthdayThemeStudioScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteThemeIds = {};

  static const List<Map<String, dynamic>> _themes = [
    {
      'id': 'minimal_classy',
      'name': 'Minimal Classy',
      'category': 'Elegant',
      'description': 'Clean lines, muted tones, understated elegance',
      'imageAsset': 'assets/images/birthday/theme_minimal.jpg',
      'colors': ['#F8F3EE', '#B28A63', '#382923'],
      'colorNames': ['Warm Ivory', 'Muted Gold', 'Deep Cocoa'],
      'decorationIdeas': [
        'Matte ivory fabric drapery paired with linear metallic gold accents',
        'Low-profile dried pampas grass, white orchids, and ceramic vessels',
        'Laser-cut custom acrylic signage with clean modern typography',
        'Sculptural ribbed pillar candles casting soft ambient glow',
      ],
      'cakeInspiration':
          'Single or two-tier concrete textured fondant cake featuring edible gold leaf flecks and delicate dried botanical sprigs.',
      'dressCode': 'Monochrome chic or smart-casual in warm earth, ivory, and taupe tones.',
      'estimatedBudget': 15000,
    },
    {
      'id': 'champagne_gold',
      'name': 'Champagne & Gold',
      'category': 'Elegant',
      'description': 'Golden accents, crystal details, champagne hues',
      'imageAsset': 'assets/images/birthday/theme_champagne.jpg',
      'colors': ['#F5E6AB', '#B28A63', '#FAF6F0'],
      'colorNames': ['Champagne Gold', 'Muted Gold', 'Warm Pearl'],
      'decorationIdeas': [
        'Cascading champagne and chrome gold balloon arch framing the entrance',
        'Crystal cut glassware and shimmering satin champagne table runners',
        'Warm micro-LED fairy light curtain with soft ambient backlighting',
        'Champagne coupe tower centerpiece with dry-ice mist fog effect',
      ],
      'cakeInspiration':
          'Two-tier white chocolate ganache cake adorned with brushed gold leaf foil, delicate macarons, and sparkler candles.',
      'dressCode': 'Glamorous cocktail attire in champagne, gold, warm bronze, or black.',
      'estimatedBudget': 35000,
    },
    {
      'id': 'blush_ivory',
      'name': 'Blush & Ivory',
      'category': 'Romantic',
      'description': 'Soft pink roses, ivory linens, romantic warmth',
      'imageAsset': 'assets/images/birthday/theme_blush.jpg',
      'colors': ['#FAD2E1', '#FFFBF7', '#D9B7A7'],
      'colorNames': ['Soft Blush', 'Warm Ivory', 'Rose Beige'],
      'decorationIdeas': [
        'Fresh English garden blush roses in fluted vintage glass vessels',
        'Floor-length ivory linen tablecloths with sheer chiffon runner overlays',
        'Romantic floral arch entryway interwoven with eucalyptus and baby\'s breath',
        'Handwritten calligraphy place cards tied with satin blush ribbons',
      ],
      'cakeInspiration':
          'Vintage Lambeth-piped cake with blush buttercream rosettes, maraschino cherries, and pearl dragee accents.',
      'dressCode': 'Romantic pastels, dusty pink dresses, cream blazers, or floral motifs.',
      'estimatedBudget': 25000,
    },
    {
      'id': 'garden_romance',
      'name': 'Garden Romance',
      'category': 'Romantic',
      'description': 'Lush greenery, fairy lights, al fresco charm',
      'imageAsset': 'assets/images/birthday/theme_garden.jpg',
      'colors': ['#588157', '#A3B18A', '#F8F3EE'],
      'colorNames': ['Sage Olive', 'Moss Green', 'Warm Ivory'],
      'decorationIdeas': [
        'Suspended warm Edison festoon bulbs interwoven with olive branches',
        'Rustic timber farm tables with living moss and wildflower runners',
        'Botanical chalkboard welcome easel flanked by terracotta potted plants',
        'Cozy wicker lounge corners layered with woven linen outdoor cushions',
      ],
      'cakeInspiration':
          'Semi-naked sponge cake filled with chantilly cream, fresh raspberries, blackberries, and fresh rosemary sprigs.',
      'dressCode': 'Garden party chic, botanical floral prints, airy linen shirts, and sun hats.',
      'estimatedBudget': 30000,
    },
    {
      'id': 'pastel_dream',
      'name': 'Pastel Dream',
      'category': 'Playful & Fun',
      'description': 'Soft rainbow pastels, dreamy clouds, gentle joy',
      'imageAsset': 'assets/images/birthday/theme_pastel.jpg',
      'colors': ['#FFC8DD', '#BDE0FE', '#CDB4DB'],
      'colorNames': ['Cloud Pink', 'Baby Blue', 'Lavender Mist'],
      'decorationIdeas': [
        'Cotton candy cloud sculptures with concealed micro twinkle lights',
        'Pastel ombre balloon clusters accented with iridescent shimmer streamers',
        'Floating pastel macaron pyramid centerpiece on an acrylic pedestal',
        'Custom photo backdrop wall featuring a glowing holographic LED sign',
      ],
      'cakeInspiration':
          'Pastel watercolor buttercream cake crowned with fluffy meringue cloud kisses and edible shimmer dust.',
      'dressCode': 'Dreamy pastels: lavender, powder blue, soft mint, or buttercup yellow.',
      'estimatedBudget': 20000,
    },
    {
      'id': 'royal_celebration',
      'name': 'Royal Celebration',
      'category': 'Elegant',
      'description': 'Velvet drapes, crystal chandeliers, opulent gold',
      'imageAsset': 'assets/images/birthday/theme_royal.jpg',
      'colors': ['#2B1E4A', '#B28A63', '#141B41'],
      'colorNames': ['Royal Plum', 'Opulent Gold', 'Midnight Navy'],
      'decorationIdeas': [
        'Deep midnight velvet backdrops framed with ornate baroque gold mouldings',
        'Miniature crystal chandeliers suspended over banquet dining tables',
        'Multi-arm brass candelabras with tapered candles and deep burgundy blooms',
        'Plush royal carpet runner flanked by polished brass stanchions',
      ],
      'cakeInspiration':
          'Three-tier regal fondant masterpiece with hand-painted baroque gold filigree and an ornate crown cake topper.',
      'dressCode': 'Black tie or formal evening attire with rich jewels and structured tailoring.',
      'estimatedBudget': 50000,
    },
    {
      'id': 'black_gold',
      'name': 'Black & Gold',
      'category': 'Modern & Bold',
      'description': 'Dramatic contrast, metallic shimmer, bold elegance',
      'imageAsset': 'assets/images/birthday/theme_black_gold.jpg',
      'colors': ['#121212', '#D4AF37', '#2A2A2A'],
      'colorNames': ['Noir Black', 'Metallic Gold', 'Slate Charcoal'],
      'decorationIdeas': [
        'Matte black feature wall with oversized 3D metallic mirror-gold numerals',
        'Black tablecloths layered with shimmering gold sequin runners',
        'Dual-tone matte black and mirror chrome gold ceiling balloon cascade',
        'Dramatic mood lighting with amber uplights and beam spotlights',
      ],
      'cakeInspiration':
          'Midnight black cocoa velvet cake with fractured 24k edible gold leaf geode crack and gold drip trim.',
      'dressCode': 'Sleek black cocktail dresses or sharp tuxedo blazers with gold accessories.',
      'estimatedBudget': 30000,
    },
    {
      'id': 'floral_elegance',
      'name': 'Floral Elegance',
      'category': 'Romantic',
      'description': 'Cascading blooms, garden-fresh arrangements',
      'imageAsset': 'assets/images/birthday/theme_floral.jpg',
      'colors': ['#E5989B', '#6D6875', '#B5838D'],
      'colorNames': ['Dusty Rose', 'Vintage Mauve', 'Petal Pink'],
      'decorationIdeas': [
        'Lush 3D flower wall backdrop featuring hydrangeas, peonies, and garden roses',
        'Hanging floral hoop chandeliers suspended above the cake presentation area',
        'Individual mini glass floral cloches as bespoke table place settings',
        'Fresh flower petal pathway leading into the celebration hall',
      ],
      'cakeInspiration':
          'Pressed edible flower buttercream cake featuring violas, pansies, and real gold leaf flecks.',
      'dressCode': 'Romantic floral dresses, pastel tailored suits, or garden tea party chic.',
      'estimatedBudget': 25000,
    },
    {
      'id': 'kids_wonderland',
      'name': "Kids' Wonderland",
      'category': 'Playful & Fun',
      'description': 'Rainbow balloons, cartoon characters, pure fun',
      'imageAsset': 'assets/images/birthday/theme_kids.jpg',
      'colors': ['#FF5964', '#35A7FF', '#FFE74C'],
      'colorNames': ['Coral Red', 'Sky Blue', 'Sunflower Yellow'],
      'decorationIdeas': [
        'Whimsical rainbow balloon castle with spiraling candy cane balloon columns',
        'Life-sized cartoon cutout character photo standees with child face holes',
        'Customized candy buffet station with jars, candy scoops, and personalized bags',
        'Color-coded kids activity tables equipped with doodle placemats and party hats',
      ],
      'cakeInspiration':
          'Playful 3D cartoon fondant cake with hidden rainbow sponge layers and gravity-defying candy spill.',
      'dressCode': 'Bright, colorful celebratory party wear or favorite superhero/cartoon costumes.',
      'estimatedBudget': 20000,
    },
    {
      'id': 'gaming_party',
      'name': 'Gaming Party',
      'category': 'Modern & Bold',
      'description': 'Neon lights, controller motifs, digital vibes',
      'imageAsset': 'assets/images/birthday/theme_gaming.jpg',
      'colors': ['#00F5D4', '#7B2CBF', '#0F0E17'],
      'colorNames': ['Neon Cyan', 'Cyber Violet', 'Dark Arcade'],
      'decorationIdeas': [
        'Cyberpunk LED neon rope illumination in vivid electric cyan and magenta',
        'Game controller balloon mosaic and 8-bit retro pixel wall decals',
        'Tournament battle station backdrop with illuminated RGB ring lights',
        'Pixel heart "Power-Up" energy drink bar and gamer snack dispensers',
      ],
      'cakeInspiration':
          'Custom gaming console controller cake or miniature arcade cabinet cake with pixel piping.',
      'dressCode': 'Graphic gaming tees, cyberpunk streetwear, or favorite game character cosplay.',
      'estimatedBudget': 18000,
    },
    {
      'id': 'kpop_inspired',
      'name': 'K-pop Inspired',
      'category': 'Modern & Bold',
      'description': 'Lightstick colors, idol aesthetic, fan culture',
      'imageAsset': 'assets/images/birthday/theme_kpop.jpg',
      'colors': ['#F72585', '#7209B7', '#4CC9F0'],
      'colorNames': ['Lightstick Pink', 'Idol Purple', 'Neon Cyan'],
      'decorationIdeas': [
        'Official photocard display gallery wall with miniature wooden pegs & fairy lights',
        'Holographic foil fringe photo backdrop with music video inspired stage spotlights',
        'Lightstick ocean display table with synchronized color LED light bars',
        'Personalized K-pop concert VIP badge invitations and commemorative wristbands',
      ],
      'cakeInspiration':
          'Aesthetic concept cake inspired by comeback album visuals with holographic butterfly topper and Korean lettering.',
      'dressCode': 'K-pop stage outfit inspired, monochrome streetwear, or group fandom concept colors.',
      'estimatedBudget': 22000,
    },
    {
      'id': 'tropical_summer',
      'name': 'Tropical Summer',
      'category': 'Playful & Fun',
      'description': 'Palm leaves, exotic fruits, sunset palette',
      'imageAsset': 'assets/images/birthday/theme_tropical.jpg',
      'colors': ['#06D6A0', '#FFD166', '#EF476F'],
      'colorNames': ['Palm Teal', 'Sunset Amber', 'Hibiscus Coral'],
      'decorationIdeas': [
        'Monstera and palm frond balloon arch featuring giant flamingo inflatables',
        'Bamboo tiki mocktail bar serving fresh coconut water and pineapple spritzers',
        'Pineapple and fresh hibiscus table centerpieces with natural woven seagrass mats',
        'Warm sunset paper lanterns and natural rattan pendant fixtures',
      ],
      'cakeInspiration':
          'Tropical coconut lime cake styled with edible wafer paper monstera leaves and hibiscus blossoms.',
      'dressCode': 'Hawaiian aloha shirts, tropical maxi dresses, and light summer linen attire.',
      'estimatedBudget': 20000,
    },
  ];

  static const List<String> _categories = [
    'All',
    'Elegant',
    'Romantic',
    'Modern & Bold',
    'Playful & Fun',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatBudget(int amount) {
    final integerPart = amount.toString();
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

  void _openThemeDetail(Map<String, dynamic> theme) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BirthdayThemeDetailScreen(
          theme: theme,
          isFavorite: _favoriteThemeIds.contains(theme['id']),
          onToggleFavorite: () {
            setState(() {
              if (_favoriteThemeIds.contains(theme['id'])) {
                _favoriteThemeIds.remove(theme['id']);
              } else {
                _favoriteThemeIds.add(theme['id']);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BirthdayProvider>(context);
    final activeThemeName = provider.activeEvent?.theme;

    final query = _searchController.text.trim().toLowerCase();
    final filteredThemes = _themes.where((theme) {
      final matchesCategory = _selectedCategory == 'All' || theme['category'] == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          (theme['name'] as String).toLowerCase().contains(query) ||
          (theme['description'] as String).toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

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
          'Birthday Theme Studio',
          style: BirthdayTheme.heading3,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: BirthdayTheme.body,
                  decoration: InputDecoration(
                    hintText: 'Search themes, aesthetics, moods...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: BirthdayTheme.deepCocoa.withValues(alpha: 0.4), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: BirthdayTheme.mutedGold, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: BirthdayTheme.deepCocoa, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                ),
                const SizedBox(height: 12),
                // Category Filter Chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : BirthdayTheme.deepCocoa,
                        ),
                        selected: isSelected,
                        selectedColor: BirthdayTheme.mutedGold,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? BirthdayTheme.mutedGold : BirthdayTheme.subtleBorder,
                          ),
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Themes Grid
          Expanded(
            child: filteredThemes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.palette_outlined, size: 48, color: BirthdayTheme.mutedGold.withValues(alpha: 0.6)),
                          const SizedBox(height: 12),
                          Text('No themes found', style: BirthdayTheme.heading3),
                          const SizedBox(height: 4),
                          Text(
                            'Try selecting another category or clear your search query.',
                            textAlign: TextAlign.center,
                            style: BirthdayTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: filteredThemes.length,
                    itemBuilder: (context, index) {
                      final theme = filteredThemes[index];
                      final isActive = activeThemeName == theme['name'];
                      final isFavorite = _favoriteThemeIds.contains(theme['id']);

                      return _buildThemeCard(theme, isActive: isActive, isFavorite: isFavorite);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(Map<String, dynamic> theme, {required bool isActive, required bool isFavorite}) {
    final imageAsset = theme['imageAsset'] as String;
    final name = theme['name'] as String;
    final description = theme['description'] as String;
    final budget = theme['estimatedBudget'] as int;

    return GestureDetector(
      onTap: () => _openThemeDetail(theme),
      child: Container(
        decoration: BirthdayTheme.cardDecoration.copyWith(
          border: Border.all(
            color: isActive ? BirthdayTheme.mutedGold : BirthdayTheme.subtleBorder,
            width: isActive ? 1.8 : 0.8,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Overlays
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: BirthdayTheme.assetImage(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient Shadow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ),
                // Active Theme Badge
                if (isActive)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BirthdayTheme.mutedGold,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'ACTIVE',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Favorite Heart Toggle
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isFavorite) {
                          _favoriteThemeIds.remove(theme['id']);
                        } else {
                          _favoriteThemeIds.add(theme['id']);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? const Color(0xFFFF5964) : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // Budget Tag in corner
                Positioned(
                  bottom: 6,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatBudget(budget),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: BirthdayTheme.deepCocoa,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: BirthdayTheme.deepCocoa.withValues(alpha: 0.7),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Color dots preview
                    Row(
                      children: (theme['colors'] as List<String>).map((hex) {
                        return Container(
                          margin: const EdgeInsets.only(right: 5),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _parseHex(hex),
                            shape: BoxShape.circle,
                            border: Border.all(color: BirthdayTheme.subtleBorder, width: 0.8),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detailed Screen for Theme Inspiration & Selection
class BirthdayThemeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> theme;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const BirthdayThemeDetailScreen({
    super.key,
    required this.theme,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<BirthdayThemeDetailScreen> createState() => _BirthdayThemeDetailScreenState();
}

class _BirthdayThemeDetailScreenState extends State<BirthdayThemeDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
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

  String _formatBudget(int amount) {
    final integerPart = amount.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = integerPart.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '৳$formatted';
  }

  void _selectTheme() {
    final provider = Provider.of<BirthdayProvider>(context, listen: false);
    final themeName = widget.theme['name'] as String;

    if (provider.activeEvent != null) {
      final active = provider.activeEvent!;
      active.theme = themeName;
      provider.updateEvent(active);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selected "$themeName" for ${active.personName}\'s birthday!',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
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
            'Theme "$themeName" chosen! Create or select an event to bind.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: BirthdayTheme.mutedGold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final name = theme['name'] as String;
    final description = theme['description'] as String;
    final imageAsset = theme['imageAsset'] as String;
    final colors = theme['colors'] as List<String>;
    final colorNames = (theme['colorNames'] as List<String>?) ?? ['Primary', 'Accent', 'Base'];
    final decorationIdeas = theme['decorationIdeas'] as List<String>;
    final cakeInspiration = theme['cakeInspiration'] as String;
    final dressCode = theme['dressCode'] as String;
    final budget = theme['estimatedBudget'] as int;

    return Scaffold(
      backgroundColor: BirthdayTheme.warmIvory,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Large Cover Image Sliver App Bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: BirthdayTheme.warmIvory,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.45),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? const Color(0xFFFF5964) : Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                      widget.onToggleFavorite();
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  BirthdayTheme.assetImage(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          BirthdayTheme.warmIvory.withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text(
                    name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: BirthdayTheme.deepCocoa,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: BirthdayTheme.subtitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 20),

                  // Color Palette (3 circles)
                  _buildSectionTitle(Icons.palette_outlined, 'Color Palette'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BirthdayTheme.cardDecoration,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(colors.length, (idx) {
                        final hex = colors[idx];
                        final cName = idx < colorNames.length ? colorNames[idx] : hex;
                        final color = _parseHex(hex);

                        return Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: BirthdayTheme.subtleBorder, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: BirthdayTheme.deepCocoa.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: BirthdayTheme.deepCocoa,
                              ),
                            ),
                            Text(
                              hex,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Decoration Inspiration (bullet list)
                  _buildSectionTitle(Icons.auto_awesome_outlined, 'Decoration Inspiration'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BirthdayTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: decorationIdeas.map((idea) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4, right: 10),
                                child: Icon(Icons.stars_rounded, color: BirthdayTheme.mutedGold, size: 16),
                              ),
                              Expanded(
                                child: Text(idea, style: BirthdayTheme.body),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cake Inspiration
                  _buildSectionTitle(Icons.cake_outlined, 'Cake Inspiration'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BirthdayTheme.cardDecoration,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: BirthdayTheme.champagneBeige.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cake_rounded, color: BirthdayTheme.mutedGold, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            cakeInspiration,
                            style: BirthdayTheme.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Suggested Dress Code
                  _buildSectionTitle(Icons.checkroom_outlined, 'Suggested Dress Code'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BirthdayTheme.cardDecoration,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: BirthdayTheme.champagneBeige.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.style_outlined, color: BirthdayTheme.mutedGold, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            dressCode,
                            style: BirthdayTheme.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Estimated Decoration Budget
                  _buildSectionTitle(Icons.account_balance_wallet_outlined, 'Estimated Decoration Budget'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BirthdayTheme.cardDecoration,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Standard Package',
                              style: BirthdayTheme.bodySmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatBudget(budget),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: BirthdayTheme.mutedGold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: BirthdayTheme.champagneBeige.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Estimated Decor',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: BirthdayTheme.deepCocoa,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 'Select This Theme' Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _selectTheme,
                      style: BirthdayTheme.primaryButton,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: Text('Select This Theme', style: BirthdayTheme.buttonText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: BirthdayTheme.mutedGold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: BirthdayTheme.heading3.copyWith(fontSize: 17),
        ),
      ],
    );
  }
}
