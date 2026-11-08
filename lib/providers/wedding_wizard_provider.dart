import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/supabase_database_service.dart';
import '../models/wedding_booking_model.dart';

class WeddingWizardProvider extends ChangeNotifier {
  int _currentStep = 0; // 0: Entry, 1: Details, 2: Venue, 3: Package, 4: Decor, 5: Catering, 6: Guests, 7: Photography, 8: Entertainment, 9: Checklist, 10: Budget, 11: Invitation, 12: Payment, 13: Summary, 14: Confirmation, 15: Main Dashboard
  
  late WeddingBookingModel _booking;

  // Repositories / Options Lists
  late List<VenueModel> _venues;
  late List<WeddingPackageModel> _packages;
  late List<DecorationItemModel> _decorations;
  late List<CateringItemModel> _cateringPackages;
  late List<PhotographyServiceModel> _photographyServices;
  late List<EntertainmentOptionModel> _entertainmentOptions;
  late List<WeddingNotificationModel> _notifications;

  int get currentStep => _currentStep;
  WeddingBookingModel get booking => _booking;

  List<VenueModel> get venues => _venues;
  List<WeddingPackageModel> get packages => _packages;
  List<DecorationItemModel> get decorations => _decorations;
  List<CateringItemModel> get cateringPackages => _cateringPackages;
  List<PhotographyServiceModel> get photographyServices => _photographyServices;
  List<EntertainmentOptionModel> get entertainmentOptions => _entertainmentOptions;
  List<WeddingNotificationModel> get notifications => _notifications;

  WeddingWizardProvider() {
    _initBookingAndMockData();
  }

