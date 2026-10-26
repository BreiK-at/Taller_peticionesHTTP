import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/department_model.dart';
import '../models/president_model.dart';
import '../models/touristic_attraction_model.dart';
import '../models/typical_dish_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Uri _buildUri(String path) {
    final base = AppConfig.apiBaseUrl;
    return Uri.parse('$base$path');
  }

  Future<dynamic> _get(String path) async {
    final uri = _buildUri(path);
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
      ).timeout(AppConfig.timeoutDuration);

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return decoded;
      } else if (response.statusCode == 404) {
        throw ApiException('El recurso solicitado no fue encontrado.', 404);
      } else if (response.statusCode >= 500) {
        throw ApiException(
          'El servidor de API Colombia presento una falla temporal (Error ${response.statusCode}).',
          response.statusCode,
        );
      } else {
        throw ApiException(
          'Respuesta inesperada del servidor (Codigo ${response.statusCode}).',
          response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException(
        'No se pudo establecer conexion con el servidor. Verifique su conexion a internet.',
      );
    } on TimeoutException {
      throw NetworkException(
        'El tiempo de espera para obtener respuesta del servidor ha expirado.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException('Error de comunicacion de red: ${e.message}');
    } on FormatException {
      throw ApiException('Error al procesar el formato de respuesta JSON del servidor.');
    }
  }

  // 1. Departamentos
  Future<List<DepartmentModel>> getDepartments() async {
    final data = await _get(AppConfig.endpointDepartment);
    if (data is List) {
      return data
          .map((item) => DepartmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<DepartmentModel> getDepartmentById(int id) async {
    final data = await _get('${AppConfig.endpointDepartment}/$id');
    if (data is Map<String, dynamic>) {
      return DepartmentModel.fromJson(data);
    }
    throw ApiException('Estructura de departamento invalida.');
  }

  // 2. Presidentes
  Future<List<PresidentModel>> getPresidents() async {
    final data = await _get(AppConfig.endpointPresident);
    if (data is List) {
      return data
          .map((item) => PresidentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<PresidentModel> getPresidentById(int id) async {
    final data = await _get('${AppConfig.endpointPresident}/$id');
    if (data is Map<String, dynamic>) {
      return PresidentModel.fromJson(data);
    }
    throw ApiException('Estructura de presidente invalida.');
  }

  // 3. Atracciones Turísticas
  Future<List<TouristicAttractionModel>> getTouristicAttractions() async {
    final data = await _get(AppConfig.endpointTouristicAttraction);
    if (data is List) {
      return data
          .map((item) => TouristicAttractionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<TouristicAttractionModel> getTouristicAttractionById(int id) async {
    final data = await _get('${AppConfig.endpointTouristicAttraction}/$id');
    if (data is Map<String, dynamic>) {
      return TouristicAttractionModel.fromJson(data);
    }
    throw ApiException('Estructura de atraccion turistica invalida.');
  }

  // 4. Platos Típicos
  Future<List<TypicalDishModel>> getTypicalDishes() async {
    final data = await _get(AppConfig.endpointTypicalDish);
    if (data is List) {
      return data
          .map((item) => TypicalDishModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<TypicalDishModel> getTypicalDishById(int id) async {
    final data = await _get('${AppConfig.endpointTypicalDish}/$id');
    if (data is Map<String, dynamic>) {
      return TypicalDishModel.fromJson(data);
    }
    throw ApiException('Estructura de plato tipico invalida.');
  }
}
