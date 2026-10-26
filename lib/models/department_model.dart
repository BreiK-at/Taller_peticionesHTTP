class DepartmentModel {
  final int id;
  final String name;
  final String description;
  final int municipalities;
  final int surface;
  final int population;
  final String phonePrefix;
  final String capitalName;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.municipalities,
    required this.surface,
    required this.population,
    required this.phonePrefix,
    required this.capitalName,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    String capital = 'No especificada';
    if (json['cityCapital'] != null && json['cityCapital'] is Map) {
      capital = json['cityCapital']['name']?.toString() ?? 'No especificada';
    }

    return DepartmentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Sin nombre',
      description: json['description']?.toString() ?? 'Sin descripcion disponible.',
      municipalities: json['municipalities'] is int
          ? json['municipalities']
          : int.tryParse(json['municipalities']?.toString() ?? '0') ?? 0,
      surface: json['surface'] is int
          ? json['surface']
          : int.tryParse(json['surface']?.toString() ?? '0') ?? 0,
      population: json['population'] is int
          ? json['population']
          : int.tryParse(json['population']?.toString() ?? '0') ?? 0,
      phonePrefix: json['phonePrefix']?.toString() ?? 'N/A',
      capitalName: capital,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'municipalities': municipalities,
      'surface': surface,
      'population': population,
      'phonePrefix': phonePrefix,
      'capitalName': capitalName,
    };
  }
}