  void _initBookingAndMockData() {
    // Venues
    _venues = [
      VenueModel(
        id: 'v1',
        name: 'Radisson Garden Ballroom',
        location: 'Dhanmondi / Airport Road, Dhaka',
        capacity: 500,
        rating: 4.9,
        price: 85000.0,
        isAvailable: true,
        venueType: VenueType.indoor,
        facilities: ['Central AC', 'Bridal Suite', 'Valet Parking', 'Generator Backup'],
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3',
        description: 'Grand royal crystal chandelier ballroom suitable for luxury weddings.',
      ),
      VenueModel(
        id: 'v2',
        name: 'Grand Heritage Garden Resort',
        location: 'Purbachal, Dhaka',
        capacity: 800,
        rating: 4.8,
        price: 120000.0,
        isAvailable: true,
        venueType: VenueType.both,
        facilities: ['Lawn Garden', 'Lake View Stage', 'Poolside Lounge', 'Helipad'],
        imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552',
        description: 'Sprawling lakeside outdoor garden venue with natural floral arches.',
      ),
      VenueModel(
        id: 'v3',
        name: 'Pan Pacific Crystal Hall',
        location: 'Kawran Bazar, Dhaka',
        capacity: 400,
        rating: 4.7,
        price: 70000.0,
        isAvailable: true,
        venueType: VenueType.indoor,
        facilities: ['5-Star Catering', 'VIP Lounge', 'Stage Lighting', 'Audio System'],
        imageUrl: 'https://images.unsplash.com/photo-1544077960-604201fe74bc',
        description: 'Elegantly decorated luxury hotel hall for grand family receptions.',
      ),
    ];

    // Packages
    _packages = [
      WeddingPackageModel(
        id: 'pkg1',
        name: 'Basic Celebration',
        tier: 'Basic',
        targetAudience: 'Suitable for small intimate weddings (Up to 150 guests)',
        price: 95000.0,
        decorationSummary: 'Classic Floral Arch & Entry Carpet',
        cateringSummary: 'Standard Kacchi & Dessert Menu',
        photographySummary: '1 Senior Photographer (6 Hours)',
        videographySummary: 'Full HD Highlights Video',
        stageSummary: 'Traditional Velvet Sofa Stage',
        lightingSummary: 'Warm Ambient Spotlights',
        soundSummary: 'Dual Speaker Sound System',
      ),
      WeddingPackageModel(
        id: 'pkg2',
        name: 'Standard Royal Package',
        tier: 'Standard',
        targetAudience: 'Suitable for medium weddings (200 - 400 guests)',
        price: 185000.0,
        decorationSummary: '3D Floral Stage, Tunnel Entrance & Centerpieces',
        cateringSummary: 'Royal Shahi Buffet & Dessert Bar',
        photographySummary: '2 Senior Photographers + 1 Cinematographer',
        videographySummary: '4K Cinematic Film + Teaser Reel',
        stageSummary: '30ft Mirror Floor Royal Stage',
        lightingSummary: 'Moving Head Beam Lights & Fog Blasts',
        soundSummary: 'Pro Line Array Sound System',
      ),
      WeddingPackageModel(
        id: 'pkg3',
        name: 'Imperial Deluxe Package',
        tier: 'Premium',
        targetAudience: 'Ultra luxury experience for grand royal weddings (500+ guests)',
        price: 320000.0,
        decorationSummary: 'Full Venue Transformation, Crystal Canopy & Live Flowers',
        cateringSummary: '5-Star Shahi & International Fusion Buffet',
        photographySummary: 'Chief Photographer + 2 Assistants + 2 Cinematographers',
        videographySummary: '4K Drone Aerials + Same Day Edit Trailer',
        stageSummary: 'Custom 3D Theme Stage with Cold Pyros',
        lightingSummary: 'Laser Matrix, Haze & Cold Fire Blasts',
        soundSummary: 'Concert Grade Sound & Live DJ Console',
      ),
    ];

    // Decorations
    _decorations = [
      DecorationItemModel(
        id: 'd1',
        name: 'Luxury Floral Arch',
        category: 'Wedding Arch',
        themeName: 'Luxury Floral Arch',
        description: 'Handcrafted fresh white & blush rose entrance archway.',
        price: 25000.0,
        imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552',
        isSelected: true,
      ),
      DecorationItemModel(
        id: 'd2',
        name: 'Classic White Theme Stage',
        category: 'Stage Decoration',
        themeName: 'Classic White Theme',
        description: 'Clean white silk drapes with crystal chandelier stage.',
        price: 45000.0,
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3',
        isSelected: true,
      ),
      DecorationItemModel(
        id: 'd3',
        name: 'Royal Red Floral Tunnel',
        category: 'Entrance Decoration',
        themeName: 'Royal Red Theme',
        description: 'Deep red rose arch tunnel with fairy light pathway.',
        price: 30000.0,
        imageUrl: 'https://images.unsplash.com/photo-1520854221256-17451cc331bf',
      ),
      DecorationItemModel(
        id: 'd4',
        name: 'Golden Crystal Table Centerpiece',
        category: 'Centerpieces',
        themeName: 'Modern Golden Theme',
        description: 'Tall golden candelabra with fresh eucalyptus & orchids.',
        price: 15000.0,
        imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622',
      ),
      DecorationItemModel(
        id: 'd5',
        name: 'Garden Canopy Fairy Lights',
        category: 'Lighting',
        themeName: 'Garden Wedding Theme',
        description: 'Thousands of twinkling warm LED fairy lights covering ceiling.',
        price: 20000.0,
        imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3',
        isSelected: true,
      ),
    ];

    // Catering
    _cateringPackages = [
      CateringItemModel(
        id: 'c1',
        packageName: 'Royal Shahi Buffet Menu',
        perPersonPrice: 650.0,
        appetizers: ['Chicken Reshmi Kebab', 'Paneer Tikka', 'Borhani'],
        mainCourse: ['Special Mutton Kacchi Biryani', 'Chicken Roast', 'Beef Bhuna'],
        riceDishes: ['Shahi Basmati Kacchi', 'Plain Polao'],
        meatDishes: ['Mutton Kacchi', 'Chicken Roast', 'Beef Rezala'],
        fishDishes: ['Vetki Fish Fry'],
        vegetables: ['Shahi Mixed Vegetable'],
        desserts: ['Jorda', 'Firni', 'Ice Cream'],
        drinks: ['Borhani', 'Soft Drinks', 'Mineral Water'],
      ),
      CateringItemModel(
        id: 'c2',
        packageName: 'Grand International Fusion Menu',
        perPersonPrice: 950.0,
        appetizers: ['Prawn Thermidor', 'Chicken Satay', 'Fresh Salad Bar'],
        mainCourse: ['Mutton Kacchi', 'Grilled Salmon', 'Beef Steak Medallions'],
        riceDishes: ['Kacchi Biryani', 'Fried Rice'],
        meatDishes: ['Mutton Kacchi', 'Chicken Roast'],
        fishDishes: ['Butter Garlic Prawns', 'Vetki Fry'],
        vegetables: ['Sauteed Vegetables', 'Creamy Mushroom'],
        desserts: ['Gourmet Pastries', 'Firni', 'Chocolate Fountain'],
        drinks: ['Live Mocktail Bar', 'Coffee & Tea Station'],
      ),
    ];

    // Photography
    _photographyServices = [
      PhotographyServiceModel(
        id: 'p1',
        title: 'Cinematic Photography & Film',
        description: '2 Lead Photographers + 1 Cinematographer for 4K video recording.',
        price: 35000.0,
        duration: 'Full Wedding Day (up to 8 Hours)',
        portfolioImages: [
          'https://images.unsplash.com/photo-1537633552985-df8429e8048b',
          'https://images.unsplash.com/photo-1606800052052-a08af7148866',
        ],
        isBooked: true,
      ),
      PhotographyServiceModel(
        id: 'p2',
        title: 'Pre-Wedding & Outdoor Couple Shoot',
        description: 'Scenic outdoor couple photoshoot with drone cinematic teaser.',
        price: 20000.0,
        duration: 'Half Day (4 Hours)',
        portfolioImages: [
          'https://images.unsplash.com/photo-1519741497674-611481863552',
        ],
      ),
      PhotographyServiceModel(
        id: 'p3',
        title: '4K Drone Aerial Coverage',
        description: 'Aerial drone footage of venue entrance, fireworks & stage.',
        price: 15000.0,
        duration: 'Event Coverage',
        portfolioImages: [],
        isBooked: true,
      ),
    ];

    // Entertainment
    _entertainmentOptions = [
      EntertainmentOptionModel(
        id: 'e1',
        name: 'Live DJ & Concert Sound System',
        category: 'DJ',
        description: 'Professional DJ with energetic dance playlist & laser show.',
        price: 20000.0,
        duration: '3 Hours',
        imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819',
        isSelected: true,
      ),
      EntertainmentOptionModel(
        id: 'e2',
        name: 'Acoustic Band & Live Singer',
        category: 'Live Band',
        description: 'Live romantic acoustic band for dinner background music.',
        price: 35000.0,
        duration: '2 Hours',
        imageUrl: 'https://images.unsplash.com/photo-1465847899084-d164df4dedc6',
        isSelected: true,
      ),
      EntertainmentOptionModel(
        id: 'e3',
        name: 'Cold Pyro Sparkler & Fog Blast Effects',
        category: 'Special Effects',
        description: '6 cold pyro blasts during entrance & cake cutting.',
        price: 12000.0,
        duration: 'Entrance Moment',
        imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
      ),
    ];

    // Default Pre-populated Tasks
    final defaultTasks = [
      WeddingTaskModel(
        id: 't1',
        title: 'Select Wedding Venue',
        dueDate: DateTime.now().subtract(const Duration(days: 20)),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
      ),
      WeddingTaskModel(
        id: 't2',
        title: 'Book Stage & Floral Decoration',
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
      ),
      WeddingTaskModel(
        id: 't3',
        title: 'Book Catering Menu',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
      ),
      WeddingTaskModel(
        id: 't4',
        title: 'Book Photographer & Videographer',
        dueDate: DateTime.now(),
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
      ),
      WeddingTaskModel(
        id: 't5',
        title: 'Prepare Guest List',
        dueDate: DateTime.now().add(const Duration(days: 10)),
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
      ),
      WeddingTaskModel(
        id: 't6',
        title: 'Send Digital Invitations',
        dueDate: DateTime.now().add(const Duration(days: 20)),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
      ),
      WeddingTaskModel(
        id: 't7',
        title: 'Select Wedding Dress & Jewelry',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
      ),
      WeddingTaskModel(
        id: 't8',
        title: 'Book Makeup Artist & Hair Stylist',
        dueDate: DateTime.now().add(const Duration(days: 40)),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
      ),
      WeddingTaskModel(
        id: 't9',
        title: 'Arrange Transportation & Cars',
        dueDate: DateTime.now().add(const Duration(days: 50)),
        priority: TaskPriority.low,
        status: TaskStatus.pending,
      ),
      WeddingTaskModel(
        id: 't10',
        title: 'Final Venue Check & Audio Trial',
        dueDate: DateTime.now().add(const Duration(days: 110)),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
      ),
    ];

    _notifications = [];

    // Create Clean Initial Zero-Event Booking Object
    _booking = WeddingBookingModel(
      weddingId: '',
      brideName: '',
      groomName: '',
      bridePhone: '',
      groomPhone: '',
      weddingDate: DateTime.now().add(const Duration(days: 120)),
      weddingTime: '06:00 PM',
      weddingType: WeddingType.royal,
      expectedGuestCount: 300,
      description: '',
      selectedVenue: null,
      selectedPackage: null,
      selectedDecorations: [],
      selectedCateringPackage: null,
      guestsList: [],
      selectedMediaServices: [],
      selectedEntertainment: [],
      tasksList: _createDefaultTasks(),
      totalPlannedBudget: 0.0,
      paymentHistory: [],
      isConfirmed: false,
    );
  }

