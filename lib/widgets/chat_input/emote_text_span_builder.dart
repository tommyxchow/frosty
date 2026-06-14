import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/widgets/frosty_cached_network_image.dart';

/// A [SpecialTextSpanBuilder] that renders emote names as inline images.
///
/// This builder parses input text word-by-word and converts recognized emote
/// names into [ExtendedWidgetSpan] widgets displaying the emote image.
/// Unrecognized words remain as regular text.
class EmoteTextSpanBuilder extends SpecialTextSpanBuilder {
  /// Map of emote names to their [Emote] objects (global + channel emotes).
  final Map<String, Emote> emoteToObject;

  /// Map of user-owned emotes (subscriber, bits, unlocked).
  final Map<String, Emote> userEmoteToObject;

  /// The height to render emotes at.
  final double emoteSize;

  EmoteTextSpanBuilder({
    required this.emoteToObject,
    required this.userEmoteToObject,
    required this.emoteSize,
  });

  @override
  TextSpan build(
    String data, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
  }) {
    if (data.isEmpty) {
      return TextSpan(text: '', style: textStyle);
    }

    final spans = <InlineSpan>[];
    var currentIndex = 0;

    // Split by spaces but preserve space positions
    final parts = _splitPreservingSpaces(data);

    for (final part in parts) {
      if (part == ' ') {
        // Add space as regular text
        spans.add(TextSpan(text: ' ', style: textStyle));
        currentIndex += 1;
      } else if (part.isNotEmpty) {
        // Check if this word is an emote - render immediately on exact match
        final emote = emoteToObject[part] ?? userEmoteToObject[part];

        if (emote != null) {
          spans.add(_createEmoteSpan(emote, part, currentIndex));
        } else {
          spans.add(TextSpan(text: part, style: textStyle));
        }
        currentIndex += part.length;
      }
    }

    return TextSpan(children: spans, style: textStyle);
  }

  /// Splits text into words and spaces, preserving the spaces as separate elements.
  List<String> _splitPreservingSpaces(String text) {
    final result = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == ' ') {
        if (buffer.isNotEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        }
        result.add(' ');
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }

    return result;
  }

  /// Creates an [ExtendedWidgetSpan] for the given emote.
  ExtendedWidgetSpan _createEmoteSpan(Emote emote, String text, int start) {
    // Calculate dimensions - use emote's native size if available,
    // otherwise use the configured emoteSize
    final height = emote.height?.toDouble() ?? emoteSize;
    final width = emote.width?.toDouble();

    return ExtendedWidgetSpan(
      actualText: text,
      start: start,
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: FrostyCachedNetworkImage(
          imageUrl: emote.url,
          height: height,
          width: width,
          useFade: false,
        ),
      ),
    );
  }

  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    int? index,
  }) {
    // We handle all parsing in the build method, so this returns null
    return null;
  }
}
