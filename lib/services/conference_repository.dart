import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../data/conference/conference_seed_data.dart';
import '../models/conference/conference_event.dart';
import '../models/conference/conference_provider.dart';
import '../models/conference/conference_service_booking.dart';

class ConferenceRepository {
  static const _eventsKey = 'vowora_conference_events_v1';
  static const _bookingsKey = 'vowora_conference_bookings_v1';
  static const _invitationsKey = 'vowora_conference_invitations_v1';
  static final Random _random = Random.secure();

  static String generateConferenceCode() =>
      (10000 + _random.nextInt(90000)).toString();

  static Future<ConferenceEvent> createConference({
    required String title,
    required String slogan,
    required DateTime eventDate,
    required String organizerName,
    required String organizerEmail,
    required String location,
  }) async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      for (var attempt = 0; attempt < 10; attempt++) {
        final code = generateConferenceCode();
        try {
          final response = await SupabaseService.client
              .from('conference_events')
              .insert({
                'conference_code': code,
                'title': title.trim(),
                'slogan': slogan.trim(),
                'event_date': _dateOnly(eventDate),
                'organizer_name': organizerName.trim(),
                'organizer_email': organizerEmail.trim(),
                'location': location.trim(),
                'user_id': user.id,
              })
              .select()
              .single();
          return ConferenceEvent.fromMap(Map<String, dynamic>.from(response));
        } on PostgrestException catch (error) {
          if (error.code == '23505' && attempt < 9) continue;
          rethrow;
        }
      }
      throw StateError('Could not generate an available conference code.');
    }

    final prefs = await SharedPreferences.getInstance();
    final events = _readEvents(prefs.getString(_eventsKey));
    String code;
    do {
      code = generateConferenceCode();
    } while (events.any((event) => event.code == code));

    final event = ConferenceEvent(
      id: 'guest_$code',
      code: code,
      title: title.trim(),
      slogan: slogan.trim(),
      eventDate: eventDate,
      organizerName: organizerName.trim(),
      organizerEmail: organizerEmail.trim(),
      location: location.trim(),
      userId: null,
      isLocalOnly: true,
    );
    events.insert(0, event);
    await prefs.setString(
      _eventsKey,
      jsonEncode(events.map((item) => item.toLocalMap()).toList()),
    );
    return event;
  }

  static Future<List<ConferenceEvent>> getConferences() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      final response = await SupabaseService.client
          .from('conference_events')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return (response as List)
          .map(
            (item) =>
                ConferenceEvent.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }

    final prefs = await SharedPreferences.getInstance();
    return _readEvents(prefs.getString(_eventsKey));
  }

  static Future<ConferenceEvent> updateConferenceDate(
    ConferenceEvent event,
    DateTime eventDate,
  ) async {
    final normalizedDate = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
    );
    if (event.isLocalOnly) {
      final prefs = await SharedPreferences.getInstance();
      final events = _readEvents(prefs.getString(_eventsKey));
      final bookings = _readBookings(prefs.getString(_bookingsKey));
      final currentHallBookings = bookings
          .where(
            (booking) =>
                booking.conferenceId == event.id &&
                booking.category == 'hall' &&
                booking.status != 'cancelled',
          )
          .toList();
      if (currentHallBookings.isNotEmpty &&
          bookings.any(
            (booking) =>
                booking.conferenceId != event.id &&
                booking.category == 'hall' &&
                booking.providerId == currentHallBookings.first.providerId &&
                _sameDate(booking.bookingDate, normalizedDate) &&
                booking.status != 'cancelled',
          )) {
        throw const ConferenceBookingUnavailableException();
      }

      final updatedEvent = event.copyWith(eventDate: normalizedDate);
      final eventIndex = events.indexWhere((item) => item.id == event.id);
      if (eventIndex >= 0) events[eventIndex] = updatedEvent;
      for (var index = 0; index < bookings.length; index++) {
        final booking = bookings[index];
        if (booking.conferenceId == event.id && booking.status != 'cancelled') {
          bookings[index] = ConferenceServiceBooking(
            id: booking.id,
            conferenceId: booking.conferenceId,
            category: booking.category,
            providerId: booking.providerId,
            providerName: booking.providerName,
            packageName: booking.packageName,
            bookingDate: normalizedDate,
            totalPrice: booking.totalPrice,
            selectionDetails: booking.selectionDetails,
            status: booking.status,
            isLocalOnly: true,
          );
        }
      }
      await prefs.setString(
        _eventsKey,
        jsonEncode(events.map((item) => item.toLocalMap()).toList()),
      );
      await prefs.setString(
        _bookingsKey,
        jsonEncode(bookings.map((item) => item.toLocalMap()).toList()),
      );
      return updatedEvent;
    }

    try {
      final response = await SupabaseService.client.rpc(
        'update_conference_event_date',
        params: {
          'p_conference_id': event.id,
          'p_event_date': _dateOnly(normalizedDate),
        },
      );
      return ConferenceEvent.fromMap(
        Map<String, dynamic>.from(response as Map),
      );
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const ConferenceBookingUnavailableException();
      }
      rethrow;
    }
  }

  static Future<List<ConferenceProvider>> getProviders({
    required String category,
    required String city,
  }) async {
    final seedRecords = switch (category) {
      'hall' => ConferenceSeedData.halls,
      'food' => ConferenceSeedData.foods,
      'sound' => ConferenceSeedData.sounds,
      'decoration' => ConferenceSeedData.decorations,
      'photography' => ConferenceSeedData.photography,
      'transportation' => ConferenceSeedData.transport,
      _ => const <Map<String, dynamic>>[],
    };
    final requestedCity = city.trim().toLowerCase();
    return seedRecords
        .map((raw) => _demoProvider(Map<String, dynamic>.from(raw), category))
        .where(
          (provider) =>
              requestedCity.isEmpty ||
              provider.city.toLowerCase() == requestedCity,
        )
        .toList();
  }

  static Future<List<ConferenceServiceBooking>> getBookings(
    ConferenceEvent event,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final localBookings = _readBookings(prefs.getString(_bookingsKey))
        .where((booking) => booking.conferenceId == event.id)
        .where((booking) => booking.status != 'cancelled')
        .toList();
    if (event.isLocalOnly) return localBookings;

    try {
      final response = await SupabaseService.client
          .from('conference_provider_bookings')
          .select()
          .eq('conference_id', event.id)
          .neq('status', 'cancelled')
          .order('created_at');
      final remoteBookings = (response as List)
          .map(
            (item) => ConferenceServiceBooking.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      final bookingsByCategory = {
        for (final booking in remoteBookings) booking.category: booking,
        for (final booking in localBookings) booking.category: booking,
      };
      return bookingsByCategory.values.toList();
    } on PostgrestException catch (error) {
      if (_isMissingConferenceBookingsTable(error)) return localBookings;
      rethrow;
    }
  }

  static Future<ConferenceServiceBooking> saveBooking({
    required ConferenceEvent event,
    required ConferenceProvider provider,
    required String packageName,
    required num totalPrice,
    required Map<String, dynamic> selectionDetails,
  }) async {
    final bookingDate = DateTime(
      event.eventDate.year,
      event.eventDate.month,
      event.eventDate.day,
    );
    if (event.isLocalOnly || provider.isDemo) {
      final prefs = await SharedPreferences.getInstance();
      final bookings = _readBookings(prefs.getString(_bookingsKey));
      final current = bookings.where(
        (booking) =>
            booking.conferenceId == event.id &&
            booking.category == provider.category &&
            booking.status != 'cancelled',
      );
      final currentId = current.isEmpty ? null : current.first.id;

      final booking = ConferenceServiceBooking(
        id: currentId ?? 'local_${DateTime.now().microsecondsSinceEpoch}',
        conferenceId: event.id,
        category: provider.category,
        providerId: provider.id,
        providerName: provider.name,
        packageName: packageName,
        bookingDate: bookingDate,
        totalPrice: totalPrice,
        selectionDetails: selectionDetails,
        status: 'draft',
        isLocalOnly: true,
      );
      bookings.removeWhere(
        (item) =>
            item.conferenceId == event.id && item.category == provider.category,
      );
      bookings.add(booking);
      await prefs.setString(
        _bookingsKey,
        jsonEncode(bookings.map((item) => item.toLocalMap()).toList()),
      );
      return booking;
    }

    try {
      final response = await SupabaseService.client.rpc(
        'save_conference_service_booking',
        params: {
          'p_conference_id': event.id,
          'p_provider_id': provider.id,
          'p_category': provider.category,
          'p_provider_name': provider.name,
          'p_package_name': packageName,
          'p_booking_date': _dateOnly(bookingDate),
          'p_total_price': totalPrice,
          'p_selection_details': selectionDetails,
        },
      );
      final result = response is List ? response.single : response;
      return ConferenceServiceBooking.fromMap(
        Map<String, dynamic>.from(result as Map),
      );
    } on PostgrestException catch (error) {
      if (provider.category == 'hall' && error.code == '23505') {
        throw const ConferenceBookingUnavailableException();
      }
      rethrow;
    }
  }

  static Future<void> cancelBooking(
    ConferenceEvent event,
    ConferenceServiceBooking booking,
  ) async {
    if (event.isLocalOnly || booking.isLocalOnly) {
      final prefs = await SharedPreferences.getInstance();
      final bookings = _readBookings(prefs.getString(_bookingsKey));
      final index = bookings.indexWhere((item) => item.id == booking.id);
      if (index >= 0) {
        final current = bookings[index];
        bookings[index] = ConferenceServiceBooking(
          id: current.id,
          conferenceId: current.conferenceId,
          category: current.category,
          providerId: current.providerId,
          providerName: current.providerName,
          packageName: current.packageName,
          bookingDate: current.bookingDate,
          totalPrice: current.totalPrice,
          selectionDetails: current.selectionDetails,
          status: 'cancelled',
          isLocalOnly: true,
        );
        await prefs.setString(
          _bookingsKey,
          jsonEncode(bookings.map((item) => item.toLocalMap()).toList()),
        );
      }
      return;
    }

    await SupabaseService.client
        .from('conference_provider_bookings')
        .update({'status': 'cancelled'})
        .eq('id', booking.id!)
        .eq('conference_id', event.id);
  }

  static Future<void> saveInvitation({
    required ConferenceEvent event,
    required String startTime,
    required String endTime,
    required String schedule,
    required List<String> guestNumbers,
  }) async {
    final invitation = {
      'conference_id': event.id,
      'conference_title': event.title,
      'event_date': _dateOnly(event.eventDate),
      'location': event.location,
      'start_time': startTime,
      'end_time': endTime,
      'schedule': schedule,
      'guest_numbers': guestNumbers,
      'sending_status': 'draft',
    };
    if (event.isLocalOnly) {
      final prefs = await SharedPreferences.getInstance();
      final saved = _readJsonList(prefs.getString(_invitationsKey));
      saved.add(invitation);
      await prefs.setString(_invitationsKey, jsonEncode(saved));
      return;
    }
    await SupabaseService.client
        .from('conference_invitations')
        .insert(invitation);
  }

  static ConferenceProvider _demoProvider(
    Map<String, dynamic> record,
    String category,
  ) {
    final packages = record['packages'] ?? record['packs'];
    num startingPrice =
        (record['starting_price'] ?? record['price'] ?? 0) as num;
    if (startingPrice == 0 && packages is List && packages.isNotEmpty) {
      final first = packages.first;
      if (first is Map && first['price'] is num) {
        startingPrice = first['price'] as num;
      }
    }
    const images = {
      'hall':
          'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=1200&q=80',
      'food':
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=1200&q=80',
      'sound':
          'https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=1200&q=80',
      'decoration':
          'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&w=1200&q=80',
      'photography':
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
      'transportation':
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1200&q=80',
    };
    final city = (record['city'] ?? record['location'] ?? 'Dhaka') as String;
    return ConferenceProvider(
      id: record['id'] as String,
      name: (record['name'] ?? 'Demo provider') as String,
      category: category,
      city: city,
      address: (record['address'] ?? city) as String,
      description:
          (record['description'] ??
                  'Demo listing. Provider details and contact information are not verified.')
              as String,
      imageUrl:
          (record['image_url'] ?? record['image'] ?? images[category]!)
              as String,
      startingPrice: startingPrice,
      details: record,
      isDemo: true,
    );
  }

  static List<ConferenceEvent> _readEvents(String? raw) =>
      _readJsonList(raw).map(ConferenceEvent.fromMap).toList();

  static List<ConferenceServiceBooking> _readBookings(String? raw) =>
      _readJsonList(raw).map(ConferenceServiceBooking.fromMap).toList();

  static List<Map<String, dynamic>> _readJsonList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Saved conference data is not a list.');
    }
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static bool _sameDate(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;

  static bool _isMissingConferenceBookingsTable(PostgrestException error) =>
      (error.code == '42P01' || error.code == 'PGRST205') &&
      error.message.contains('conference_provider_bookings');

  static String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class ConferenceBookingUnavailableException implements Exception {
  const ConferenceBookingUnavailableException();

  @override
  String toString() =>
      'Sorry! Another program is already booked on this date. Please choose another date.';
}

class ConferenceOrderMath {
  static num foodTotal(Iterable<Map<String, dynamic>> items) =>
      items.fold<num>(0, (total, item) {
        final price = item['unit_price'] as num;
        final quantity = item['quantity'] as int;
        return total + price * quantity;
      });

  static num transportTotal(Iterable<Map<String, dynamic>> vehicles) =>
      vehicles.fold<num>(0, (total, vehicle) {
        final pricePerDay = vehicle['price_per_day'] as num;
        final quantity = vehicle['quantity'] as int;
        final days = vehicle['days'] as int;
        return total + pricePerDay * quantity * days;
      });
}