  // --- Fetch User Saved Wedding Event From Supabase Database ---
  Future<void> loadUserWeddingFromSupabase(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    if (!SupabaseDatabaseService.isReady) return;

    try {
      final data = await SupabaseDatabaseService.fetchUserWedding(userId);
      if (data != null && data.isNotEmpty) {
        final weddingId = data['id'] ?? 'WED-2026-0001';

        // Fetch guests for this wedding from Supabase guests table
        final guestRows = await SupabaseDatabaseService.fetchGuestsByWeddingId(weddingId);
        final loadedGuests = guestRows.map((json) {
          return WeddingGuestModel(
            id: json['id'] ?? '',
            name: json['name'] ?? 'Guest',
            phone: json['phone'] ?? '',
            email: json['email'] ?? '',
            groupFamily: json['group_family'] ?? 'Friends',
            numberOfGuests: json['number_of_guests'] ?? 1,
            isInvited: json['is_invited'] ?? true,
            rsvpStatus: RSVPStatus.values.firstWhere(
              (e) => e.name == json['rsvp_status'],
              orElse: () => RSVPStatus.pending,
            ),
          );
        }).toList();

        _booking = WeddingBookingModel(
          weddingId: weddingId,
          brideName: data['bride_name'] ?? '',
          groomName: data['groom_name'] ?? '',
          bridePhone: data['bride_phone'] ?? '',
          groomPhone: data['groom_phone'] ?? '',
          weddingDate: DateTime.tryParse(data['wedding_date'] ?? '') ?? DateTime.now().add(const Duration(days: 120)),
          weddingTime: data['wedding_time'] ?? '06:00 PM',
          weddingType: WeddingType.values.firstWhere(
            (e) => e.name == data['wedding_type'],
            orElse: () => WeddingType.royal,
          ),
          expectedGuestCount: data['expected_guest_count'] ?? 300,
          description: data['description'] ?? '',
          bridePhotoUrl: data['bride_photo_url'],
          groomPhotoUrl: data['groom_photo_url'],
          coverPhotoUrl: data['cover_photo_url'],
          selectedVenue: data['venue_name'] != null ? VenueModel(
            id: 'v_supabase',
            name: data['venue_name'],
            location: data['venue_location'] ?? 'Dhaka',
            capacity: data['expected_guest_count'] ?? 300,
            rating: 4.9,
            price: 85000.0,
            venueType: VenueType.indoor,
            facilities: ['AC', 'Bridal Suite'],
            imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3',
            description: 'Venue selected via Supabase',
          ) : null,
          guestsList: loadedGuests, // Real guests from Supabase!
          totalPlannedBudget: (data['total_planned_budget'] as num?)?.toDouble() ?? 400000.0,
          isConfirmed: data['is_confirmed'] ?? true,
        );
        _currentStep = 15; // Set to Dashboard ready
        notifyListeners();
      } else {
        // Event was deleted in Supabase -> Reset to clean 0-event state!
        resetForNewUser();
      }
    } catch (e) {
      debugPrint('❌ Error loading user wedding: $e');
    }
  }

