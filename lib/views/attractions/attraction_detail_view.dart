import 'package:flutter/material.dart';
import '../../models/touristic_attraction_model.dart';
import '../../services/api_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_state_widget.dart';
import '../../widgets/network_image_with_fallback.dart';

class AttractionDetailView extends StatefulWidget {
  final int attractionId;
  final TouristicAttractionModel? initialAttraction;

  const AttractionDetailView({
    super.key,
    required this.attractionId,
    this.initialAttraction,
  });

  @override
  State<AttractionDetailView> createState() => _AttractionDetailViewState();
}

class _AttractionDetailViewState extends State<AttractionDetailView> {
  final ApiService _apiService = ApiService();
  TouristicAttractionModel? _attraction;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialAttraction != null) {
      _attraction = widget.initialAttraction;
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
      final data = await _apiService.getTouristicAttractionById(widget.attractionId);
      setState(() {
        _attraction = data;
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
        title: Text(_attraction?.name ?? 'Detalle del Destino'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingStateWidget(
        message: 'Consultando informacion del destino turistico...',
      );
    }

    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Error al cargar atraccion',
        message: _errorMessage!,
        onRetry: _cargarDetalle,
      );
    }

    if (_attraction == null) {
      return const Center(child: Text('No hay datos disponibles.'));
    }

    final item = _attraction!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen principal
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
              imageUrl: item.primaryImage,
              borderRadius: BorderRadius.circular(20),
              fallbackIcon: Icons.landscape_rounded,
            ),
          ),
          const SizedBox(height: 20),

          // Título y Ciudad
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place_rounded, size: 14, color: AppTheme.primaryDark),
                    const SizedBox(width: 4),
                    Text(
                      item.cityName,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.latitude != null && item.longitude != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gps_fixed_rounded, size: 13, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${item.latitude}, ${item.longitude}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Descripción
          const Text(
            'Descripcion del Destino',
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
              item.description,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),

          // Galería si hay más de 1 imagen
          if (item.images.length > 1) ...[
            const SizedBox(height: 24),
            const Text(
              'Galeria de Imagenes',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.images.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 130,
                    child: NetworkImageWithFallback(
                      imageUrl: item.images[index],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
