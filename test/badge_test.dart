import "dart:convert";
import "package:flutter_test/flutter_test.dart";
import 'package:frosty/models/badges.dart';

void main() {
  group('Twitch', () {
    test('badge should parse correctly', () {
      const sampleJson = '''{
        "set_id": "vip",
        "versions": [
          {
            "id": "1",
            "image_url_1x": "https://static-cdn.jtvnw.net/badges/v1/b817aba4-fad8-49e2-b88a-7cc744dfa6ec/1",
            "image_url_2x": "https://static-cdn.jtvnw.net/badges/v1/b817aba4-fad8-49e2-b88a-7cc744dfa6ec/2",
            "image_url_4x": "https://static-cdn.jtvnw.net/badges/v1/b817aba4-fad8-49e2-b88a-7cc744dfa6ec/3"
          }
        ]
      }''';

      final decoded = jsonDecode(sampleJson);
      final badge = BadgesTwitch.fromJson(decoded);

      expect(badge.setId, "vip");
      expect(badge.versions.first.id, "1");
      expect(badge.versions.first.imageUrl4x, "https://static-cdn.jtvnw.net/badges/v1/b817aba4-fad8-49e2-b88a-7cc744dfa6ec/3");
    });
  });
}
