class PresidentModel {
  final int id;
  final String name;
  final String lastName;
  final String? image;
  final String startPeriodDate;
  final String endPeriodDate;
  final String politicalParty;
  final String description;
  final String cityName;

  PresidentModel({
    required this.id,
    required this.name,
    required this.lastName,
    this.image,
    required this.startPeriodDate,
    required this.endPeriodDate,
    required this.politicalParty,
    required this.description,
    required this.cityName,
  });

  String get fullName => '$name $lastName'.trim();

  String get periodFormatted {
    final start = startPeriodDate.isNotEmpty ? startPeriodDate : 'Desconocido';
    final end = endPeriodDate.isNotEmpty ? endPeriodDate : 'Actualidad';
    return '$start a $end';
  }

  factory PresidentModel.fromJson(Map<String, dynamic> json) {
    String city = 'No especificada';
    if (json['city'] != null && json['city'] is Map) {
      city = json['city']['name']?.toString() ?? 'No especificada';
    }

    return PresidentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      image: json['image']?.toString(),
      startPeriodDate: json['startPeriodDate']?.toString() ?? '',
      endPeriodDate: json['endPeriodDate']?.toString() ?? '',
      politicalParty: json['politicalParty']?.toString() ?? 'Independiente',
      description: json['description']?.toString() ?? 'Sin biografia disponible.',
      cityName: city,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'image': image,
      'startPeriodDate': startPeriodDate,
      'endPeriodDate': endPeriodDate,
      'politicalParty': politicalParty,
      'description': description,
      'cityName': cityName,
    };
  }
}
