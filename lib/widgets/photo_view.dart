import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frosty/cache_manager.dart';
import 'package:frosty/theme.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class FrostyPhotoViewDialog extends HookWidget {
  final String imageUrl;
  final String? cacheKey;

  const FrostyPhotoViewDialog({
    super.key,
    required this.imageUrl,
    this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    final photoViewScaleState = useState(PhotoViewScaleState.initial);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dismissible(
          key: const Key('photo_view_dismissible'),
          direction: photoViewScaleState.value == PhotoViewScaleState.initial
              ? DismissDirection.vertical
              : DismissDirection.none,
          onDismissed: Navigator.of(context).pop,
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(
              imageUrl,
              cacheKey: cacheKey,
              cacheManager: CustomCacheManager.instance,
            ),
            scaleStateChangedCallback: (value) =>
                photoViewScaleState.value = value,
            backgroundDecoration:
                const BoxDecoration(color: Colors.transparent),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: context.watch<FrostyThemes>().dark.colorScheme.onSurface,
          ),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );
  }
}
