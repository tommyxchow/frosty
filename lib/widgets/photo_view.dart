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
        Dismissible(
          key: const Key('photo_view_dismissible'),
          direction: DismissDirection.vertical,
          onDismissed: Navigator.of(context).pop,
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration:
                const BoxDecoration(color: Colors.transparent),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Text(
            'Swipe up or down to dismiss',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
