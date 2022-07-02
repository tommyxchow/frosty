import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/user.dart';
import 'package:provider/provider.dart';

class ProfilePicture extends StatelessWidget {
  final String userLogin;
  final double radius;

  const ProfilePicture({
    Key? key,
    required this.userLogin,
    this.radius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: FutureBuilder(
        future: context.read<TwitchApi>().getUser(userLogin: userLogin, headers: context.read<AuthStore>().headersTwitch),
        builder: (context, AsyncSnapshot<UserTwitch> snapshot) {
          return snapshot.hasData
              ? CachedNetworkImage(
                  width: radius * 2,
                  height: radius * 2,
                  imageUrl: snapshot.data!.profileImageUrl,
                )
              : SizedBox(
                  width: radius * 2,
                  height: radius * 2,
                );
        },
      ),
    );
  }
}
