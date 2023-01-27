import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

/// A wrapper around [CachedNetworkImage] that adds custom defaults for Frosty.
class FrostyCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Widget Function(BuildContext, String)? placeholder;
  final bool useOldImageOnUrlChange;
  final bool useFade;
  final BoxFit? fit;

  const FrostyCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.placeholder,
    this.useFade = true,
    this.useOldImageOnUrlChange = false,
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      placeholder: placeholder,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      fadeOutDuration: useFade ? const Duration(milliseconds: 500) : Duration.zero,
      fadeInDuration: useFade ? const Duration(milliseconds: 500) : Duration.zero,
      fadeInCurve: Curves.easeOut,
      fadeOutCurve: Curves.easeIn,
      fit: fit,
    );
  }
}
