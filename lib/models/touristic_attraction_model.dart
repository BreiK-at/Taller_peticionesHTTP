class TouristicAttractionModel {
  final int id;
  final String name;
  final String description;
  final List<String> images;
  final String? latitude;
  final String? longitude;
  final String cityName;

  TouristicAttractionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    this.latitude,
    this.longitude,
    required this.cityName,
  });

  String? get primaryImage => images.isNotEmpty ? images.first : null;

  factory TouristicAttractionModel.fromJson(Map<String, dynamic> json) {
    String city = 'No especificada';
    if (json['city'] != null && json['city'] is Map) {
      city = json['city']['name']?.toString() ?? 'No especificada';
    }

    final rawImages = json['images'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages
          .where((img) => img != null && img.toString().trim().isNotEmpty)
          .map((img) => img.toString())
          .toList();
    }

    return TouristicAttractionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Sin nombre',
      description: json['description']?.toString() ?? 'Sin descripcion turistica disponible.',
      images: parsedImages,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      cityName: city,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
    };
  }
}
