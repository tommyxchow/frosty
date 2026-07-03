import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/cache_manager.dart';

/// A wrapper around [CachedNetworkImage] that adds custom defaults for Frosty.
class FrostyCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final String? cacheKey;
  final double? width;
  final double? height;

  /// Decode size caps (physical pixels) for the in-memory image. Without
  /// these, images decode and stay resident at their intrinsic size — emote
  /// CDNs serve 3x-4x assets (~112-128 px) that render in ~28 lp boxes, so
  /// capping the decode cuts memory and raster cost several-fold. Applies to
  /// animated codecs too (all frames decode at the target size; animation is
  /// preserved). Providing only one axis keeps the aspect ratio.
  final int? memCacheWidth;
  final int? memCacheHeight;

  final Color? color;
  final BlendMode? colorBlendMode;
  final Widget Function(BuildContext, String)? placeholder;
  final bool useOldImageOnUrlChange;
  final bool useFade;
  final BoxFit? fit;

  const FrostyCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.cacheKey,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
    this.color,
    this.colorBlendMode,
    this.placeholder,
    this.useFade = true,
    this.useOldImageOnUrlChange = false,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheKey: cacheKey,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      color: color,
      colorBlendMode: colorBlendMode,
      placeholder: placeholder,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      fadeOutDuration: useFade
          ? const Duration(milliseconds: 500)
          : Duration.zero,
      fadeInDuration: useFade
          ? const Duration(milliseconds: 500)
          : Duration.zero,
      fadeInCurve: Curves.easeOut,
      fadeOutCurve: Curves.easeIn,
      fit: fit,
      cacheManager: CustomCacheManager.instance,
    );
  }
}
