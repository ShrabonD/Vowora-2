import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/vowora_theme.dart';

enum ImageContextSize { thumbnail, card, hero, full }

class VoworaCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageContextSize contextSize;
  final String? cacheKey;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool isAssetFallback;

  const VoworaCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.contextSize = ImageContextSize.card,
    this.cacheKey,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.isAssetFallback = false,
  });

  int? get _memCacheWidth {
    switch (contextSize) {
      case ImageContextSize.thumbnail:
        return 240;
      case ImageContextSize.card:
        return 600;
      case ImageContextSize.hero:
        return 900;
      case ImageContextSize.full:
        return null;
    }
  }

  int? get _memCacheHeight {
    switch (contextSize) {
      case ImageContextSize.thumbnail:
        return 240;
      case ImageContextSize.card:
        return 600;
      case ImageContextSize.hero:
        return 900;
      case ImageContextSize.full:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    Widget content;
    if (cleanUrl.isEmpty) {
      content = _buildErrorWidget(context);
    } else if (cleanUrl.startsWith('assets/')) {
      content = Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => _buildErrorWidget(context),
      );
    } else if (!cleanUrl.startsWith('http')) {
      content = _buildErrorWidget(context);
    } else {
      content = CachedNetworkImage(
        imageUrl: cleanUrl,
        cacheKey: cacheKey,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: _memCacheWidth,
        memCacheHeight: _memCacheHeight,
        fadeInDuration: const Duration(milliseconds: 250),
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => placeholder ?? _buildSkeletonPlaceholder(context),
        errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(context),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildSkeletonPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: VoworaColors.darkCardBackground.withValues(alpha: 0.6),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              VoworaColors.champagneGold.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: VoworaColors.darkCardBackground,
        borderRadius: borderRadius,
      ),
      child: Image.asset(
        'assets/images/wedding_background.png',
        fit: fit,
        width: width,
        height: height,
      ),
    );
  }
}

class VoworaImagePreloader {
  /// Preloads essential image URLs into cache asynchronously without blocking UI thread
  static void preloadImages(BuildContext context, List<String> imageUrls) {
    if (imageUrls.isEmpty) return;
    Future.microtask(() {
      for (final url in imageUrls) {
        final clean = url.trim();
        if (clean.startsWith('http')) {
          precacheImage(CachedNetworkImageProvider(clean), context).catchError((_) {});
        } else if (clean.startsWith('assets/')) {
          precacheImage(AssetImage(clean), context).catchError((_) {});
        }
      }
    });
  }
}
