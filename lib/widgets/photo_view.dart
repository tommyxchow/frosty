import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FrostyPhotoViewDialog extends StatefulWidget {
  final String imageUrl;

  const FrostyPhotoViewDialog({super.key, required this.imageUrl});

  @override
  State<FrostyPhotoViewDialog> createState() => _FrostyPhotoViewDialogState();
}

class _FrostyPhotoViewDialogState extends State<FrostyPhotoViewDialog> {
  PhotoViewScaleState photoViewScaleState = PhotoViewScaleState.initial;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dismissible(
          key: const Key('photo_view_dismissible'),
          direction: photoViewScaleState == PhotoViewScaleState.initial
              ? DismissDirection.vertical
              : DismissDirection.none,
          onDismissed: Navigator.of(context).pop,
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(widget.imageUrl),
            scaleStateChangedCallback: (value) =>
                setState(() => photoViewScaleState = value),
            backgroundDecoration:
                const BoxDecoration(color: Colors.transparent),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: Navigator.of(context).pop,
        ),
      ],
    );
  }
}
