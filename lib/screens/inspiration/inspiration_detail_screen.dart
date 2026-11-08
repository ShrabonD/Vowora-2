import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/inspiration_item.dart';
import '../../providers/wedding_provider.dart';
import '../../routes/app_routes.dart';

class InspirationDetailScreen extends StatelessWidget {
  final InspirationItem item;

  const InspirationDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final weddingProvider = Provider.of<WeddingProvider>(context);
    // Find current item state from provider to get latest isFavorite
    final currentItem = weddingProvider.inspirationItems.firstWhere(
      (element) => element.id == item.id,
      orElse: () => item,
    );
    final relatedItems = weddingProvider.inspirationItems
        .where((element) => element.id != item.id)
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      body: CustomScrollView(
        slivers: [
          // Immersive App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            backgroundColor: VoworaColors.darkBackground,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    currentItem.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: currentItem.isFavorite ? Colors.redAccent : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  weddingProvider.toggleInspirationFavorite(currentItem.id);
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'inspiration_${currentItem.id}',
                    child: currentItem.imageUrl.startsWith('assets/')
                        ? Image.asset(currentItem.imageUrl, fit: BoxFit.cover)
                        : Image.network(
                            currentItem.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/images/wedding_background.png', fit: BoxFit.cover),
                          ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          currentItem.category.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: VoworaColors.champagneGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: VoworaColors.champagneGold, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'Curated Design',
                            style: GoogleFonts.plusJakartaSans(
                              color: VoworaColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentItem.title,
                    style: GoogleFonts.playfairDisplay(
                      color: VoworaColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'This exquisite concept combines luxury editorial aesthetics with bespoke event planning. Featuring refined detailing, atmospheric lighting, and high-end floral artistry tailored for unforgettable celebrations.',
                    style: GoogleFonts.plusJakartaSans(
                      color: VoworaColors.textSecondary,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            weddingProvider.toggleInspirationFavorite(currentItem.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  currentItem.isFavorite ? 'Removed from saved ideas' : 'Saved to your inspiration collection ♡',
                                  style: GoogleFonts.plusJakartaSans(),
                                ),
                                backgroundColor: VoworaColors.darkCardBackground,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: VoworaColors.champagneGold,
                            side: const BorderSide(color: VoworaColors.champagneGold, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: Icon(
                            currentItem.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 18,
                          ),
                          label: Text(
                            currentItem.isFavorite ? 'Saved' : 'Save Inspiration',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.weddingManager);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: VoworaColors.champagneGold,
                            foregroundColor: VoworaColors.darkBackground,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                          label: Text(
                            'Use This Theme',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Related Inspirations Section
                  Text(
                    'More Inspirations',
                    style: GoogleFonts.playfairDisplay(
                      color: VoworaColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: relatedItems.length,
                    itemBuilder: (context, index) {
                      final relItem = relatedItems[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InspirationDetailScreen(item: relItem),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              relItem.imageUrl.startsWith('assets/')
                                  ? Image.asset(relItem.imageUrl, fit: BoxFit.cover)
                                  : Image.network(
                                      relItem.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Image.asset('assets/images/wedding_background.png', fit: BoxFit.cover),
                                    ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      relItem.title,
                                      style: GoogleFonts.playfairDisplay(
                                        color: Colors.white,
                                        fontSize: 13,
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
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
