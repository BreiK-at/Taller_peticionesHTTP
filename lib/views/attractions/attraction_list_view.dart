import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/touristic_attraction_model.dart';
import '../../services/api_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';
import '../../widgets/network_image_with_fallback.dart';

class AttractionListView extends StatefulWidget {
  const AttractionListView({super.key});

  @override
  State<AttractionListView> createState() => _AttractionListViewState();
}

class _AttractionListViewState extends State<AttractionListView> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<TouristicAttractionModel> _attractions = [];
  List<TouristicAttractionModel> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarAtracciones();
    _searchController.addListener(_filtrarAtracciones);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarAtracciones() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getTouristicAttractions();
      setState(() {
        _attractions = data;
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

  void _filtrarAtracciones() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = _attractions;
      } else {
        _filtered = _attractions.where((item) {
          final nameMatch = item.name.toLowerCase().contains(query);
          final cityMatch = item.cityName.toLowerCase().contains(query);
          return nameMatch || cityMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atracciones Turisticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: _cargarAtracciones,
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
                hintText: 'Buscar atraccion o ciudad...',
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
        message: 'Cargando atracciones y destinos turisticos...',
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Error al consultar atracciones',
        message: _errorMessage!,
        onRetry: _cargarAtracciones,
      );
    }

    if (_filtered.isEmpty) {
      return EmptyStateWidget(
        title: 'Sin coincidencias',
        message: 'No se encontraron atracciones turisticas para la busqueda.',
        onRefresh: () {
          _searchController.clear();
          _cargarAtracciones();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarAtracciones,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final item = _filtered[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: SizedBox(
                width: 56,
                height: 56,
                child: NetworkImageWithFallback(
                  imageUrl: item.primaryImage,
                  borderRadius: BorderRadius.circular(12),
                  fallbackIcon: Icons.landscape_rounded,
                ),
              ),
              title: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.cityName,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
              onTap: () {
                context.push('/attractions/${item.id}', extra: item);
              },
            ),
          );
        },
      ),
    );
  }
}
