import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taller_peticiones_http/models/department_model.dart';
import 'package:taller_peticiones_http/models/president_model.dart';
import 'package:taller_peticiones_http/models/touristic_attraction_model.dart';
import 'package:taller_peticiones_http/models/typical_dish_model.dart';
import 'package:taller_peticiones_http/services/api_service.dart';
import 'package:taller_peticiones_http/views/dashboard_view.dart';
import 'package:taller_peticiones_http/widgets/dashboard_card_widget.dart';

void main() {
  group('Pruebas Unitarias de Modelos de Datos', () {
    test('DepartmentModel serializa y deserializa correctamente', () {
      final jsonSample = {
        "id": 5,
        "name": "Antioquia",
        "description": "Departamento ubicado al noroccidente.",
        "municipalities": 125,
        "surface": 63612,
        "population": 6887306,
        "phonePrefix": "4",
        "cityCapital": {"name": "Medellin"}
      };

      final model = DepartmentModel.fromJson(jsonSample);
      expect(model.id, 5);
      expect(model.name, "Antioquia");
      expect(model.capitalName, "Medellin");
      expect(model.municipalities, 125);
      expect(model.surface, 63612);

      final jsonOutput = model.toJson();
      expect(jsonOutput['name'], "Antioquia");
      expect(jsonOutput['capitalName'], "Medellin");
    });

    test('PresidentModel calcula fullName y periodo correctamente', () {
      final jsonSample = {
        "id": 1,
        "name": "Jose Maria",
        "lastName": "Campo Serrano",
        "image": "https://example.com/foto.jpg",
        "startPeriodDate": "1886-08-05",
        "endPeriodDate": "1887-01-06",
        "politicalParty": "Partido Nacional",
        "description": "Presidente constitucional.",
        "city": {"name": "Santa Marta"}
      };

      final model = PresidentModel.fromJson(jsonSample);
      expect(model.fullName, "Jose Maria Campo Serrano");
      expect(model.periodFormatted, "1886-08-05 a 1887-01-06");
      expect(model.cityName, "Santa Marta");
    });

    test('TouristicAttractionModel extrae lista de imagenes y ciudad', () {
      final jsonSample = {
        "id": 10,
        "name": "Parque Tayrona",
        "description": "Area natural protegida.",
        "images": ["https://example.com/tayrona1.jpg", "https://example.com/tayrona2.jpg"],
        "latitude": "11.312",
        "longitude": "-74.072",
        "city": {"name": "Santa Marta"}
      };

      final model = TouristicAttractionModel.fromJson(jsonSample);
      expect(model.name, "Parque Tayrona");
      expect(model.images.length, 2);
      expect(model.primaryImage, "https://example.com/tayrona1.jpg");
      expect(model.cityName, "Santa Marta");
    });

    test('TypicalDishModel formatea lista de ingredientes', () {
      final jsonSample = {
        "id": 1,
        "name": "Ajiaco",
        "description": "Sopa tradicional con pollo y papas.",
        "ingredients": "Pollo, Papa criolla, Guascas, Mazorca, Crema de leche",
        "imageUrl": "https://example.com/ajiaco.jpg",
        "department": {"name": "Cundinamarca"}
      };

      final model = TypicalDishModel.fromJson(jsonSample);
      expect(model.name, "Ajiaco");
      expect(model.departmentName, "Cundinamarca");
      expect(model.ingredientList.length, 5);
      expect(model.ingredientList.first, "Pollo");
    });
  });

  group('Pruebas de ApiService con Respuestas Mock', () {
    test('getDepartments() procesa respuesta exitosa 200 OK', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode([
            {"id": 1, "name": "Amazonas", "cityCapital": {"name": "Leticia"}}
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = ApiService(client: mockClient);
      final depts = await service.getDepartments();

      expect(depts.length, 1);
      expect(depts.first.name, "Amazonas");
      expect(depts.first.capitalName, "Leticia");
    });

    test('getDepartments() lanza ApiException ante error 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = ApiService(client: mockClient);
      expect(() => service.getDepartments(), throwsA(isA<ApiException>()));
    });
  });

  group('Pruebas de Interfaz del Dashboard', () {
    testWidgets('DashboardView renderiza encabezado y 4 tarjetas de endpoints', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardView(),
        ),
      );

      // Verificación de títulos y elementos
      expect(find.text('Explorador API Colombia'), findsOneWidget);
      expect(find.text('Modulos y Endpoints Disponibles'), findsOneWidget);

      // Verificación de las 4 cards interactivas
      expect(find.byType(DashboardCardWidget), findsNWidgets(4));
      expect(find.text('Departamentos'), findsOneWidget);
      expect(find.text('Presidentes de Colombia'), findsOneWidget);
      expect(find.text('Atracciones Turisticas'), findsOneWidget);
      expect(find.text('Platos Tipicos'), findsOneWidget);

      // Verificación de los endpoints en las cards
      expect(find.text('GET /Department'), findsOneWidget);
      expect(find.text('GET /President'), findsOneWidget);
      expect(find.text('GET /TouristicAttraction'), findsOneWidget);
      expect(find.text('GET /TypicalDish'), findsOneWidget);
    });
  });
}
