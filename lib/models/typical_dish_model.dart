class TypicalDishModel {
  final int id;
  final String name;
  final String description;
  final String ingredients;
  final String? imageUrl;
  final String departmentName;

  TypicalDishModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    this.imageUrl,
    required this.departmentName,
  });

  List<String> get ingredientList {
    if (ingredients.trim().isEmpty) return [];
    return ingredients
        .split(RegExp(r'[,;]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  factory TypicalDishModel.fromJson(Map<String, dynamic> json) {
    String dept = 'Colombia (General)';
    if (json['department'] != null && json['department'] is Map) {
      dept = json['department']['name']?.toString() ?? 'Colombia';
    }

    return TypicalDishModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Sin nombre',
      description: json['description']?.toString() ?? 'Sin descripcion disponible.',
      ingredients: json['ingredients']?.toString() ?? 'No especificados.',
      imageUrl: json['imageUrl']?.toString(),
      departmentName: dept,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'departmentName': departmentName,
    };
  }
}
