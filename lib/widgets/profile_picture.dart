import 'package:flutter/material.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/user.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:provider/provider.dart';

class ProfilePicture extends StatefulWidget {
  final String userLogin;
  final double radius;

  const ProfilePicture({
    super.key,
    required this.userLogin,
    this.radius = 20,
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
    final future = context.read<TwitchApi>().getUser(userLogin: userLogin)
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

    return ClipOval(
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
  }

  // Clear cache when app needs fresh data (e.g., user logout/login)
  // Can be called from anywhere: ProfilePicture.clearCache();
  static void clearCache() {
    _urlCache.clear();
    _pendingRequests.clear();
  }
}
