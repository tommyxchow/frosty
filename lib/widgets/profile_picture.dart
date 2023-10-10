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
        future: context.read<TwitchApi>().getUser(
            userLogin: userLogin,
            headers: context.read<AuthStore>().headersTwitch),
        builder: (context, AsyncSnapshot<UserTwitch> snapshot) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: snapshot.hasData
                ? FrostyCachedNetworkImage(
                    width: diameter,
                    height: diameter,
                    imageUrl: snapshot.data!.profileImageUrl,
                    placeholder: (context, url) =>
                        ColoredBox(color: Colors.grey.shade900),
                  )
                : Container(
                    color: Colors.grey.shade900,
                    width: diameter,
                    height: diameter,
                  ),
          );
        },
      ),
    );
  }
}
