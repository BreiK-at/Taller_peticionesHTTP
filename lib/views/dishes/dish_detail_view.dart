import 'package:flutter/material.dart';
import '../../models/typical_dish_model.dart';
import '../../services/api_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';
import '../../widgets/network_image_with_fallback.dart';

class DishDetailView extends StatefulWidget {
  final int dishId;
  final TypicalDishModel? initialDish;

  const DishDetailView({
    super.key,
    required this.dishId,
    this.initialDish,
  });

  @override
  State<DishDetailView> createState() => _DishDetailViewState();
}

class _DishDetailViewState extends State<DishDetailView> {
  final ApiService _apiService = ApiService();
  TypicalDishModel? _dish;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialDish != null) {
      _dish = widget.initialDish;
    } else {
      _cargarDetalle();
    }
  }

  Future<void> _cargarDetalle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getTypicalDishById(widget.dishId);
      setState(() {
        _dish = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dish?.name ?? 'Detalle Gastronomico'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingStateWidget(
        message: 'Consultando informacion del plato tipico...',
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Error al cargar plato tipico',
        message: _errorMessage!,
        onRetry: _cargarDetalle,
      );
    }

    if (_dish == null) {
      return const Center(child: Text('No hay datos disponibles.'));
    }

    final dish = _dish!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del plato
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: NetworkImageWithFallback(
              imageUrl: dish.imageUrl,
              borderRadius: BorderRadius.circular(20),
              fallbackIcon: Icons.restaurant_menu_rounded,
            ),
          ),
          const SizedBox(height: 20),

          // Nombre y Departamento de procedencia
          Text(
            dish.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.secondary),
                const SizedBox(width: 4),
                Text(
                  'Region / Origen: ${dish.departmentName}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ingredientes tradicionales
          const Text(
            'Ingredientes Principales',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          if (dish.ingredientList.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dish.ingredientList.map((ing) {
                return Chip(
                  avatar: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.primary),
                  label: Text(ing),
                  backgroundColor: AppTheme.primaryLight,
                  labelStyle: const TextStyle(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  side: BorderSide.none,
                );
              }).toList(),
            )
          else
            Text(
              dish.ingredients,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),

          const SizedBox(height: 24),

          // Reseña cultural y gastronómica
          const Text(
            'Reseña Cultural y Tradicion',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              dish.description,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
