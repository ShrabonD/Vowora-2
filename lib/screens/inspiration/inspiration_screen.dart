import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../providers/wedding_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/vowora_cached_image.dart';
import 'inspiration_detail_screen.dart';

class InspirationScreen extends StatefulWidget {
  const InspirationScreen({super.key});

  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> {
  String _selectedCategory = 'All Inspirations';
  bool _showFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All Inspirations',
    'Wedding',
    'Floral Designs',
    'Stage Setups',
    'Birthday',
    'Lighting',
    'Table Decor',
    'Luxury Venues',
    'Outdoor Events',
    'Decor',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weddingProvider = Provider.of<WeddingProvider>(context);
    final allItems = weddingProvider.inspirationItems;

    final filteredItems = allItems.where((item) {
      final matchesCategory = _selectedCategory == 'All Inspirations' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesFavorite = !_showFavoritesOnly || item.isFavorite;
      final matchesSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesFavorite && matchesSearch;
    }).toList();

    final featuredItem = allItems.isNotEmpty ? allItems.first : null;

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: VoworaColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Explore Inspirations',
          style: GoogleFonts.playfairDisplay(
            color: VoworaColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _showFavoritesOnly ? Colors.redAccent : VoworaColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Atmosphere
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
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.78),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Subtitle
                      Text(
                        'Discover extraordinary ideas for unforgettable celebrations.',
                        style: GoogleFonts.plusJakartaSans(
                          color: VoworaColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: VoworaColors.darkCardBackground.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: VoworaColors.champagneGold.withValues(alpha: 0.3),
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.plusJakartaSans(color: VoworaColors.textPrimary),
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Search themes, decor, lighting...',
                                hintStyle: GoogleFonts.plusJakartaSans(color: VoworaColors.textSecondary),
                                prefixIcon: const Icon(Icons.search_rounded, color: VoworaColors.champagneGold),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, color: VoworaColors.textSecondary),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? VoworaColors.champagneGold
                                        : VoworaColors.darkCardBackground.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? VoworaColors.champagneGold
                                          : VoworaColors.champagneGold.withValues(alpha: 0.25),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isSelected ? VoworaColors.darkBackground : VoworaColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Featured Inspiration Hero Card
                      if (featuredItem != null && _searchQuery.isEmpty && !_showFavoritesOnly) ...[
                        Text(
                          'Featured Masterpiece',
                          style: GoogleFonts.playfairDisplay(
                            color: VoworaColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InspirationDetailScreen(item: featuredItem),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 220,
                                  width: double.infinity,
                                  child: Hero(
                                    tag: 'inspiration_${featuredItem.id}',
                                    child: VoworaCachedImage(
                                      imageUrl: featuredItem.imageUrl,
                                      contextSize: ImageContextSize.hero,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.85),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 14,
                                  right: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: VoworaColors.champagneGold,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'FEATURED',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: VoworaColors.darkBackground,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        featuredItem.title,
                                        style: GoogleFonts.playfairDisplay(
                                          color: VoworaColors.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap to explore full concept details and themes ♡',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: VoworaColors.textSecondary,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Gallery Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _showFavoritesOnly ? 'Saved Collections' : 'Inspiration Gallery',
                            style: GoogleFonts.playfairDisplay(
                              color: VoworaColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${filteredItems.length} items',
                            style: GoogleFonts.plusJakartaSans(
                              color: VoworaColors.champagneGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ]),
                  ),
                ),

                // Inspiration Grid
                filteredItems.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: VoworaEmptyState(
                            title: 'No inspiration items found ♡',
                            description: 'Explore themes and tap the heart icon to save your favorites.',
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.82,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = filteredItems[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => InspirationDetailScreen(item: item),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Hero(
                                        tag: 'inspiration_${item.id}',
                                        child: VoworaCachedImage(
                                          imageUrl: item.imageUrl,
                                          contextSize: ImageContextSize.card,
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
                                                Colors.transparent,
                                                Colors.black.withValues(alpha: 0.78),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () {
                                            weddingProvider.toggleInspirationFavorite(item.id);
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                              child: Container(
                                                padding: const EdgeInsets.all(7),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.45),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                  color: item.isFavorite ? Colors.redAccent : Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        right: 12,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: VoworaColors.champagneGold.withValues(alpha: 0.85),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                item.category.toUpperCase(),
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: VoworaColors.darkBackground,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.title,
                                              style: GoogleFonts.playfairDisplay(
                                                color: VoworaColors.textPrimary,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: filteredItems.length,
                          ),
                        ),
                      ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
