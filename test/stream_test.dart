import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/stream.dart';

void main() {
  test('Twitch stream should parse correctly', () {
    const sampleStream = '''
      {
        "id":"43809710301",
        "user_id":"71092938",
        "user_login":"xqcow",
        "user_name":"xQcOW",
        "game_id":"508292",
        "game_name":"Bloons TD 6",
        "type":"live",
        "title":"A shorter title...",
        "viewer_count":50051,
        "started_at":"2021-09-23T20:06:22Z",
        "language":"en",
        "thumbnail_url":"https://static-cdn.jtvnw.net/previews-ttv/live_user_xqcow-{width}x{height}.jpg",
        "tag_ids":[
          "e6bb8b34-4c28-4b5f-94ed-12c1ebf2d0e4",
          "6ea6bca4-4712-4ab9-a906-e3336a9d8039",
          "6606e54c-f92d-40f6-8257-74977889ccdd"
          ],
        "is_mature":false
      }
    ''';

    final decoded = jsonDecode(sampleStream);
    final stream = StreamTwitch.fromJson(decoded);

    expect(stream.id, '43809710301');
    expect(stream.userId, '71092938');
    expect(stream.userLogin, 'xqcow');
    expect(stream.userName, 'xQcOW');
    expect(stream.gameId, '508292');
    expect(stream.gameName, 'Bloons TD 6');
    expect(stream.type, 'live');
    expect(stream.title, 'A shorter title...');
    expect(stream.viewerCount, 50051);
    expect(stream.startedAt, '2021-09-23T20:06:22Z');
    expect(stream.language, 'en');
    expect(stream.thumbnailUrl, 'https://static-cdn.jtvnw.net/previews-ttv/live_user_xqcow-{width}x{height}.jpg');
    expect(stream.tagIds, ["e6bb8b34-4c28-4b5f-94ed-12c1ebf2d0e4", "6ea6bca4-4712-4ab9-a906-e3336a9d8039", "6606e54c-f92d-40f6-8257-74977889ccdd"]);
    expect(stream.isMature, false);
  });
}
