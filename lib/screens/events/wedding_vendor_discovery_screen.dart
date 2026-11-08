import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/vendor_package.dart';

class WeddingVendorDiscoveryScreen extends StatefulWidget {
  const WeddingVendorDiscoveryScreen({super.key});

  @override
  State<WeddingVendorDiscoveryScreen> createState() =>
      _WeddingVendorDiscoveryScreenState();
}

class _WeddingVendorDiscoveryScreenState
    extends State<WeddingVendorDiscoveryScreen> {
  String _selectedCategory = 'All';
  String _currentLocation = 'Dhanmondi, Dhaka';

  // Sample Nearby Vendors Data with Tiered Packages & Customizer Items
  final List<NearbyVendor> _allVendors = [
    NearbyVendor(
      id: 'v1',
      name: 'Aura Cinematic Photography',
      category: 'Photography',
      rating: 4.9,
      reviewsCount: 128,
      distanceKm: 1.2,
      address: 'Road 8A, Dhanmondi',
      imageUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b',
      startingPrice: 35000,
      packages: [
        VendorPackage(
          id: 'p1_basic',
          name: 'Basic Memories',
          tier: PackageTier.basic,
          basePrice: 35000,
          description: 'Essential photography package for intimate ceremonies.',
          items: [
            PackageItem(
              id: 'i1',
              name: '1 Senior Photographer',
              description: 'Full day coverage (up to 6 hours)',
              defaultPrice: 15000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i2',
              name: '100 Color Corrected Edits',
              description: 'High resolution digital copies',
              defaultPrice: 8000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i3',
              name: 'Printed Premium Album (30 Pages)',
              description: 'Silk finish hardcover photo album',
              defaultPrice: 12000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i4',
              name: 'Drone Aerial Photography',
              description: '4K drone coverage of venue & entrance',
              defaultPrice: 8000,
              isDefaultIncluded: false,
              isSelected: false,
            ),
            PackageItem(
              id: 'i5',
              name: 'Cinematic Teaser (1-2 Mins)',
              description: 'Highlights reel for Instagram/Facebook',
              defaultPrice: 10000,
              isDefaultIncluded: false,
              isSelected: false,
            ),
          ],
        ),
        VendorPackage(
          id: 'p1_moderate',
          name: 'Moderate Signature',
          tier: PackageTier.moderate,
          basePrice: 65000,
          description: 'Most popular choice! Complete photography & cinematography.',
          items: [
            PackageItem(
              id: 'i1',
              name: '2 Senior Photographers',
              description: 'Full ceremony & reception coverage',
              defaultPrice: 25000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i2',
              name: '1 Senior Cinematographer',
              description: '4K Full HD Video Recording',
              defaultPrice: 20000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i3',
              name: 'Drone Shot & Cinematic Trailer',
              description: '3 min teaser + 20 min documentary film',
              defaultPrice: 15000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i4',
              name: 'Luxury Velvet Photobook',
              description: '40 pages custom designed album',
              defaultPrice: 12000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i5',
              name: 'Extra Hour Coverage',
              description: 'Additional hour per crew member',
              defaultPrice: 5000,
              isDefaultIncluded: false,
              isSelected: false,
            ),
          ],
        ),
        VendorPackage(
          id: 'p1_premium',
          name: 'Royal Heritage Package',
          tier: PackageTier.premium,
          basePrice: 110000,
          description: 'Luxury multi-crew royal wedding coverage.',
          items: [
            PackageItem(
              id: 'i1',
              name: 'Chief Photographer + 2 Assistants',
              description: 'Master creative direction and candid shots',
              defaultPrice: 45000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i2',
              name: '2 Lead Cinematographers + 4K Drone',
              description: 'Dual angle cinematic film + live projection',
              defaultPrice: 40000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i3',
              name: '2 Premium Royal Leather Albums',
              description: 'Handcrafted luxury albums with wooden case',
              defaultPrice: 25000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'i4',
              name: 'Same Day Edit Reel',
              description: 'Teaser delivered before event finishes',
              defaultPrice: 15000,
              isDefaultIncluded: false,
              isSelected: false,
            ),
          ],
        ),
      ],
    ),
    NearbyVendor(
      id: 'v2',
      name: 'Grand Royal Decor & Stage',
      category: 'Stage & Decor',
      rating: 4.8,
      reviewsCount: 95,
      distanceKm: 2.1,
      address: 'Mirpur Road, Sobhanbag, Dhaka',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3',
      startingPrice: 80000,
      packages: [
        VendorPackage(
          id: 'p2_basic',
          name: 'Classic Elegance',
          tier: PackageTier.basic,
          basePrice: 80000,
          description: 'Clean floral stage with essential walkway lighting.',
          items: [
            PackageItem(
              id: 'd1',
              name: 'Floral Stage Backdrop (20x10 ft)',
              description: 'Fresh & artificial flower combination',
              defaultPrice: 45000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'd2',
              name: 'Entrance Archway & Pathway Lights',
              description: 'Warm LED fairy lights and carpeted walkway',
              defaultPrice: 25000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'd3',
              name: 'Bride & Groom Sofa Set',
              description: 'Royal velvet gold trim sofa',
              defaultPrice: 10000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'd4',
              name: 'Photo Booth Corner',
              description: 'Custom themed floral photo wall',
              defaultPrice: 15000,
              isDefaultIncluded: false,
              isSelected: false,
            ),
          ],
        ),
        VendorPackage(
          id: 'p2_moderate',
          name: 'Grand Velvet Deluxe',
          tier: PackageTier.moderate,
          basePrice: 140000,
          description: 'Full venue transformation with thematic lighting.',
          items: [
            PackageItem(
              id: 'd1',
              name: 'Grand Stage & Ceiling Drapes',
              description: 'Luxury crystal chandeliers and 30ft stage',
              defaultPrice: 75000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'd2',
              name: 'Table Centerpieces (15 Tables)',
              description: 'Fresh rose arrangements with golden stands',
              defaultPrice: 30000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'd3',
              name: 'Dynamic Ambient Lighting System',
              description: 'Focus spots, beam lights, and fog machine',
              defaultPrice: 35000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'd4',
              name: 'Cold Pyro Sparklers Entrance',
              description: '6 cold pyro blasts for grand entry',
              defaultPrice: 12000,
              isDefaultIncluded: false,
              isSelected: false,
            ),
          ],
        ),
        VendorPackage(
          id: 'p2_premium',
          name: 'Imperial Palace Setup',
          tier: PackageTier.premium,
          basePrice: 250000,
          description: 'Ultra luxury custom theme design for royal weddings.',
          items: [
            PackageItem(
              id: 'd1',
              name: 'Fully Customized 3D Theme Stage',
              description: 'Imported fresh flowers & mirror floor stage',
              defaultPrice: 150000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'd2',
              name: 'Complete Venue Lighting & Tunnel Entry',
              description: 'LED matrix tunnel with cold pyros & haze',
              defaultPrice: 60000,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'd3',
              name: 'VIP Lounge Setup & Custom Photobooths',
              description: '2 photo zones + luxury seating lounges',
              defaultPrice: 40000,
              isDefaultIncluded: true,
            ),
          ],
        ),
      ],
    ),
    NearbyVendor(
      id: 'v3',
      name: 'Feast & Flavors Catering',
      category: 'Catering',
      rating: 4.7,
      reviewsCount: 210,
      distanceKm: 3.0,
      address: 'Satmasjid Road, Dhanmondi',
      imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033',
      startingPrice: 450, // Per plate
      packages: [
        VendorPackage(
          id: 'p3_basic',
          name: 'Traditional Kacchi Feast',
          tier: PackageTier.basic,
          basePrice: 550, // per person base
          description: 'Authentic Mutton Kacchi Biryani menu.',
          items: [
            PackageItem(
              id: 'c1',
              name: 'Special Mutton Kacchi Biryani',
              description: 'Premium Basmati rice & tender mutton',
              defaultPrice: 350,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'c2',
              name: 'Chicken Roast & Borhani',
              description: 'Quarter roast & traditional spiced yogurt drink',
              defaultPrice: 120,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'c3',
              name: 'Jorda Dessert & Salad',
              description: 'Sweet rice dessert & fresh cucumber salad',
              defaultPrice: 80,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'c4',
              name: 'Live Kebab Counter',
              description: 'Reshmi & Seekh kebab live station',
              defaultPrice: 150,
              isDefaultIncluded: false,
              isSelected: false,
            ),
          ],
        ),
        VendorPackage(
          id: 'p3_moderate',
          name: 'Royal Shahi Buffet',
          tier: PackageTier.moderate,
          basePrice: 850,
          description: 'Multi-course Mughal feast with live live counters.',
          items: [
            PackageItem(
              id: 'c1',
              name: 'Kacchi Biryani + Polao Option',
              description: 'Two main rice dish options',
              defaultPrice: 400,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'c2',
              name: 'Chicken Roast, Beef Bhuna & Fish Fry',
              description: 'Rich gravy dishes & fried vetki',
              defaultPrice: 280,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'c3',
              name: 'Firni, Jorda & Ice Cream Bar',
              description: 'Assorted royal desserts',
              defaultPrice: 170,
              isDefaultIncluded: true,
            ),
          ],
        ),
        VendorPackage(
          id: 'p3_premium',
          name: 'International & Shahi Fusion',
          tier: PackageTier.premium,
          basePrice: 1300,
          description: 'Five star hotel grade culinary presentation.',
          items: [
            PackageItem(
              id: 'c1',
              name: 'Shahi Mutton Kacchi & Chinese Live Wok',
              description: 'Fusion spread for all palate preferences',
              defaultPrice: 650,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'c2',
              name: 'Prawn Thermidor & Mutton Rezala',
              description: 'Exotic seafood & rich traditional curry',
              defaultPrice: 400,
              isDefaultIncluded: true,
            ),
            PackageItem(
              id: 'c3',
              name: 'Gourmet Dessert Lounge & Mocktail Bar',
              description: 'Unlimited live mocktails & french pastries',
              defaultPrice: 250,
              isDefaultIncluded: true,
            ),
          ],
        ),
      ],
    ),
  ];

  final List<String> _categories = [
    'All',
    'Photography',
    'Stage & Decor',
    'Catering',
    'Bridal Makeup',
    'Venue',
    'Sound & Light',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredVendors = _selectedCategory == 'All'
        ? _allVendors
        : _allVendors.where((v) => v.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wedding Vendors',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.near_me_rounded,
                  size: 11,
                  color: VoworaColors.champagneGold,
                ),
                const SizedBox(width: 4),
                Text(
                  'Nearby: $_currentLocation',
                  style: GoogleFonts.plusJakartaSans(
                    color: VoworaColors.champagneGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: VoworaColors.champagneGold),
            onPressed: () => _showLocationChangeSheet(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Location Banner & Radius Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: VoworaColors.champagneGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: VoworaColors.champagneGold,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Showing Vendors Within 5 km',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Auto-matched by distance & backend availability',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _showLocationChangeSheet(context),
                          child: Text(
                            'Change',
                            style: GoogleFonts.plusJakartaSans(
                              color: VoworaColors.champagneGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Category Filter Pills
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = cat);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? VoworaColors.champagneGold
                                  : Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? VoworaColors.champagneGold
                                    : Colors.white.withValues(alpha: 0.3),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected ? const Color(0xFF141210) : Colors.white,
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Nearby Vendors List
                Expanded(
                  child: filteredVendors.isEmpty
                      ? Center(
                    child: Text(
                      'No nearby vendors found in this category.',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    itemCount: filteredVendors.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final vendor = filteredVendors[index];
                      return _buildVendorCard(context, vendor);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Vendor Card Widget ────────────────────────────────────────────────────
  Widget _buildVendorCard(BuildContext context, NearbyVendor vendor) {
    return GestureDetector(
      onTap: () => _showVendorPackagesSheet(context, vendor),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Info & Distance Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vendor Avatar / Icon Container
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: VoworaColors.champagneGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: VoworaColors.champagneGold,
                        size: 30,
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
                              Flexible(
                                child: Text(
                                  vendor.name,
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Distance Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: VoworaColors.champagneGold
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.navigation_rounded,
                                      size: 10,
                                      color: VoworaColors.champagneGold,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${vendor.distanceKm} km away',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: VoworaColors.champagneGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vendor.category} • ${vendor.address}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 15, color: Color(0xFFFFC107)),
                              const SizedBox(width: 3),
                              Text(
                                '${vendor.rating} (${vendor.reviewsCount} reviews)',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white.withValues(alpha: 0.15)),
                const SizedBox(height: 8),

                // Bottom Row: Price & Select Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3 Tier Packages Available',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          vendor.category == 'Catering'
                              ? 'From ৳${vendor.startingPrice.toStringAsFixed(0)} / Plate'
                              : 'Starting ৳${vendor.startingPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.playfairDisplay(
                            color: VoworaColors.champagneGold,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showVendorPackagesSheet(context, vendor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VoworaColors.champagneGold,
                        foregroundColor: const Color(0xFF141210),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.auto_awesome, size: 14),
                      label: Text(
                        'View Tiers',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Show Vendor Packages Modal Sheet ──────────────────────────────────────
  void _showVendorPackagesSheet(BuildContext context, NearbyVendor vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _VendorPackagesView(vendor: vendor);
      },
    );
  }

  // ── Change Location Dialog ────────────────────────────────────────────────
  void _showLocationChangeSheet(BuildContext context) {
    final controller = TextEditingController(text: _currentLocation);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1816),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Nearby Location',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your area or city to find nearby wedding vendors.',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon:
                  const Icon(Icons.location_on, color: VoworaColors.champagneGold),
                  hintText: 'e.g. Gulshan, Dhaka or Chittagong',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      setState(() => _currentLocation = text);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.champagneGold,
                    foregroundColor: const Color(0xFF141210),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Apply Location',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Vendor Packages Modal View ──────────────────────────────────────────────
class _VendorPackagesView extends StatefulWidget {
  final NearbyVendor vendor;

  const _VendorPackagesView({required this.vendor});

  @override
  State<_VendorPackagesView> createState() => _VendorPackagesViewState();
}

class _VendorPackagesViewState extends State<_VendorPackagesView> {
  late VendorPackage _selectedPackage;

  @override
  void initState() {
    super.initState();
    // Default to Moderate package if available, else first
    _selectedPackage = widget.vendor.packages.firstWhere(
          (p) => p.tier == PackageTier.moderate,
      orElse: () => widget.vendor.packages.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: const Color(0xFF161412),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vendor.name,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Select or Customize Tiered Pricing Package',
                        style: GoogleFonts.plusJakartaSans(
                          color: VoworaColors.champagneGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.12)),

          // 3 Tier Buttons Bar (Basic / Moderate / Premium)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: widget.vendor.packages.map((pkg) {
                final isSelected = _selectedPackage.id == pkg.id;
                String tierLabel = 'Basic';
                if (pkg.tier == PackageTier.moderate) tierLabel = 'Moderate ⭐';
                if (pkg.tier == PackageTier.premium) tierLabel = 'Premium';

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedPackage = pkg);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? VoworaColors.champagneGold
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? VoworaColors.champagneGold
                              : Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            tierLabel,
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳${pkg.basePrice.toStringAsFixed(0)}',
                            style: GoogleFonts.playfairDisplay(
                              color: isSelected ? Colors.black : VoworaColors.champagneGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Selected Package Details & Customizable List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner describing selected tier
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: VoworaColors.champagneGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: VoworaColors.champagneGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedPackage.name,
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: VoworaColors.champagneGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _selectedPackage.tier.name.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _selectedPackage.description,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customization Instructions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customize Package Options',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Check/Uncheck items',
                        style: GoogleFonts.plusJakartaSans(
                          color: VoworaColors.champagneGold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // List of Items in this Tier
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedPackage.items.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _selectedPackage.items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.isSelected
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.isSelected
                                ? VoworaColors.champagneGold.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: item.isSelected,
                              activeColor: VoworaColors.champagneGold,
                              checkColor: Colors.black,
                              onChanged: (val) {
                                setState(() {
                                  item.isSelected = val ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      if (item.isDefaultIncluded) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white12,
                                            borderRadius:
                                            BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Included',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white70,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.description,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              item.isDefaultIncluded && item.isSelected
                                  ? 'Included'
                                  : '+৳${item.defaultPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.playfairDisplay(
                                color: VoworaColors.champagneGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
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

          // Bottom Dynamic Calculation & Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF100E0D),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Customized Estimate',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '৳${_selectedPackage.calculateTotalPrice().toStringAsFixed(0)}',
                      style: GoogleFonts.playfairDisplay(
                        color: VoworaColors.champagneGold,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: VoworaColors.champagneGold,
                            content: Text(
                              'Customized quote sent for "${widget.vendor.name}"!',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VoworaColors.champagneGold,
                        foregroundColor: const Color(0xFF141210),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Book / Request Quote',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
