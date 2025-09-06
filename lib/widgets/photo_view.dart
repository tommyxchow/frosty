import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/cache_manager.dart';
import 'package:frosty/theme.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class FrostyPhotoViewDialog extends StatefulWidget {
  final String imageUrl;
  final String? cacheKey;

  const FrostyPhotoViewDialog({
    super.key,
    required this.imageUrl,
    this.cacheKey,
  });

  @override
  State<FrostyPhotoViewDialog> createState() => _FrostyPhotoViewDialogState();
}

class _FrostyPhotoViewDialogState extends State<FrostyPhotoViewDialog>
    with TickerProviderStateMixin {
  PhotoViewScaleState photoViewScaleState = PhotoViewScaleState.initial;
  bool _isFullResolution = false;
  String? _currentCacheKey;

  // Vertical drag offset in pixels. Positive = dragging down.
  double _dragOffset = 0.0;
  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;
  // Exit animation (translate in swipe direction + fade out) when dismissing
  late final AnimationController _exitController;
  late Animation<double> _exitTranslateAnimation;
  late Animation<double> _exitOpacityAnimation;
  double _imageOpacity = 1.0;
  // Track swipe direction for dismissal animation
  double _swipeDirection = 1.0; // 1.0 for down, -1.0 for up

  @override
  void initState() {
    super.initState();
    _currentCacheKey = widget.cacheKey;
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _resetAnimation = Tween<double>(begin: 0, end: 0).animate(_resetController)
      ..addListener(() => setState(() => _dragOffset = _resetAnimation.value));
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _exitTranslateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    )..addListener(() => setState(() {}));
    _exitOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
        )..addListener(
          () => setState(() => _imageOpacity = _exitOpacityAnimation.value),
        );
  }

  void _toggleResolution() {
    setState(() {
      if (_isFullResolution) {
        // Switch back to the original thumbnail version
        _isFullResolution = false;
        _currentCacheKey = widget.cacheKey;
      } else {
        // Load full resolution and clear cache key to force fresh fetch
        _isFullResolution = true;
        _currentCacheKey = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create full resolution URL
    final fullResUrl = widget.imageUrl.replaceFirst('-{width}x{height}', '');
    // Only stream card thumbnails include the placeholder; emotes do not.
    // If replacement yields the same URL, there is no full-res variant.
    final supportsFullRes = fullResUrl != widget.imageUrl;

    final screenHeight = MediaQuery.of(context).size.height;
    final fadeDistance = screenHeight * 0.20; // 20% of screen height
    final buttonsOpacity = (1.0 - (_dragOffset.abs() / fadeDistance)).clamp(
      0.0,
      1.0,
    );

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Very weak blurred background behind the image (fills the screen)
        BlurredContainer(
          sigmaX: 4.0,
          sigmaY: 4.0,
          // Use a very low alpha so the blur is subtle
          backgroundAlpha: 0,
          child: const SizedBox.expand(),
        ),
        // Use a GestureDetector so we can track vertical drags and translate the
        // PhotoView accordingly. When the photo is zoomed (not initial) we disable dragging.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (_) {
            if (_resetController.isAnimating) _resetController.stop();
            // Reset swipe direction for new drag
            _swipeDirection = 1.0;
          },
          onVerticalDragUpdate:
              photoViewScaleState == PhotoViewScaleState.initial
              ? (details) => setState(() => _dragOffset += details.delta.dy)
              : null,
          onVerticalDragEnd: photoViewScaleState == PhotoViewScaleState.initial
              ? (details) {
                  final velocity = details.velocity.pixelsPerSecond.dy;
                  final shouldDismiss =
                      (_dragOffset.abs() > fadeDistance) ||
                      velocity.abs() > 700;
                  if (shouldDismiss) {
                    // Determine swipe direction based on drag offset and velocity
                    _swipeDirection = _dragOffset > 0 ? 1.0 : -1.0;
                    if (_dragOffset.abs() < 10 && velocity != 0) {
                      _swipeDirection = velocity > 0 ? 1.0 : -1.0;
                    }
                    // run exit animation: translate in swipe direction by 30% of screen and fade out
                    _exitController
                      ..value = 0.0
                      ..forward().whenComplete(
                        () => Navigator.of(context).pop(),
                      );
                    return;
                  }

                  // animate back to zero
                  _resetAnimation = Tween<double>(
                    begin: _dragOffset,
                    end: 0.0,
                  ).animate(_resetController);
                  _resetController
                    ..value = 0.0
                    ..forward();
                }
              : null,
          child: Transform.translate(
            offset: Offset(
              0,
              _dragOffset +
                  (_exitTranslateAnimation.value *
                      screenHeight *
                      0.25 *
                      _swipeDirection),
            ),
            child: Opacity(
              opacity: _imageOpacity,
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(
                  _isFullResolution ? fullResUrl : widget.imageUrl,
                  cacheKey: _currentCacheKey,
                  cacheManager: CustomCacheManager.instance,
                ),
                scaleStateChangedCallback: (value) =>
                    setState(() => photoViewScaleState = value),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
        // Close button that fades with drag
        AnimatedOpacity(
          opacity: buttonsOpacity,
          duration: const Duration(milliseconds: 100),
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: context.watch<FrostyThemes>().dark.colorScheme.onSurface,
            ),
            onPressed: Navigator.of(context).pop,
          ),
        ),

        if (supportsFullRes)
          Positioned(
            // Place the button roughly between the image area and the bottom of the screen.
            // Assumption: the photo view occupies the top portion of the screen; using
            // a fractional top offset (80%) places the button in the gap between image and bottom.
            top: MediaQuery.of(context).size.height * 0.8,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Center(
                child: AnimatedOpacity(
                  opacity: buttonsOpacity,
                  duration: const Duration(milliseconds: 100),
                  child: ElevatedButton(
                    onPressed: _toggleResolution,
                    child: Text(
                      _isFullResolution ? 'View thumbnail' : 'View original',
                      style: TextStyle(
                        color: context
                            .watch<FrostyThemes>()
                            .dark
                            .colorScheme
                            .onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    _exitController.dispose();
    super.dispose();
  }
}
