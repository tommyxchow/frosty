import 'package:flutter/material.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/widgets/frosty_cached_network_image.dart';
import 'package:provider/provider.dart';

const _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

class ProfilePicture extends StatefulWidget {
  final String userLogin;
  final double radius;
  final bool isGrayscale;

  const ProfilePicture({
    super.key,
    required this.userLogin,
    this.radius = 20,
    this.isGrayscale = false,
  });

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  // Cache profile image URLs to avoid repeated API calls
  static final Map<String, String> _urlCache = {};
  static final Map<String, Future<String>> _pendingRequests = {};

  @override
  void initState() {
    super.initState();
  }

  Future<String> _getProfileImageUrl() async {
    final userLogin = widget.userLogin;

    // Return cached URL if available
    if (_urlCache.containsKey(userLogin)) {
      return _urlCache[userLogin]!;
    }

    // Return existing pending request if one is already in progress
    if (_pendingRequests.containsKey(userLogin)) {
      return _pendingRequests[userLogin]!;
    }

    // Make new request and cache it
    final future = context
        .read<TwitchApi>()
        .getUser(userLogin: userLogin)
        .then((user) => user.profileImageUrl);
    _pendingRequests[userLogin] = future;

    try {
      final url = await future;
      _urlCache[userLogin] = url;
      _pendingRequests.remove(userLogin);
      return url;
    } catch (e) {
      _pendingRequests.remove(userLogin);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radius * 2;
    final placeholderColor = Theme.of(context).colorScheme.surfaceContainer;

    final avatar = ClipOval(
      child: FutureBuilder<String>(
        future: _getProfileImageUrl(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? FrostyCachedNetworkImage(
                  width: diameter,
                  height: diameter,
                  imageUrl: snapshot.data!,
                  placeholder: (context, url) =>
                      ColoredBox(color: placeholderColor),
                )
              : Container(
                  color: placeholderColor,
                  width: diameter,
                  height: diameter,
                );
        },
      ),
    );

    if (!widget.isGrayscale) return avatar;

    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
      child: avatar,
    );
  }
}
