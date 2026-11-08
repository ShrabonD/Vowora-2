import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/supabase_database_service.dart';
import '../models/wedding_booking_model.dart';
import '../models/wedding_ecosystem_models.dart';

class WeddingEcosystemProvider extends ChangeNotifier {
  UserRole _activeRole = UserRole.client;
  
  // Active Wedding Booking (Client's active wedding, linked by WED-8F42K9)
  late WeddingBookingModel _activeWedding;

  // Live Timer
  Timer? _countdownTimer;
  int _countdownDays = 0;
  int _countdownHours = 0;
  int _countdownMinutes = 0;
  int _countdownSeconds = 0;

  // Marketplace Service Providers
  late List<ServiceProviderModel> _serviceProviders;
  late List<ServiceBookingRequestModel> _bookingRequests;

  // Wedding Photos Gallery
  late List<WeddingGalleryPhotoModel> _weddingPhotos;

  // Wedding Event Schedule
  late List<WeddingScheduleItemModel> _scheduleItems;

  // Ecosystem Notifications
  late List<WeddingNotificationModel> _clientNotifications;
  late List<WeddingNotificationModel> _guestNotifications;
  late List<WeddingNotificationModel> _providerNotifications;

  // Current Active Joined Wedding for Guest Role
  WeddingBookingModel? _joinedGuestWedding;

  UserRole get activeRole => _activeRole;
  WeddingBookingModel get activeWedding => _activeWedding;
  WeddingBookingModel? get joinedGuestWedding => _joinedGuestWedding;

  int get countdownDays => _countdownDays;
  int get countdownHours => _countdownHours;
  int get countdownMinutes => _countdownMinutes;
  int get countdownSeconds => _countdownSeconds;

  List<ServiceProviderModel> get serviceProviders => _serviceProviders;
  List<ServiceBookingRequestModel> get bookingRequests => _bookingRequests;
  List<WeddingGalleryPhotoModel> get weddingPhotos => _weddingPhotos;
  List<WeddingScheduleItemModel> get scheduleItems => _scheduleItems;

  List<WeddingNotificationModel> get clientNotifications => _clientNotifications;
  List<WeddingNotificationModel> get guestNotifications => _guestNotifications;
  List<WeddingNotificationModel> get providerNotifications => _providerNotifications;

  WeddingEcosystemProvider() {
    _initEcosystemData();
    _startLiveCountdown();
  }

  void setActiveRole(UserRole role) {
    _activeRole = role;
    notifyListeners();
  }

