import 'package:flutter/material.dart';
import '../../models/department_model.dart';
import '../../services/api_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';

class DepartmentDetailView extends StatefulWidget {
  final int departmentId;
  final DepartmentModel? initialDepartment;

  const DepartmentDetailView({
    super.key,
    required this.departmentId,
    this.initialDepartment,
  });

  @override
  State<DepartmentDetailView> createState() => _DepartmentDetailViewState();
}

class _DepartmentDetailViewState extends State<DepartmentDetailView> {
  final ApiService _apiService = ApiService();
  DepartmentModel? _department;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialDepartment != null) {
      _department = widget.initialDepartment;
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
      final data = await _apiService.getDepartmentById(widget.departmentId);
      setState(() {
        _department = data;
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
        title: Text(_department?.name ?? 'Detalle del Departamento'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingStateWidget(
        message: 'Consultando detalle del departamento...',
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Error al cargar detalle',
        message: _errorMessage!,
        onRetry: _cargarDetalle,
      );
    }

    if (_department == null) {
      return const Center(child: Text('No hay datos disponibles.'));
    }

    final dept = _department!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de cabecera
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ID: ${dept.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Icon(Icons.map_rounded, color: Colors.white70, size: 28),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  dept.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Capital: ${dept.capitalName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Métricas territoriales
          const Text(
            'Datos Generales',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: [
              _buildStatCard(
                icon: Icons.people_alt_outlined,
                label: 'Poblacion',
                value: dept.population > 0 ? dept.population.toString() : 'No disponible',
                color: Colors.blue.shade700,
              ),
              _buildStatCard(
                icon: Icons.square_foot_rounded,
                label: 'Superficie',
                value: dept.surface > 0 ? '${dept.surface} km²' : 'No disponible',
                color: Colors.teal.shade700,
              ),
              _buildStatCard(
                icon: Icons.holiday_village_outlined,
                label: 'Municipios',
                value: '${dept.municipalities}',
                color: Colors.amber.shade800,
              ),
              _buildStatCard(
                icon: Icons.phone_in_talk_outlined,
                label: 'Prefijo Telefonico',
                value: '+57 (${dept.phonePrefix})',
                color: Colors.purple.shade700,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Descripción geográfica y cultural
          const Text(
            'Descripcion Geografica y Territorial',
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              dept.description,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppTheme.textPrimary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
