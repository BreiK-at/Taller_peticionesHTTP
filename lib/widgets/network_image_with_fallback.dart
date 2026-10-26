import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.image_not_supported_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final clipRadius = borderRadius ?? BorderRadius.zero;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildFallback(clipRadius);
    }

    return ClipRRect(
      borderRadius: clipRadius,
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppTheme.border.withValues(alpha: 0.4),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(clipRadius);
        },
      ),
    );
  }

  Widget _buildFallback(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.border.withValues(alpha: 0.5),
        borderRadius: radius,
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          size: (height != null && height! < 60) ? 22 : 32,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
