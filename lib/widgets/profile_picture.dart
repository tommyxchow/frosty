import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/user.dart';
import 'package:provider/provider.dart';

class ProfilePicture extends StatelessWidget {
  final String userLogin;
  final double? radius;

  const ProfilePicture({
    Key? key,
    required this.userLogin,
    this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<TwitchApi>().getUser(userLogin: userLogin, headers: context.read<AuthStore>().headersTwitch),
      builder: (context, AsyncSnapshot<UserTwitch> snapshot) {
        return AnimatedOpacity(
          opacity: snapshot.hasData ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: Colors.transparent,
            foregroundImage: snapshot.hasData ? CachedNetworkImageProvider(snapshot.data!.profileImageUrl) : null,
          ),
        );
      },
    );
  }
}
