class ConferenceProvider {
  const ConferenceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    required this.address,
    required this.description,
    required this.imageUrl,
    required this.startingPrice,
    required this.details,
    required this.isDemo,
    this.rating,
  });

  final String id;
  final String name;
  final String category;
  final String city;
  final String address;
  final String description;
  final String imageUrl;
  final num startingPrice;
  final Map<String, dynamic> details;
  final bool isDemo;
  final double? rating;

  factory ConferenceProvider.fromMap(Map<String, dynamic> map) {
    final details = map['details'];
    final rating = map['rating'];
    return ConferenceProvider(
      id: map['id'] as String,
      name: (map['name'] ?? 'Provider') as String,
      category: map['category'] as String,
      city: (map['city'] ?? '') as String,
      address: (map['address'] ?? map['location'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      imageUrl: (map['image_url'] ?? '') as String,
      startingPrice: map['starting_price'] as num? ?? 0,
      details: details is Map
          ? Map<String, dynamic>.from(details)
          : <String, dynamic>{},
      isDemo: map['is_demo'] as bool? ?? false,
      rating: rating is num ? rating.toDouble() : null,
    );
  }
}
