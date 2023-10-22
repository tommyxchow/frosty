import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/user.dart';

void main() {
  test('Twitch user should parse', () {
    const sampleUser = '''
      {
        "id":"88888888",
        "login":"bob",
        "display_name":"Bob",
        "type":"random type",
        "broadcaster_type":"streamer",
        "description":"random description",
        "profile_image_url":"https://static-cdn.jtvnw.net/user-default-pictures-uv/ead5c8b2-a4c9-4724-b1dd-9f00b46cbd3d-profile_image-300x300.png",
        "offline_image_url":"",
        "view_count":94,
        "created_at":"2013-09-25T00:32:05Z"
      }
    ''';

    final decoded = jsonDecode(sampleUser);
    final user = UserTwitch.fromJson(decoded);

    expect(user.id, '88888888');
    expect(user.login, 'bob');
    expect(user.displayName, 'Bob');
    expect(
      user.profileImageUrl,
      'https://static-cdn.jtvnw.net/user-default-pictures-uv/ead5c8b2-a4c9-4724-b1dd-9f00b46cbd3d-profile_image-300x300.png',
    );
  });
}
