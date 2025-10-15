import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget optimizado para mostrar avatares con caché
class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CachedAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final defaultFgColor = foregroundColor ?? theme.colorScheme.onPrimaryContainer;

    // Si hay URL de imagen, usar cached_network_image
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: defaultBgColor,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: SizedBox(
                width: radius,
                height: radius,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(defaultFgColor),
                ),
              ),
            ),
            errorWidget: (context, url, error) => _buildInitials(
              defaultBgColor,
              defaultFgColor,
            ),
          ),
        ),
      );
    }

    // Si no hay imagen, mostrar iniciales
    return _buildInitials(defaultBgColor, defaultFgColor);
  }

  Widget _buildInitials(Color bgColor, Color fgColor) {
    final initials = _getInitials();
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: fgColor,
        ),
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) {
      return '?';
    }

    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return name![0].toUpperCase();
  }
}

/// Widget optimizado para mostrar imágenes con caché
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.broken_image_outlined,
          color: theme.colorScheme.onSurfaceVariant,
          size: 40,
        ),
      ),
    );

    // Aplicar border radius si se especificó
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Widget para thumbnail optimizado
class CachedThumbnail extends StatelessWidget {
  final String imageUrl;
  final double size;

  const CachedThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return CachedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(8),
    );
  }
}