  // --- Reset State For New User Account ---
  void resetForNewUser() {
    _currentStep = 0;
    _booking = WeddingBookingModel(
      weddingId: '',
      brideName: '',
      groomName: '',
      bridePhone: '',
      groomPhone: '',
      weddingDate: DateTime.now().add(const Duration(days: 120)),
      weddingTime: '06:00 PM',
      weddingType: WeddingType.royal,
      expectedGuestCount: 300,
      description: '',
      selectedVenue: null,
      selectedPackage: null,
      selectedDecorations: [],
      selectedCateringPackage: null,
      guestsList: [],
      selectedMediaServices: [],
      selectedEntertainment: [],
      tasksList: _createDefaultTasks(),
      totalPlannedBudget: 0.0,
      paymentHistory: [],
      isConfirmed: false,
    );
    notifyListeners();
  }

  // --- Start New Booking Creation Wizard ---
  void startNewBookingWizard() {
    _currentStep = 1;
    _booking = WeddingBookingModel(
      weddingId: 'WED-2026-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999)).toString()}',
      brideName: '',
      groomName: '',
      bridePhone: '',
      groomPhone: '',
      weddingDate: DateTime.now().add(const Duration(days: 120)),
      weddingTime: '06:00 PM',
      weddingType: WeddingType.royal,
      expectedGuestCount: 300,
      description: 'Our special dream wedding celebration.',
      selectedVenue: _venues.isNotEmpty ? _venues[0] : null,
      selectedPackage: _packages.length > 1 ? _packages[1] : null,
      selectedDecorations: _decorations.isNotEmpty ? [_decorations[0]] : [],
      selectedCateringPackage: _cateringPackages.isNotEmpty ? _cateringPackages[0] : null,
      guestsList: [],
      selectedMediaServices: _photographyServices.isNotEmpty ? [_photographyServices[0]] : [],
      selectedEntertainment: _entertainmentOptions.isNotEmpty ? [_entertainmentOptions[0]] : [],
      tasksList: _createDefaultTasks(),
      totalPlannedBudget: 400000.0,
      paymentHistory: [],
      isConfirmed: false,
    );
    notifyListeners();
  }

