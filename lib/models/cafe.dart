class Cafe {
  const Cafe({
    required this.id,
    required this.name,
    this.category = '',
    this.area = '',
    this.address = '',
    this.priceRange = '',
    this.description = '',
    this.openingHours = '',
    this.facilities = const [],
    this.needsTags = const [],
    this.rating,
    this.reviewCount = 0,
    this.verified = false,
    this.status = '',
    this.mapsUrl = '',
    this.latitude,
    this.longitude,
    this.lastVerifiedAt,
  });

  final int id;
  final String name,
      category,
      area,
      address,
      priceRange,
      description,
      openingHours;
  final List<String> facilities, needsTags;
  final double? rating, latitude, longitude;
  final int reviewCount;
  final bool verified;
  final String status, mapsUrl;
  final DateTime? lastVerifiedAt;

  factory Cafe.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}');
    final name = _text(json['name']).replaceAll(RegExp(r'^[\s\uFE0F]+'), '');
    if (id == null || name.isEmpty) {
      throw const FormatException('ID atau nama kafe tidak valid.');
    }
    final rating = _number(json['gmaps_rating']);
    return Cafe(
      id: id,
      name: name,
      category: _text(json['category']),
      area: _text(json['area']),
      address: _text(json['address']),
      priceRange: _text(json['price_range']),
      description: _text(json['description']),
      openingHours: _text(json['opening_hours']),
      facilities: _strings(json['facilities']),
      needsTags: _strings(json['needs_tags']),
      rating: rating != null && rating > 0 && rating <= 5 ? rating : null,
      reviewCount: int.tryParse('${json['gmaps_review_count']}') ?? 0,
      verified: json['verified'] == true,
      status: _text(json['gmaps_status']),
      mapsUrl: _text(json['gmaps_url']),
      latitude: _number(json['latitude']),
      longitude: _number(json['longitude']),
      lastVerifiedAt: DateTime.tryParse(_text(json['last_verified_at'])),
    );
  }

  bool get is24Hours =>
      RegExp(r'24\s*jam', caseSensitive: false).hasMatch(openingHours);
  bool get isTemporarilyClosed => status.toLowerCase() == 'temporarily closed';
  String get ratingLabel => rating?.toStringAsFixed(1) ?? 'Belum dinilai';
  String get areaLabel => area.isEmpty ? 'Wilayah belum tersedia' : area;
  String get priceLabel =>
      priceRange.isEmpty ? 'Harga belum tersedia' : priceRange;

  Uri? get mapsUri {
    final uri = Uri.tryParse(mapsUrl);
    if (uri != null &&
        uri.scheme == 'https' &&
        (uri.host == 'www.google.com' ||
            uri.host == 'maps.google.com' ||
            uri.host == 'maps.app.goo.gl')) {
      return uri;
    }
    if (latitude != null && longitude != null) {
      return Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '$latitude,$longitude',
      });
    }
    return null;
  }

  static String _text(dynamic value) => value is String ? value.trim() : '';
  static double? _number(dynamic value) {
    final number = double.tryParse('$value');
    return number != null && number.isFinite ? number : null;
  }

  static List<String> _strings(dynamic value) => value is List
      ? value
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false)
      : const [];
}
