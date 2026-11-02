class ConferenceServiceBooking {
  const ConferenceServiceBooking({
    this.id,
    required this.conferenceId,
    required this.category,
    required this.providerId,
    required this.providerName,
    required this.packageName,
    required this.bookingDate,
    required this.totalPrice,
    required this.selectionDetails,
    required this.status,
    required this.isLocalOnly,
  });

  final String? id;
  final String conferenceId;
  final String category;
  final String providerId;
  final String providerName;
  final String packageName;
  final DateTime bookingDate;
  final num totalPrice;
  final Map<String, dynamic> selectionDetails;
  final String status;
  final bool isLocalOnly;

  factory ConferenceServiceBooking.fromMap(Map<String, dynamic> map) {
    final details = map['selection_details'];
    return ConferenceServiceBooking(
      id: map['id'] as String?,
      conferenceId: map['conference_id'] as String,
      category: map['category'] as String,
      providerId: map['provider_id'] as String,
      providerName: map['provider_name'] as String,
      packageName: (map['package_name'] ?? '') as String,
      bookingDate: DateTime.parse(map['booking_date'] as String),
      totalPrice: map['total_price'] as num? ?? 0,
      selectionDetails: details is Map
          ? Map<String, dynamic>.from(details)
          : <String, dynamic>{},
      status: (map['status'] ?? 'confirmed') as String,
      isLocalOnly: map['is_local_only'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toLocalMap() => {
    'id': id,
    'conference_id': conferenceId,
    'category': category,
    'provider_id': providerId,
    'provider_name': providerName,
    'package_name': packageName,
    'booking_date': _dateOnly(bookingDate),
    'total_price': totalPrice,
    'selection_details': selectionDetails,
    'status': status,
    'is_local_only': isLocalOnly,
  };

  static String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