  List<WeddingTaskModel> _createDefaultTasks() {
    return [
      WeddingTaskModel(
        id: 't1',
        title: 'Select Wedding Venue',
        dueDate: DateTime.now().subtract(const Duration(days: 20)),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
      ),
      WeddingTaskModel(
        id: 't2',
        title: 'Book Stage & Floral Decoration',
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
      ),
      WeddingTaskModel(
        id: 't3',
        title: 'Book Catering Menu',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
      ),
      WeddingTaskModel(
        id: 't4',
        title: 'Book Photographer & Videographer',
        dueDate: DateTime.now(),
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
      ),
      WeddingTaskModel(
        id: 't5',
        title: 'Prepare Guest List',
        dueDate: DateTime.now().add(const Duration(days: 10)),
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
      ),
      WeddingTaskModel(
        id: 't6',
        title: 'Send Digital Invitations',
        dueDate: DateTime.now().add(const Duration(days: 20)),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
      ),
      WeddingTaskModel(
        id: 't7',
        title: 'Select Wedding Dress & Jewelry',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
      ),
      WeddingTaskModel(
        id: 't8',
        title: 'Book Makeup Artist & Hair Stylist',
        dueDate: DateTime.now().add(const Duration(days: 40)),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
      ),
      WeddingTaskModel(
        id: 't9',
        title: 'Arrange Transportation & Cars',
        dueDate: DateTime.now().add(const Duration(days: 50)),
        priority: TaskPriority.low,
        status: TaskStatus.pending,
      ),
      WeddingTaskModel(
        id: 't10',
        title: 'Final Venue Check & Audio Trial',
        dueDate: DateTime.now().add(const Duration(days: 110)),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
      ),
    ];
  }

