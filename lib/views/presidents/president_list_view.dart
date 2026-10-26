import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/president_model.dart';
import '../../services/api_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';
import '../../widgets/network_image_with_fallback.dart';

class PresidentListView extends StatefulWidget {
  const PresidentListView({super.key});

  @override
  State<PresidentListView> createState() => _PresidentListViewState();
}

class _PresidentListViewState extends State<PresidentListView> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<PresidentModel> _presidents = [];
  List<PresidentModel> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarPresidentes();
    _searchController.addListener(_filtrarPresidentes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarPresidentes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getPresidents();
      setState(() {
        _presidents = data;
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

  void _filtrarPresidentes() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = _presidents;
      } else {
        _filtered = _presidents.where((p) {
          final nameMatch = p.fullName.toLowerCase().contains(query);
          final partyMatch = p.politicalParty.toLowerCase().contains(query);
          final cityMatch = p.cityName.toLowerCase().contains(query);
          return nameMatch || partyMatch || cityMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presidentes de Colombia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: _cargarPresidentes,
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
                hintText: 'Buscar presidente, partido o ciudad...',
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
        message: 'Cargando listado historico de presidentes...',
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Error al consultar presidentes',
        message: _errorMessage!,
        onRetry: _cargarPresidentes,
      );
    }

    if (_filtered.isEmpty) {
      return EmptyStateWidget(
        title: 'Sin coincidencias',
        message: 'No se encontraron mandatarios con el criterio de busqueda.',
        onRefresh: () {
          _searchController.clear();
          _cargarPresidentes();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarPresidentes,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final president = _filtered[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: SizedBox(
                width: 50,
                height: 50,
                child: NetworkImageWithFallback(
                  imageUrl: president.image,
                  borderRadius: BorderRadius.circular(25),
                  fallbackIcon: Icons.person_rounded,
                ),
              ),
              title: Text(
                president.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partido: ${president.politicalParty}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        president.periodFormatted,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
              onTap: () {
                context.push('/presidents/${president.id}', extra: president);
              },
            ),
          );
        },
      ),
    );
  }
}
