import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRefresh;

  const EmptyStateWidget({
    super.key,
    this.title = 'Sin resultados',
    this.message = 'No se encontraron registros en esta seccion.',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.border.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 38,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Actualizar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
