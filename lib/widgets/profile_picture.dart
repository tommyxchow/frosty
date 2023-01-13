import 'package:flutter/material.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/user.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/cached_image.dart';
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
    final diameter = radius * 2;

    return ClipOval(
      child: FutureBuilder(
        future:
            context.read<TwitchApi>().getUser(userLogin: userLogin, headers: context.read<AuthStore>().headersTwitch),
        builder: (context, AsyncSnapshot<UserTwitch> snapshot) {
          return snapshot.hasData
              ? FrostyCachedNetworkImage(
                  width: diameter,
                  height: diameter,
                  imageUrl: snapshot.data!.profileImageUrl,
                )
              : SizedBox(
                  width: diameter,
                  height: diameter,
                );
        },
      ),
    );
  }
}