  void _startLiveCountdown() {
    _updateTimerValues();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimerValues();
    });
  }

  void _updateTimerValues() {
    final now = DateTime.now();
    final target = _activeWedding.weddingDate;
    final diff = target.difference(now);

    if (diff.isNegative) {
      _countdownDays = 0;
      _countdownHours = 0;
      _countdownMinutes = 0;
      _countdownSeconds = 0;
    } else {
      _countdownDays = diff.inDays;
      _countdownHours = diff.inHours % 24;
      _countdownMinutes = diff.inMinutes % 60;
      _countdownSeconds = diff.inSeconds % 60;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initEcosystemData() {
    // 1. Initial Clean Zero-Event State for New User
    _activeWedding = WeddingBookingModel(
      weddingId: 'WED-8F42K9',
      brideName: '',
      groomName: '',
      bridePhone: '',
      groomPhone: '',
      weddingDate: DateTime.now().add(const Duration(days: 120)),
      weddingTime: '06:00 PM',
      weddingType: WeddingType.royal,
      expectedGuestCount: 300,
      description: '',
      totalPlannedBudget: 0.0,
      isConfirmed: false,
      guestsList: [],
    );

    // 2. Service Providers Marketplace Directory
    _serviceProviders = [
      ServiceProviderModel(
        id: 'sp1',
        name: 'Dream Lens Studio',
        type: ServiceProviderType.photographer,
        location: 'Sylhet & Dhaka',
        rating: 4.9,
        reviewsCount: 142,
        startingPrice: 25000.0,
        portfolioCount: 48,
        profileImageUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b',
        bio: 'Award winning wedding photography & 4K cinematic reels studio.',
        portfolioImages: [
          'https://images.unsplash.com/photo-1537633552985-df8429e8048b',
          'https://images.unsplash.com/photo-1606800052052-a08af7148866',
          'https://images.unsplash.com/photo-1519741497674-611481863552',
        ],
        packages: [
          WeddingPackageModel(
            id: 'sp1_pkg1',
            name: 'Basic Photo Package',
            tier: 'Basic',
            targetAudience: '1 Senior Photographer (6 Hours)',
            price: 25000.0,
            decorationSummary: 'N/A',
            cateringSummary: 'N/A',
            photographySummary: '100 Soft edited copies + Printed Album',
            videographySummary: 'N/A',
            stageSummary: 'N/A',
            lightingSummary: 'N/A',
            soundSummary: 'N/A',
          ),
          WeddingPackageModel(
            id: 'sp1_pkg2',
            name: 'Cinematic Dream Package',
            tier: 'Premium',
            targetAudience: '2 Lead Photographers + 1 Cinematographer + Drone',
            price: 55000.0,
            decorationSummary: 'N/A',
            cateringSummary: 'N/A',
            photographySummary: 'Unlimited High-res edits + 2 Velvet Photobooks',
            videographySummary: '4K Cinematic Film + Teaser Reel',
            stageSummary: 'N/A',
            lightingSummary: 'N/A',
            soundSummary: 'N/A',
          ),
        ],
      ),
      ServiceProviderModel(
        id: 'sp2',
        name: 'Blossom Floral Couture',
        type: ServiceProviderType.decorator,
        location: 'Dhanmondi, Dhaka',
        rating: 4.8,
        reviewsCount: 96,
        startingPrice: 45000.0,
        portfolioCount: 32,
        profileImageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3',
        bio: 'Luxury floral arches, crystal stage drapes & ambient lighting.',
        portfolioImages: [
          'https://images.unsplash.com/photo-1519167758481-83f550bb49b3',
          'https://images.unsplash.com/photo-1520854221256-17451cc331bf',
        ],
        packages: [
          WeddingPackageModel(
            id: 'sp2_pkg1',
            name: 'Royal Floral Stage Theme',
            tier: 'Standard',
            targetAudience: '30ft stage with fresh rose backdrop',
            price: 65000.0,
            decorationSummary: 'Full stage, entrance arch & table centerpieces',
            cateringSummary: 'N/A',
            photographySummary: 'N/A',
            videographySummary: 'N/A',
            stageSummary: '3D Mirror floor stage',
            lightingSummary: 'Warm LED spotlights',
            soundSummary: 'N/A',
          ),
        ],
      ),
      ServiceProviderModel(
        id: 'sp3',
        name: 'Royal Shahi Feast Catering',
        type: ServiceProviderType.caterer,
        location: 'Banani, Dhaka',
        rating: 4.9,
        reviewsCount: 210,
        startingPrice: 650.0,
        portfolioCount: 18,
        profileImageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033',
        bio: 'Authentic Mutton Kacchi Biryani & Moghul Shahi Buffet spreads.',
        portfolioImages: [
          'https://images.unsplash.com/photo-1555244162-803834f70033',
        ],
        packages: [],
      ),
    ];

    // 3. Service Booking Requests
    _bookingRequests = [
      ServiceBookingRequestModel(
        id: 'bk1',
        providerId: 'sp1',
        providerName: 'Dream Lens Studio',
        providerType: ServiceProviderType.photographer,
        clientId: 'client1',
        clientName: 'Ariesha Rahman',
        weddingId: 'WED-8F42K9',
        weddingName: 'Ariesha & Tariq Wedding',
        weddingDate: DateTime.now().add(const Duration(days: 76)),
        venueName: 'Radisson Garden Ballroom',
        packageName: 'Cinematic Dream Package',
        totalPrice: 55000.0,
        advancePaid: 20000.0,
        status: BookingRequestStatus.accepted,
        paymentStatus: 'Partially Paid',
      ),
      ServiceBookingRequestModel(
        id: 'bk2',
        providerId: 'sp1',
        providerName: 'Dream Lens Studio',
        providerType: ServiceProviderType.photographer,
        clientId: 'client2',
        clientName: 'Nusrat & Shahab',
        weddingId: 'WED-3901M2',
        weddingName: 'Nusrat & Shahab Wedding',
        weddingDate: DateTime.now().add(const Duration(days: 45)),
        venueName: 'Pan Pacific Crystal Hall',
        packageName: 'Basic Photo Package',
        totalPrice: 25000.0,
        advancePaid: 0.0,
        status: BookingRequestStatus.pending,
        paymentStatus: 'Pending',
      ),
    ];

    _bookingRequests = [];
    _weddingPhotos = [];
    _scheduleItems = [];
    _clientNotifications = [];
    _guestNotifications = [];
    _providerNotifications = [];

    // Attach Supabase Realtime WebSocket Stream Subscriptions
    _subscribeToRealtimeStreams(_activeWedding.weddingId);
  }

  StreamSubscription? _guestsSubscription;
  StreamSubscription? _bookingsSubscription;
  StreamSubscription? _photosSubscription;
  StreamSubscription? _scheduleSubscription;

  void _subscribeToRealtimeStreams(String weddingId) {
    _guestsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _photosSubscription?.cancel();
    _scheduleSubscription?.cancel();

    // Clear previous in-memory guest list when changing active wedding
    _activeWedding.guestsList = [];

    // 1. Guests Stream
    final guestsStream = SupabaseDatabaseService.streamGuests(weddingId);
    if (guestsStream != null) {
      _guestsSubscription = guestsStream.listen((data) {
        final updatedGuests = data.map((json) {
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

        if (_activeRole == UserRole.guest && _joinedGuestWedding != null) {
          _joinedGuestWedding!.guestsList = updatedGuests;
        } else {
          _activeWedding.guestsList = updatedGuests;
        }
        notifyListeners();
      });
    }

    // 2. Service Bookings Stream
    final bookingsStream = SupabaseDatabaseService.streamBookings(weddingId);
    if (bookingsStream != null) {
      _bookingsSubscription = bookingsStream.listen((data) {
        if (data.isNotEmpty) {
          _bookingRequests = data.map((json) {
            return ServiceBookingRequestModel(
              id: json['id'] ?? '',
              providerId: json['provider_id'] ?? '',
              providerName: json['provider_name'] ?? 'Vendor',
              providerType: ServiceProviderType.values.firstWhere(
                (e) => e.name == json['provider_type'],
                orElse: () => ServiceProviderType.photographer,
              ),
              clientId: json['client_id'] ?? '',
              clientName: json['client_name'] ?? '',
              weddingId: json['wedding_id'] ?? '',
              weddingName: json['wedding_name'] ?? '',
              weddingDate: DateTime.tryParse(json['wedding_date'] ?? '') ?? DateTime.now(),
              venueName: json['venue_name'] ?? '',
              packageName: json['package_name'] ?? '',
              totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
              advancePaid: (json['advance_paid'] as num?)?.toDouble() ?? 0.0,
              status: BookingRequestStatus.values.firstWhere(
                (e) => e.name == json['status'],
                orElse: () => BookingRequestStatus.pending,
              ),
              paymentStatus: json['payment_status'] ?? 'Pending',
            );
          }).toList();
          notifyListeners();
        }
      });
    }

    // 3. Photos Stream
    final photosStream = SupabaseDatabaseService.streamPhotos(weddingId);
    if (photosStream != null) {
      _photosSubscription = photosStream.listen((data) {
        if (data.isNotEmpty) {
          _weddingPhotos = data.map((json) {
            return WeddingGalleryPhotoModel(
              id: json['id'] ?? '',
              weddingId: json['wedding_id'] ?? '',
              albumName: json['album_name'] ?? 'Ceremony',
              imageUrl: json['image_url'] ?? '',
              uploaderId: json['uploader_id'] ?? '',
              uploaderName: json['uploader_name'] ?? '',
              uploaderRole: UserRole.values.firstWhere(
                (e) => e.name == json['uploader_role'],
                orElse: () => UserRole.client,
              ),
              uploadTime: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
              visibility: PhotoVisibility.values.firstWhere(
                (e) => e.name == json['visibility'],
                orElse: () => PhotoVisibility.publicToGuests,
              ),
              approvalStatus: PhotoApprovalStatus.values.firstWhere(
                (e) => e.name == json['approval_status'],
                orElse: () => PhotoApprovalStatus.approved,
              ),
            );
          }).toList();
          notifyListeners();
        }
      });
    }

    // 4. Schedule Stream
    final scheduleStream = SupabaseDatabaseService.streamSchedule(weddingId);
    if (scheduleStream != null) {
      _scheduleSubscription = scheduleStream.listen((data) {
        if (data.isNotEmpty) {
          _scheduleItems = data.map((json) {
            return WeddingScheduleItemModel(
              id: json['id'] ?? '',
              weddingId: json['wedding_id'] ?? '',
              timeString: json['time_string'] ?? '',
              title: json['title'] ?? '',
              description: json['description'] ?? '',
              location: json['location'] ?? '',
            );
          }).toList();
          notifyListeners();
        }
      });
    }
  }

  // --- GUEST EVENT JOINING VIA SECRET CODE ---
  Future<bool> joinWeddingByCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;

    // 1. Query Supabase Database for exact Secret Event Code
    if (SupabaseDatabaseService.isReady) {
      final data = await SupabaseDatabaseService.fetchWeddingById(cleanCode);
      if (data != null && data.isNotEmpty) {
        _joinedGuestWedding = WeddingBookingModel(
          weddingId: data['id'] ?? cleanCode,
          brideName: data['bride_name'] ?? 'Bride',
          groomName: data['groom_name'] ?? 'Groom',
          bridePhone: data['bride_phone'] ?? '',
          groomPhone: data['groom_phone'] ?? '',
          weddingDate: DateTime.tryParse(data['wedding_date'] ?? '') ?? DateTime.now().add(const Duration(days: 90)),
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
            id: 'v_joined',
            name: data['venue_name'],
            location: data['venue_location'] ?? 'Dhaka',
            capacity: data['expected_guest_count'] ?? 300,
            rating: 4.9,
            price: 85000.0,
            venueType: VenueType.indoor,
            facilities: ['AC', 'Bridal Suite'],
            imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3',
            description: 'Venue selected by host',
          ) : null,
          totalPlannedBudget: (data['total_planned_budget'] as num?)?.toDouble() ?? 400000.0,
          isConfirmed: true,
        );

        _activeRole = UserRole.guest;
        _subscribeToRealtimeStreams(cleanCode);
        notifyListeners();
        return true;
      }
    }

    // 2. Fallback check if code matches active wedding
    if (cleanCode == _activeWedding.weddingId.toUpperCase() && _activeWedding.brideName.isNotEmpty) {
      _joinedGuestWedding = _activeWedding;
      _activeRole = UserRole.guest;
      _subscribeToRealtimeStreams(cleanCode);
      notifyListeners();
      return true;
    }

    return false;
  }

  void clearSessionData() {
    _guestsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _photosSubscription?.cancel();
    _scheduleSubscription?.cancel();

    _joinedGuestWedding = null;
    _activeRole = UserRole.client;

    _activeWedding = WeddingBookingModel(
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
      totalPlannedBudget: 0.0,
      isConfirmed: false,
      guestsList: [],
    );

    _bookingRequests = [];
    _weddingPhotos = [];
    _scheduleItems = [];
    _clientNotifications = [];
    _guestNotifications = [];
    _providerNotifications = [];

    notifyListeners();
  }

  // --- RSVP SUBMISSION FROM GUEST ---
  void submitGuestRSVP({
    required String name,
    required String phone,
    required RSVPStatus status,
    required int attendeesCount,
    required String mealPref,
    required String specialRequest,
  }) {
    final targetWedding = (_activeRole == UserRole.guest && _joinedGuestWedding != null)
        ? _joinedGuestWedding!
        : _activeWedding;

    final existingIdx = targetWedding.guestsList.indexWhere((g) => g.phone == phone || g.name == name);
    
    if (existingIdx != -1) {
      targetWedding.guestsList[existingIdx].rsvpStatus = status;
      targetWedding.guestsList[existingIdx].numberOfGuests = attendeesCount;
    } else {
      targetWedding.guestsList.add(
        WeddingGuestModel(
          id: 'g_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          phone: phone,
          email: 'guest@vowora.app',
          groupFamily: 'Friends',
          numberOfGuests: attendeesCount,
          isInvited: true,
          rsvpStatus: status,
        ),
      );
    }

    // Add alert notification for client
    _clientNotifications.insert(
      0,
      WeddingNotificationModel(
        id: 'cn_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New RSVP Submitted',
        message: '$name submitted RSVP: ${status.name.toUpperCase()} ($attendeesCount Guests).',
        time: DateTime.now(),
        icon: Icons.how_to_reg,
      ),
    );

    // Sync to Supabase Database Realtime Table under targetWedding.weddingId
    SupabaseDatabaseService.submitGuestRSVP(
      weddingId: targetWedding.weddingId,
      name: name,
      phone: phone,
      status: status,
      attendeesCount: attendeesCount,
      mealPref: mealPref,
      specialRequest: specialRequest,
    );

    notifyListeners();
  }

  // --- SERVICE PROVIDER ACTIONS ---
  void acceptBookingRequest(String requestId) {
    final idx = _bookingRequests.indexWhere((b) => b.id == requestId);
    if (idx != -1) {
      _bookingRequests[idx].status = BookingRequestStatus.accepted;
      _bookingRequests[idx].paymentStatus = 'Partially Paid';

      _clientNotifications.insert(
        0,
        WeddingNotificationModel(
          id: 'cn_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Booking Request Accepted 🎉',
          message: '${_bookingRequests[idx].providerName} accepted your request!',
          time: DateTime.now(),
          icon: Icons.task_alt,
        ),
      );

      // Sync to Supabase Database Realtime Table
      SupabaseDatabaseService.updateBookingStatus(requestId, BookingRequestStatus.accepted);

      notifyListeners();
    }
  }

  void rejectBookingRequest(String requestId) {
    final idx = _bookingRequests.indexWhere((b) => b.id == requestId);
    if (idx != -1) {
      _bookingRequests[idx].status = BookingRequestStatus.rejected;

      // Sync to Supabase Database Realtime Table
      SupabaseDatabaseService.updateBookingStatus(requestId, BookingRequestStatus.rejected);

      notifyListeners();
    }
  }

  void createBookingRequest({
    required ServiceProviderModel provider,
    required WeddingPackageModel package,
  }) {
    final request = ServiceBookingRequestModel(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      providerId: provider.id,
      providerName: provider.name,
      providerType: provider.type,
      clientId: 'active_client',
      clientName: '${_activeWedding.brideName} & ${_activeWedding.groomName}',
      weddingId: _activeWedding.weddingId,
      weddingName: '${_activeWedding.brideName} & ${_activeWedding.groomName} Wedding',
      weddingDate: _activeWedding.weddingDate,
      venueName: _activeWedding.selectedVenue?.name ?? 'Venue',
      packageName: package.name,
      totalPrice: package.price,
      status: BookingRequestStatus.pending,
    );

    _bookingRequests.insert(0, request);

    _providerNotifications.insert(
      0,
      WeddingNotificationModel(
        id: 'pn_${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Booking Request',
        message: 'New request for ${package.name} from ${_activeWedding.brideName}.',
        time: DateTime.now(),
        icon: Icons.notifications,
      ),
    );

    // Sync to Supabase Database Realtime Table
    SupabaseDatabaseService.createBookingRequest(request);

    notifyListeners();
  }

  // --- PHOTO GALLERY & GUEST MOMENTS ---
  void uploadPhotoToWedding({
    required String weddingId,
    required String albumName,
    required String imageUrl,
    required String uploaderName,
    required UserRole uploaderRole,
  }) {
    final newPhoto = WeddingGalleryPhotoModel(
      id: 'img_${DateTime.now().millisecondsSinceEpoch}',
      weddingId: weddingId,
      albumName: albumName,
      imageUrl: imageUrl,
      uploaderId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      uploaderName: uploaderName,
      uploaderRole: uploaderRole,
      uploadTime: DateTime.now(),
      visibility: PhotoVisibility.publicToGuests,
      approvalStatus: uploaderRole == UserRole.guest
          ? PhotoApprovalStatus.pendingApproval // Requires Client Approval
          : PhotoApprovalStatus.approved,
    );

    _weddingPhotos.insert(0, newPhoto);

    if (uploaderRole == UserRole.guest) {
      _clientNotifications.insert(
        0,
        WeddingNotificationModel(
          id: 'cn_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Guest Photo Pending Approval 📸',
          message: '$uploaderName shared a moment photo in $albumName.',
          time: DateTime.now(),
          icon: Icons.add_a_photo_outlined,
        ),
      );
    }

    // Sync to Supabase Database Realtime Table
    SupabaseDatabaseService.insertPhoto(newPhoto);

    notifyListeners();
  }

  void approveGuestPhoto(String photoId) {
    final idx = _weddingPhotos.indexWhere((p) => p.id == photoId);
    if (idx != -1) {
      _weddingPhotos[idx].approvalStatus = PhotoApprovalStatus.approved;

      // Sync to Supabase Database Realtime Table
      SupabaseDatabaseService.updatePhotoApproval(photoId, PhotoApprovalStatus.approved);

      notifyListeners();
    }
  }

  void rejectGuestPhoto(String photoId) {
    _weddingPhotos.removeWhere((p) => p.id == photoId);

    // Sync to Supabase Database Realtime Table
    SupabaseDatabaseService.updatePhotoApproval(photoId, PhotoApprovalStatus.rejected);

    notifyListeners();
  }

  // --- WEDDING SCHEDULE ACTIONS ---
  void addScheduleItem(WeddingScheduleItemModel item) {
    _scheduleItems.add(item);

    // Sync to Supabase Database Realtime Table
    SupabaseDatabaseService.insertScheduleItem(item);

    notifyListeners();
  }

  void deleteScheduleItem(String id) {
    _scheduleItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
