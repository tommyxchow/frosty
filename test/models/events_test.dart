import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/events.dart';

import '../fixtures/api_responses.dart';

void main() {
  group('SevenTVEvent', () {
    test('fromJson deserializes op, t, and d fields', () {
      final event = SevenTVEvent.fromJson(
        sevenTVEventJson as Map<String, dynamic>,
      );

      expect(event.op, 0);
      expect(event.t, 1);
      expect(event.d.type, 'emote_set.update');
    });

    test('toJson roundtrip preserves data', () {
      final event = SevenTVEvent.fromJson(
        sevenTVEventJson as Map<String, dynamic>,
      );

      // Use jsonEncode/jsonDecode for a true roundtrip, since toJson()
      // doesn't recursively serialize nested objects without explicitToJson.
      final json = jsonDecode(jsonEncode(event.toJson()))
          as Map<String, dynamic>;
      final restored = SevenTVEvent.fromJson(json);

      expect(restored.op, event.op);
      expect(restored.t, event.t);
      expect(restored.d.type, event.d.type);
    });

    test('fromJson handles null t field', () {
      final event = SevenTVEvent.fromJson(const {
        'op': 2,
        'd': {'type': null},
      });

      expect(event.op, 2);
      expect(event.t, isNull);
    });
  });

  group('SevenTVEventData', () {
    test('fromJson deserializes type and condition', () {
      final data = SevenTVEventData.fromJson(
        (sevenTVEventJson as Map<String, dynamic>)['d']
            as Map<String, dynamic>,
      );

      expect(data.type, 'emote_set.update');
      expect(data.condition?['object_id'], 'set_abc123');
    });

    test('fromJson with null type', () {
      final data = SevenTVEventData.fromJson(const {
        'type': null,
        'condition': null,
      });

      expect(data.type, isNull);
      expect(data.condition, isNull);
    });

    test('toJson produces valid output', () {
      const data = SevenTVEventData(
        type: 'emote_set.update',
        condition: {'object_id': 'test'},
      );

      final json = data.toJson();

      expect(json['type'], 'emote_set.update');
      expect(json['condition'], {'object_id': 'test'});
    });
  });

  group('SevenTVEventEmoteSetBody', () {
    test('fromJson deserializes actor and pushed/pulled lists', () {
      final body = SevenTVEventEmoteSetBody.fromJson(const {
        'actor': {
          'username': 'moderator',
          'display_name': 'Moderator',
        },
        'pushed': <dynamic>[],
        'pulled': <dynamic>[],
      });

      expect(body.actor.username, 'moderator');
      expect(body.actor.displayName, 'Moderator');
      expect(body.pushed, isEmpty);
      expect(body.pulled, isEmpty);
    });

    test('fromJson handles null pushed/pulled', () {
      final body = SevenTVEventEmoteSetBody.fromJson(const {
        'actor': {
          'username': 'mod',
          'display_name': 'Mod',
        },
      });

      expect(body.pushed, isNull);
      expect(body.pulled, isNull);
    });
  });
}
