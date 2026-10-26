import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/department_model.dart';
import '../models/president_model.dart';
import '../models/touristic_attraction_model.dart';
import '../models/typical_dish_model.dart';
import '../views/dashboard_view.dart';
import '../views/departments/department_detail_view.dart';
import '../views/departments/department_list_view.dart';
import '../views/presidents/president_detail_view.dart';
import '../views/presidents/president_list_view.dart';
import '../views/attractions/attraction_detail_view.dart';
import '../views/attractions/attraction_list_view.dart';
import '../views/dishes/dish_detail_view.dart';
import '../views/dishes/dish_list_view.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String departments = '/departments';
  static const String departmentDetail = '/departments/:id';
  static const String presidents = '/presidents';
  static const String presidentDetail = '/presidents/:id';
  static const String attractions = '/attractions';
  static const String attractionDetail = '/attractions/:id';
  static const String dishes = '/dishes';
  static const String dishDetail = '/dishes/:id';
}

GoRouter createRouter({String initialLocation = AppRoutes.dashboard}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardView(),
    ),

    // Rutas de Departamentos
    GoRoute(
      path: AppRoutes.departments,
      name: 'departments',
      builder: (context, state) => const DepartmentListView(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'department-detail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            final extra = state.extra is DepartmentModel ? state.extra as DepartmentModel : null;
            return DepartmentDetailView(
              departmentId: id,
              initialDepartment: extra,
            );
          },
        ),
      ],
    ),

    // Rutas de Presidentes
    GoRoute(
      path: AppRoutes.presidents,
      name: 'presidents',
      builder: (context, state) => const PresidentListView(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'president-detail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            final extra = state.extra is PresidentModel ? state.extra as PresidentModel : null;
            return PresidentDetailView(
              presidentId: id,
              initialPresident: extra,
            );
          },
        ),
      ],
    ),

    // Rutas de Atracciones Turísticas
    GoRoute(
      path: AppRoutes.attractions,
      name: 'attractions',
      builder: (context, state) => const AttractionListView(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'attraction-detail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            final extra = state.extra is TouristicAttractionModel
                ? state.extra as TouristicAttractionModel
                : null;
            return AttractionDetailView(
              attractionId: id,
              initialAttraction: extra,
            );
          },
        ),
      ],
    ),

    // Rutas de Platos Típicos
    GoRoute(
      path: AppRoutes.dishes,
      name: 'dishes',
      builder: (context, state) => const DishListView(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'dish-detail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            final extra = state.extra is TypicalDishModel
                ? state.extra as TypicalDishModel
                : null;
            return DishDetailView(
              dishId: id,
              initialDish: extra,
            );
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Ruta no encontrada')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'La ruta "${state.uri}" no existe.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.dashboard),
            child: const Text('Volver al Inicio'),
          ),
        ],
      ),
    ),
  ),
);
