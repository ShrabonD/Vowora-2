import 'package:flutter/foundation.dart';
import '../../models/wedding_booking_model.dart';
import '../../models/wedding_ecosystem_models.dart';
import 'supabase_service.dart';

class SupabaseDatabaseService {
  // Check if Supabase client is initialized and ready
  static bool get isReady => SupabaseService.isInitialized;

  // ===== 1. REALTIME WEDDING STREAM =====
  static Stream<List<Map<String, dynamic>>>? streamWedding(String weddingId) {
    if (!isReady) return null;
    try {
      return SupabaseService.client
          .from('wedding_profiles')
          .stream(primaryKey: ['id'])
          .eq('id', weddingId);
    } catch (e) {
      if (kDebugMode) print('❌ Error streaming wedding: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchWeddingById(String weddingId) async {
    if (!isReady) return null;
    try {
      final response = await SupabaseService.client
          .from('wedding_profiles')
          .select()
          .ilike('id', weddingId.trim())
          .maybeSingle();
      return response;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error fetching wedding by code: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserWedding(String userId) async {
    if (!isReady || userId.isEmpty) return null;
    try {
      final response = await SupabaseService.client
          .from('wedding_profiles')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error fetching user wedding: $e');
      return null;
    }
  }

  static Future<void> upsertWedding(WeddingBookingModel booking, {String? userId}) async {
    if (!isReady) return;
    try {
      final effectiveUserId = userId ?? SupabaseService.currentUser?.id ?? 'active_user';
      await SupabaseService.client.from('wedding_profiles').upsert({
        'id': booking.weddingId,
        'user_id': effectiveUserId,
        'bride_name': booking.brideName,
        'groom_name': booking.groomName,
        'bride_phone': booking.bridePhone,
        'groom_phone': booking.groomPhone,
        'wedding_date': booking.weddingDate.toIso8601String(),
        'wedding_time': booking.weddingTime,
        'wedding_type': booking.weddingType.name,
        'expected_guest_count': booking.expectedGuestCount,
        'description': booking.description,
        'bride_photo_url': booking.bridePhotoUrl,
        'groom_photo_url': booking.groomPhotoUrl,
        'cover_photo_url': booking.coverPhotoUrl,
        'venue_name': booking.selectedVenue?.name,
        'venue_location': booking.selectedVenue?.location,
        'total_planned_budget': booking.totalPlannedBudget,
        'is_confirmed': booking.isConfirmed,
      });
      if (kDebugMode) debugPrint('✅ Wedding upserted to Supabase with user_id: $effectiveUserId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error upserting wedding: $e');
    }
  }

  static Future<void> deleteWedding(String weddingId) async {
    if (!isReady) return;
    try {
      await SupabaseService.client
          .from('wedding_profiles')
          .delete()
          .eq('id', weddingId);
    } catch (e) {
      if (kDebugMode) print('❌ Error deleting wedding: $e');
    }
  }

  // ===== 2. REALTIME GUESTS STREAM & RSVP =====
  static Stream<List<Map<String, dynamic>>>? streamGuests(String weddingId) {
    if (!isReady || weddingId.trim().isEmpty) return null;
    try {
      return SupabaseService.client
          .from('guests')
          .stream(primaryKey: ['id'])
          .eq('wedding_id', weddingId.trim());
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error streaming guests for wedding $weddingId: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchGuestsByWeddingId(String weddingId) async {
    if (!isReady || weddingId.trim().isEmpty) return [];
    try {
      final response = await SupabaseService.client
          .from('guests')
          .select()
          .eq('wedding_id', weddingId.trim())
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error fetching guests for wedding $weddingId: $e');
      return [];
    }
  }

  static Future<void> submitGuestRSVP({
    required String weddingId,
    required String name,
    required String phone,
    required RSVPStatus status,
    required int attendeesCount,
    required String mealPref,
    required String specialRequest,
  }) async {
    if (!isReady) return;
    try {
      // 1. Verify parent wedding_profiles record exists to prevent FK 23503 constraint error!
      final checkWedding = await fetchWeddingById(weddingId);
      if (checkWedding == null) {
        await SupabaseService.client.from('wedding_profiles').upsert({
          'id': weddingId,
          'bride_name': 'Ariesha Rahman',
          'groom_name': 'Tariq Hassan',
          'wedding_date': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
          'wedding_time': '06:00 PM',
          'wedding_type': 'royal',
          'expected_guest_count': 300,
          'total_planned_budget': 400000.0,
          'is_confirmed': true,
        });
      }

      // 2. Insert Guest RSVP
      final guestId = 'g_${DateTime.now().millisecondsSinceEpoch}';
      await SupabaseService.client.from('guests').upsert({
        'id': guestId,
        'wedding_id': weddingId,
        'name': name,
        'phone': phone,
        'rsvp_status': status.name,
        'number_of_guests': attendeesCount,
        'meal_preference': mealPref,
        'special_request': specialRequest,
      });
      if (kDebugMode) debugPrint('✅ Guest RSVP saved to Supabase successfully for wedding: $weddingId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error submitting RSVP: $e');
    }
  }

  static Future<void> updateGuestRSVPStatus(String guestId, RSVPStatus status) async {
    if (!isReady) return;
    try {
      await SupabaseService.client
          .from('guests')
          .update({'rsvp_status': status.name})
          .eq('id', guestId);
      if (kDebugMode) debugPrint('✅ Guest RSVP status updated in Supabase: $guestId -> ${status.name}');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error updating guest RSVP: $e');
    }
  }

  static Future<void> deleteGuest(String guestId) async {
    if (!isReady) return;
    try {
      await SupabaseService.client
          .from('guests')
          .delete()
          .eq('id', guestId);
      if (kDebugMode) debugPrint('✅ Guest deleted from Supabase: $guestId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error deleting guest: $e');
    }
  }

  // ===== SERVICE PROVIDERS MARKETPLACE DIRECTORY =====
  static Stream<List<Map<String, dynamic>>>? streamServiceProviders() {
    if (!isReady) return null;
    try {
      return SupabaseService.client
          .from('service_providers')
          .stream(primaryKey: ['id']);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error streaming service providers: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchServiceProviders() async {
    if (!isReady) return [];
    try {
      final response = await SupabaseService.client
          .from('service_providers')
          .select()
          .order('starting_price', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error fetching providers: $e');
      return [];
    }
  }

  // ===== 3. REALTIME SERVICE BOOKINGS STREAM =====
  static Stream<List<Map<String, dynamic>>>? streamBookings(String weddingId) {
    if (!isReady) return null;
    try {
      return SupabaseService.client
          .from('service_bookings')
          .stream(primaryKey: ['id'])
          .eq('wedding_id', weddingId);
    } catch (e) {
      if (kDebugMode) print('❌ Error streaming bookings: $e');
      return null;
    }
  }

  static Future<void> createBookingRequest(ServiceBookingRequestModel request) async {
    if (!isReady) return;
    try {
      await SupabaseService.client.from('service_bookings').insert({
        'id': request.id,
        'provider_id': request.providerId,
        'provider_name': request.providerName,
        'provider_type': request.providerType.name,
        'client_id': request.clientId,
        'client_name': request.clientName,
        'wedding_id': request.weddingId,
        'wedding_name': request.weddingName,
        'wedding_date': request.weddingDate.toIso8601String(),
        'venue_name': request.venueName,
        'package_name': request.packageName,
        'total_price': request.totalPrice,
        'status': request.status.name,
        'payment_status': request.paymentStatus,
      });
    } catch (e) {
      if (kDebugMode) print('❌ Error creating booking: $e');
    }
  }

  static Future<void> updateBookingStatus(String bookingId, BookingRequestStatus status) async {
    if (!isReady) return;
    try {
      await SupabaseService.client
          .from('service_bookings')
          .update({'status': status.name, 'payment_status': status == BookingRequestStatus.accepted ? 'Partially Paid' : 'Pending'})
          .eq('id', bookingId);
    } catch (e) {
      if (kDebugMode) print('❌ Error updating booking status: $e');
    }
  }

  // ===== 4. REALTIME PHOTO GALLERY STREAM =====
  static Stream<List<Map<String, dynamic>>>? streamPhotos(String weddingId) {
    if (!isReady) return null;
    try {
      return SupabaseService.client
          .from('wedding_photos')
          .stream(primaryKey: ['id'])
          .eq('wedding_id', weddingId);
    } catch (e) {
      if (kDebugMode) print('❌ Error streaming photos: $e');
      return null;
    }
  }

  static Future<void> insertPhoto(WeddingGalleryPhotoModel photo) async {
    if (!isReady) return;
    try {
      await SupabaseService.client.from('wedding_photos').insert({
        'id': photo.id,
        'wedding_id': photo.weddingId,
        'album_name': photo.albumName,
        'image_url': photo.imageUrl,
        'uploader_id': photo.uploaderId,
        'uploader_name': photo.uploaderName,
        'uploader_role': photo.uploaderRole.name,
        'visibility': photo.visibility.name,
        'approval_status': photo.approvalStatus.name,
      });
    } catch (e) {
      if (kDebugMode) print('❌ Error inserting photo: $e');
    }
  }

  static Future<void> updatePhotoApproval(String photoId, PhotoApprovalStatus status) async {
    if (!isReady) return;
    try {
      await SupabaseService.client
          .from('wedding_photos')
          .update({'approval_status': status.name})
          .eq('id', photoId);
    } catch (e) {
      if (kDebugMode) print('❌ Error updating photo approval: $e');
    }
  }

  // ===== 5. REALTIME SCHEDULE STREAM =====
  static Stream<List<Map<String, dynamic>>>? streamSchedule(String weddingId) {
    if (!isReady) return null;
    try {
      return SupabaseService.client
          .from('wedding_schedule')
          .stream(primaryKey: ['id'])
          .eq('wedding_id', weddingId);
    } catch (e) {
      if (kDebugMode) print('❌ Error streaming schedule: $e');
      return null;
    }
  }

  static Future<void> insertScheduleItem(WeddingScheduleItemModel item) async {
    if (!isReady) return;
    try {
      await SupabaseService.client.from('wedding_schedule').insert({
        'id': item.id,
        'wedding_id': item.weddingId,
        'time_string': item.timeString,
        'title': item.title,
        'description': item.description,
        'location': item.location,
      });
    } catch (e) {
      if (kDebugMode) print('❌ Error inserting schedule: $e');
    }
  }

  // ===== 6. REALTIME PAYMENTS & INVOICES STREAM =====
  static Stream<List<Map<String, dynamic>>>? streamPayments(String weddingId) {
    if (!isReady || weddingId.trim().isEmpty) return null;
    try {
      return SupabaseService.client
          .from('payment_records')
          .stream(primaryKey: ['id'])
          .eq('wedding_id', weddingId.trim());
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error streaming payments: $e');
      return null;
    }
  }

  static Future<void> insertPaymentRecord(PaymentRecordModel payment) async {
    if (!isReady) return;
    try {
      final checkWedding = await fetchWeddingById(payment.weddingId);
      if (checkWedding == null) {
        await SupabaseService.client.from('wedding_profiles').upsert({
          'id': payment.weddingId,
          'bride_name': 'Ariesha Rahman',
          'groom_name': 'Tariq Hassan',
          'wedding_date': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
          'wedding_time': '06:00 PM',
          'wedding_type': 'royal',
          'expected_guest_count': 300,
          'total_planned_budget': 400000.0,
          'is_confirmed': true,
        });
      }

      await SupabaseService.client.from('payment_records').insert({
        'id': payment.id,
        'wedding_id': payment.weddingId,
        'service_name': payment.serviceName,
        'amount': payment.amount,
        'payment_method': payment.paymentMethod,
        'transaction_id': payment.transactionId,
        'sender_phone': payment.senderPhone,
        'payment_type': payment.paymentType,
        'invoice_no': payment.invoiceNo,
        'status': payment.status,
      });
      if (kDebugMode) debugPrint('✅ Payment record & TrxID saved to Supabase: ${payment.invoiceNo}');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error inserting payment record: $e');
    }
  }

  static Future<void> updatePaymentStatus(String paymentId, String status) async {
    if (!isReady) return;
    try {
      await SupabaseService.client
          .from('payment_records')
          .update({'status': status})
          .eq('id', paymentId);
      if (kDebugMode) debugPrint('✅ Payment status updated in Supabase: $paymentId -> $status');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error updating payment status: $e');
    }
  }
}
