import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/typical_dish_model.dart';
import '../../services/api_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';
import '../../widgets/network_image_with_fallback.dart';

class DishListView extends StatefulWidget {
  const DishListView({super.key});

  @override
  State<DishListView> createState() => _DishListViewState();
}

class _DishListViewState extends State<DishListView> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<TypicalDishModel> _dishes = [];
  List<TypicalDishModel> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarPlatos();
    _searchController.addListener(_filtrarPlatos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarPlatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getTypicalDishes();
      setState(() {
        _dishes = data;
        _filtered = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filtrarPlatos() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = _dishes;
      } else {
        _filtered = _dishes.where((dish) {
          final nameMatch = dish.name.toLowerCase().contains(query);
          final deptMatch = dish.departmentName.toLowerCase().contains(query);
          return nameMatch || deptMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platos Tipicos Colombianos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: _cargarPlatos,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar plato o departamento de origen...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingStateWidget(
        message: 'Cargando muestra gastronomica tradicional...',
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Error al consultar platos tipicos',
        message: _errorMessage!,
        onRetry: _cargarPlatos,
      );
    }

    if (_filtered.isEmpty) {
      return EmptyStateWidget(
        title: 'Sin coincidencias',
        message: 'No se encontraron platos tipicos con ese termino de busqueda.',
        onRefresh: () {
          _searchController.clear();
          _cargarPlatos();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarPlatos,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final dish = _filtered[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: SizedBox(
                width: 56,
                height: 56,
                child: NetworkImageWithFallback(
                  imageUrl: dish.imageUrl,
                  borderRadius: BorderRadius.circular(12),
                  fallbackIcon: Icons.restaurant_rounded,
                ),
              ),
              title: Text(
                dish.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.flag_outlined, size: 14, color: AppTheme.secondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dish.departmentName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
              onTap: () {
                context.push('/dishes/${dish.id}', extra: dish);
              },
            ),
          );
        },
      ),
    );
  }
}
