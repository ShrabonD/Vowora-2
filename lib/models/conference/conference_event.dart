class ConferenceServiceCategory {
  const ConferenceServiceCategory(this.key, this.label);

  final String key;
  final String label;

  static const List<ConferenceServiceCategory> steps = [
    ConferenceServiceCategory('hall', 'Halls'),
    ConferenceServiceCategory('food', 'Restaurant & Food'),
    ConferenceServiceCategory('sound', 'Sound & Screens'),
    ConferenceServiceCategory('decoration', 'Decorations'),
    ConferenceServiceCategory('photography', 'Photography'),
    ConferenceServiceCategory('transportation', 'Transportation'),
  ];
}

class ConferenceEvent {
  const ConferenceEvent({
    required this.id,
    required this.code,
    required this.title,
    required this.slogan,
    required this.eventDate,
    required this.organizerName,
    required this.organizerEmail,
    required this.location,
    required this.isLocalOnly,
    this.userId,
  });

  final String id;
  final String code;
  final String title;
  final String slogan;
  final DateTime eventDate;
  final String organizerName;
  final String organizerEmail;
  final String location;
  final String? userId;
  final bool isLocalOnly;

  ConferenceEvent copyWith({DateTime? eventDate}) => ConferenceEvent(
    id: id,
    code: code,
    title: title,
    slogan: slogan,
    eventDate: eventDate ?? this.eventDate,
    organizerName: organizerName,
    organizerEmail: organizerEmail,
    location: location,
    userId: userId,
    isLocalOnly: isLocalOnly,
  );

  factory ConferenceEvent.fromMap(Map<String, dynamic> map) {
    return ConferenceEvent(
      id: map['id'] as String,
      code: (map['conference_code'] ?? map['code']) as String,
      title: (map['title'] ?? '') as String,
      slogan: (map['slogan'] ?? '') as String,
      eventDate: DateTime.parse(map['event_date'] as String),
      organizerName: (map['organizer_name'] ?? '') as String,
      organizerEmail: (map['organizer_email'] ?? '') as String,
      location: (map['location'] ?? 'Dhaka') as String,
      userId: map['user_id'] as String?,
      isLocalOnly: map['is_local_only'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toLocalMap() => {
    'id': id,
    'conference_code': code,
    'title': title,
    'slogan': slogan,
    'event_date': _dateOnly(eventDate),
    'organizer_name': organizerName,
    'organizer_email': organizerEmail,
    'location': location,
    'user_id': userId,
    'is_local_only': isLocalOnly,
  };

  static String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
