import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/irc.dart';

class ChatModes extends StatelessWidget {
  final ROOMSTATE roomState;

  const ChatModes({super.key, required this.roomState});

  String pluralize(String str, String count) => count == '1' ? str : '${str}s';

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final activeModes = <MapEntry<String, Widget>>[];

        // Collect active modes with their labels for sorting
        if (roomState.emoteOnly != '0') {
          activeModes.add(
            MapEntry(
              'Emote only',
              _buildModeChip(
                context: context,
                icon: Icons.emoji_emotions_outlined,
                activeIcon: Icons.emoji_emotions_rounded,
                label: 'Emote only',
                activeLabel: 'Emote only',
                isActive: true,
                activeColor: const Color(0xFFFFB74D), // Slightly lighter orange
              ),
            ),
          );
        }

        if (roomState.followersOnly != '-1') {
          activeModes.add(
            MapEntry(
              'Follower only',
              _buildModeChip(
                context: context,
                icon: Icons.favorite_outline_rounded,
                activeIcon: Icons.favorite_rounded,
                label: 'Follower only',
                activeLabel: 'Follower only',
                isActive: true,
                activeColor: const Color(0xFFF44336), // Bright red
                duration: _getFollowersDuration(),
              ),
            ),
          );
        }

        if (roomState.slowMode != '0') {
          activeModes.add(
            MapEntry(
              'Slow mode',
              _buildModeChip(
                context: context,
                icon: Icons.hourglass_empty_rounded,
                activeIcon: Icons.hourglass_top_rounded,
                label: 'Slow mode',
                activeLabel: 'Slow mode',
                isActive: true,
                activeColor: const Color(0xFF2196F3), // Bright blue
                duration: _getSlowModeDuration(),
              ),
            ),
          );
        }

        if (roomState.subMode != '0') {
          activeModes.add(
            MapEntry(
              'Sub only',
              _buildModeChip(
                context: context,
                icon: Icons.monetization_on_outlined,
                activeIcon: Icons.monetization_on_rounded,
                label: 'Sub only',
                activeLabel: 'Sub only',
                isActive: true,
                activeColor: const Color(0xFF4CAF50), // Bright green
              ),
            ),
          );
        }

        if (roomState.r9k != '0') {
          activeModes.add(
            MapEntry(
              'Unique mode',
              _buildModeChip(
                context: context,
                icon: Icons.quiz_outlined,
                activeIcon: Icons.quiz_rounded,
                label: 'Unique mode',
                activeLabel: 'Unique mode',
                isActive: true,
                activeColor: const Color(0xFFAB47BC), // Slightly lighter purple
              ),
            ),
          );
        }

        // Sort alphabetically by label
        activeModes.sort((a, b) => a.key.compareTo(b.key));
        final activeChips = activeModes.map((entry) => entry.value).toList();

        return Wrap(
          spacing: 8,
          runSpacing: -4,
          children: activeChips,
        );
      },
    );
  }

  String? _getFollowersDuration() {
    if (roomState.followersOnly == '0') {
      return null; // No duration for immediate followers
    }
    final minutes = int.parse(roomState.followersOnly);
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
    return '${minutes}m';
  }

  String _getSlowModeDuration() {
    final seconds = int.parse(roomState.slowMode);
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return '${minutes}m';
      } else {
        return '${minutes}m ${remainingSeconds}s';
      }
    }
    return '${seconds}s';
  }

  Widget _buildModeChip({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String activeLabel,
    required bool isActive,
    required Color activeColor,
    String? duration,
  }) {
    return Chip(
      avatar: Icon(
        isActive ? activeIcon : icon,
        size: 16,
        color: isActive ? activeColor : null,
      ),
      label: duration != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isActive ? activeLabel : label),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            )
          : Text(isActive ? activeLabel : label),
      side: BorderSide.none,
    );
  }
}