  // --- Navigation & Wizard Step Control ---
  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    _currentStep++;
    notifyListeners();
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // --- Step 2: Couple & Wedding Information ---
  void updateWeddingDetails({
    required String brideName,
    required String groomName,
    required String bridePhone,
    required String groomPhone,
    required DateTime weddingDate,
    required String weddingTime,
    required WeddingType weddingType,
    required int expectedGuestCount,
    required String description,
  }) {
    _booking.brideName = brideName;
    _booking.groomName = groomName;
    _booking.bridePhone = bridePhone;
    _booking.groomPhone = groomPhone;
    _booking.weddingDate = weddingDate;
    _booking.weddingTime = weddingTime;
    _booking.weddingType = weddingType;
    _booking.expectedGuestCount = expectedGuestCount;
    _booking.description = description;
    notifyListeners();
  }

  // --- Step 3: Venue Selection ---
  void selectVenue(VenueModel venue) {
    _booking.selectedVenue = venue;
    notifyListeners();
  }

  // --- Step 4: Package Selection ---
  void selectPackage(WeddingPackageModel pkg) {
    _booking.selectedPackage = pkg;
    notifyListeners();
  }

  // --- Step 5: Decoration Selection ---
  void toggleDecoration(DecorationItemModel item) {
    final index = _booking.selectedDecorations.indexWhere((d) => d.id == item.id);
    if (index != -1) {
      _booking.selectedDecorations.removeAt(index);
    } else {
      _booking.selectedDecorations.add(item);
    }
    notifyListeners();
  }

  // --- Step 6: Catering Selection ---
  void selectCateringPackage(CateringItemModel catering, int guestsCount, String specialReq) {
    _booking.selectedCateringPackage = catering;
    _booking.expectedGuestCount = guestsCount;
    _booking.specialFoodRequirements = specialReq;
    notifyListeners();
  }

  // --- Step 7: Guest Management ---
  void addGuest(WeddingGuestModel guest) {
    _booking.guestsList.add(guest);
    SupabaseDatabaseService.submitGuestRSVP(
      weddingId: _booking.weddingId,
      name: guest.name,
      phone: guest.phone,
      status: guest.rsvpStatus,
      attendeesCount: guest.numberOfGuests,
      mealPref: 'Regular',
      specialRequest: '',
    );
    notifyListeners();
  }

  void updateGuest(WeddingGuestModel guest) {
    final idx = _booking.guestsList.indexWhere((g) => g.id == guest.id);
    if (idx != -1) {
      _booking.guestsList[idx] = guest;
      SupabaseDatabaseService.updateGuestRSVPStatus(guest.id, guest.rsvpStatus);
      notifyListeners();
    }
  }

