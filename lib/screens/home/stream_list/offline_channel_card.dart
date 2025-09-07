import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/models/followed_channel.dart';
import 'package:frosty/screens/channel/channel.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/user_actions_modal.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays an offline followed channel's details.
class OfflineChannelCard extends StatelessWidget {
  final FollowedChannel channelInfo;
  final bool showPinOption;
  final bool? isPinned;
  final bool showOfflineStatus;

  const OfflineChannelCard({
    super.key,
    required this.channelInfo,
    required this.showPinOption,
    this.isPinned,
    this.showOfflineStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final channelName = getReadableName(
      channelInfo.broadcasterName,
      channelInfo.broadcasterLogin,
    );

    final fontColor = DefaultTextStyle.of(context).style.color;
    final followedDuration = DateTime.now().difference(channelInfo.followedAt);

    String followedText;
    if (followedDuration.inDays >= 365) {
      final years = followedDuration.inDays ~/ 365;
      followedText = 'Following for $years ${years == 1 ? 'year' : 'years'}';
    } else if (followedDuration.inDays >= 30) {
      final months = followedDuration.inDays ~/ 30;
      followedText =
          'Following for $months ${months == 1 ? 'month' : 'months'}';
    } else if (followedDuration.inDays > 0) {
      followedText =
          'Following for ${followedDuration.inDays} ${followedDuration.inDays == 1 ? 'day' : 'days'}';
    } else if (followedDuration.inHours > 0) {
      followedText =
          'Following for ${followedDuration.inHours} ${followedDuration.inHours == 1 ? 'hour' : 'hours'}';
    } else {
      followedText =
          'Following for ${followedDuration.inMinutes} ${followedDuration.inMinutes == 1 ? 'minute' : 'minutes'}';
    }

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoChat(
            userId: channelInfo.broadcasterId,
            userName: channelInfo.broadcasterName,
            userLogin: channelInfo.broadcasterLogin,
          ),
        ),
      ),
      onLongPress: () {
        HapticFeedback.mediumImpact();

        showModalBottomSheetWithProperFocus(
          context: context,
          builder: (context) => UserActionsModal(
            authStore: context.read<AuthStore>(),
            name: channelName,
            userLogin: channelInfo.broadcasterLogin,
            userId: channelInfo.broadcasterId,
            showPinOption: showPinOption,
            isPinned: isPinned,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16 + MediaQuery.of(context).padding.left,
          vertical: 8,
        ),
        child: Row(
          spacing: 12,
          children: [
            // Profile picture
            ProfilePicture(userLogin: channelInfo.broadcasterLogin),
            // Channel info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Channel name
                  Text(
                    channelName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fontColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Status and follow duration
                  Text(
                    showOfflineStatus ? 'Offline' : followedText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: fontColor?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
