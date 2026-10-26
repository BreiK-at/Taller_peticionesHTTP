import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/department_model.dart';
import '../../services/api_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

class DepartmentListView extends StatefulWidget {
  const DepartmentListView({super.key});

  @override
  State<DepartmentListView> createState() => _DepartmentListViewState();
}

class _DepartmentListViewState extends State<DepartmentListView> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<DepartmentModel> _departments = [];
  List<DepartmentModel> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarDepartamentos();
    _searchController.addListener(_filtrarDepartamentos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDepartamentos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.getDepartments();
      setState(() {
        _departments = data;
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

  void _filtrarDepartamentos() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = _departments;
      } else {
        _filtered = _departments.where((dept) {
          final nameMatch = dept.name.toLowerCase().contains(query);
          final capitalMatch = dept.capitalName.toLowerCase().contains(query);
          return nameMatch || capitalMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departamentos de Colombia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: _cargarDepartamentos,
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
                hintText: 'Buscar departamento o capital...',
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
        message: 'Cargando listado de departamentos...',
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Error al consultar departamentos',
        message: _errorMessage!,
        onRetry: _cargarDepartamentos,
      );
    }

    if (_filtered.isEmpty) {
      return EmptyStateWidget(
        title: 'Sin coincidencias',
        message: 'No se encontraron departamentos con el criterio de busqueda ingresado.',
        onRefresh: () {
          _searchController.clear();
          _cargarDepartamentos();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDepartamentos,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final dept = _filtered[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    dept.id.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              title: Text(
                dept.name,
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
                    const Icon(Icons.location_city_rounded, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Capital: ${dept.capitalName}',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.border.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${dept.municipalities} mun.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
              onTap: () {
                context.push('/departments/${dept.id}', extra: dept);
              },
            ),
          );
        },
      ),
    );
  }
}
