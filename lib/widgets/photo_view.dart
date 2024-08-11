import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FrostyPhotoViewDialog extends StatelessWidget {
  final String imageUrl;

  const FrostyPhotoViewDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PhotoView(
          imageProvider: CachedNetworkImageProvider(imageUrl),
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: Navigator.of(context).pop,
          ),
        ),
      ],
    );
  }
}
