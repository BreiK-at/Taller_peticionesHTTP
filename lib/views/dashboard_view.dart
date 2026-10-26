import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_config.dart';
import '../themes/app_theme.dart';
import '../widgets/dashboard_card_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos Abiertos Colombia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner principal del Dashboard
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
                    color: AppTheme.primary.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Electiva Profesional I — UCEVA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.api_rounded, color: Colors.white70, size: 24),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Explorador API Colombia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Consumo de datos abiertos gubernamentales con arquitectura por capas, go_router y gestion de estados.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 10),
                  const Text(
                    'Estudiante: Michael Stiven Vasco Cárdenas (230231047)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Encabezado de sección
            Row(
              children: [
                const Text(
                  'Modulos y Endpoints Disponibles',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '4 endpoints',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 1. Departamentos
            DashboardCardWidget(
              title: 'Departamentos',
              subtitle: 'Division politica, capitales departamentales, poblacion, superficie y prefijos.',
              endpoint: 'GET /Department',
              icon: Icons.map_rounded,
              accentColor: AppTheme.primary,
              onTap: () => context.push('/departments'),
            ),

            // 2. Presidentes
            DashboardCardWidget(
              title: 'Presidentes de Colombia',
              subtitle: 'Registro historico de mandatarios, partidos politicos, periodos y biografias.',
              endpoint: 'GET /President',
              icon: Icons.account_balance_rounded,
              accentColor: AppTheme.secondary,
              onTap: () => context.push('/presidents'),
            ),

            // 3. Atracciones Turísticas
            DashboardCardWidget(
              title: 'Atracciones Turisticas',
              subtitle: 'Destinos geograficos, centros historicos, coordenadas y galerias fotograficas.',
              endpoint: 'GET /TouristicAttraction',
              icon: Icons.landscape_rounded,
              accentColor: AppTheme.accentBlue,
              onTap: () => context.push('/attractions'),
            ),

            // 4. Platos Típicos
            DashboardCardWidget(
              title: 'Platos Tipicos',
              subtitle: 'Gastronomia representativa, ingredientes tradicionales y region de origen.',
              endpoint: 'GET /TypicalDish',
              icon: Icons.restaurant_rounded,
              accentColor: const Color(0xFFB45309),
              onTap: () => context.push('/dishes'),
            ),

            const SizedBox(height: 16),

            // Información de configuración de entorno
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings_ethernet_rounded, size: 20, color: AppTheme.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Variable de Entorno (.env)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          AppConfig.apiBaseUrl,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