  void deleteGuest(String id) {
    _booking.guestsList.removeWhere((g) => g.id == id);
    SupabaseDatabaseService.deleteGuest(id);
    notifyListeners();
  }

  // --- Step 8: Media & Photography Selection ---
  void addMediaService(PhotographyServiceModel service) {
    _booking.selectedMediaServices.add(service);
    notifyListeners();
  }

  void updateMediaService(PhotographyServiceModel service) {
    final idx = _booking.selectedMediaServices.indexWhere((s) => s.id == service.id);
    if (idx != -1) {
      _booking.selectedMediaServices[idx] = service;
      notifyListeners();
    }
  }

  void deleteMediaService(String id) {
    _booking.selectedMediaServices.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void toggleMediaService(PhotographyServiceModel service) {
    final idx = _booking.selectedMediaServices.indexWhere((s) => s.id == service.id);
    if (idx != -1) {
      _booking.selectedMediaServices.removeAt(idx);
    } else {
      _booking.selectedMediaServices.add(service);
    }
    notifyListeners();
  }

  // --- Step 9: Entertainment Selection ---
  void toggleEntertainmentOption(EntertainmentOptionModel option) {
    final idx = _booking.selectedEntertainment.indexWhere((e) => e.id == option.id);
    if (idx != -1) {
      _booking.selectedEntertainment.removeAt(idx);
    } else {
      _booking.selectedEntertainment.add(option);
    }
    notifyListeners();
  }

  // --- Step 10: Task List Management ---
  void toggleTaskStatus(String id) {
    final idx = _booking.tasksList.indexWhere((t) => t.id == id);
    if (idx != -1) {
      if (_booking.tasksList[idx].status == TaskStatus.completed) {
        _booking.tasksList[idx].status = TaskStatus.pending;
      } else {
        _booking.tasksList[idx].status = TaskStatus.completed;
      }
      notifyListeners();
    }
  }

  void addTask(WeddingTaskModel task) {
    _booking.tasksList.add(task);
    notifyListeners();
  }

  void deleteTask(String id) {
    _booking.tasksList.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // --- Step 11: Budget Management ---
  void setTotalPlannedBudget(double budget) {
    _booking.totalPlannedBudget = budget;
    notifyListeners();
  }

  // --- Step 12: Invitation Design ---
  void updateInvitationDesign(InvitationTheme theme, String font) {
    _booking.invitationTheme = theme;
    _booking.fontStyle = font;
    notifyListeners();
  }

  // --- Step 13: Payment Recording ---
  void addPaymentRecord(PaymentRecordModel payment) {
    _booking.paymentHistory.insert(0, payment);

    // Sync to Supabase Database Realtime Table
    SupabaseDatabaseService.insertPaymentRecord(payment);

    notifyListeners();
  }

  // --- Photo Uploading via Phone Gallery ---
  Future<void> pickBridePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _booking.bridePhotoUrl = image.path;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> pickGroomPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _booking.groomPhotoUrl = image.path;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> pickCoverPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _booking.coverPhotoUrl = image.path;
        notifyListeners();
      }
    } catch (_) {}
  }

  // --- Step 14 & 15: Final Confirmation ---
  void confirmWeddingBooking({String? userId}) {
    _booking.isConfirmed = true;
    _booking.weddingId = 'WED-2026-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999)).toString()}';
    _currentStep = 14; // Confirmation screen step

    // Sync to Supabase Database
    SupabaseDatabaseService.upsertWedding(_booking, userId: userId);

    notifyListeners();
  }

  // --- Cancel and Delete Active Wedding Event ---
  Future<void> cancelAndDeleteWedding() async {
    final deletedId = _booking.weddingId;
    resetForNewUser();

    if (SupabaseDatabaseService.isReady) {
      await SupabaseDatabaseService.deleteWedding(deletedId);
    }

    notifyListeners();
  }
}
