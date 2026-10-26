import 'package:flutter/material.dart';
import '../../models/president_model.dart';
import '../../services/api_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';
import '../../widgets/network_image_with_fallback.dart';

class PresidentDetailView extends StatefulWidget {
  final int presidentId;
  final PresidentModel? initialPresident;

  const PresidentDetailView({
    super.key,
    required this.presidentId,
    this.initialPresident,
  });

  @override
  State<PresidentDetailView> createState() => _PresidentDetailViewState();
}

class _PresidentDetailViewState extends State<PresidentDetailView> {
  final ApiService _apiService = ApiService();
  PresidentModel? _president;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialPresident != null) {
      _president = widget.initialPresident;
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
      final data = await _apiService.getPresidentById(widget.presidentId);
      setState(() {
        _president = data;
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
        title: Text(_president?.fullName ?? 'Detalle del Presidente'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingStateWidget(
        message: 'Consultando datos del mandatario...',
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Error al cargar presidente',
        message: _errorMessage!,
        onRetry: _cargarDetalle,
      );
    }

    if (_president == null) {
      return const Center(child: Text('No hay datos disponibles.'));
    }

    final president = _president!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de perfil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: NetworkImageWithFallback(
                    imageUrl: president.image,
                    borderRadius: BorderRadius.circular(60),
                    fallbackIcon: Icons.account_circle_rounded,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  president.fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    president.politicalParty,
                    style: const TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.border),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn(
                      icon: Icons.calendar_today_rounded,
                      title: 'Periodo de Mandato',
                      value: president.periodFormatted,
                    ),
                    _buildInfoColumn(
                      icon: Icons.location_on_outlined,
                      title: 'Lugar de Origen',
                      value: president.cityName,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reseña biográfica
          const Text(
            'Reseña Biografica e Historica',
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
              president.description,
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

  Widget _buildInfoColumn({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.secondary),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
