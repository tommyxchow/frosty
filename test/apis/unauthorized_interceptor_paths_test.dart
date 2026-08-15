import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/unauthorized_interceptor.dart';

void main() {
  group('moderation path helpers', () {
    test('matches helix moderation paths', () {
      expect(
        isTwitchModeratedChannelsPath('/helix/moderation/channels'),
        isTrue,
      );
      expect(isTwitchModeratorActionPath('/helix/moderation/chat'), isTrue);
      expect(isTwitchModeratorActionPath('/helix/moderation/bans'), isTrue);
      expect(
        isTwitchModeratorActionPath('/helix/moderation/channels'),
        isFalse,
      );
      expect(isTwitchModeratedChannelsPath('/helix/users'), isFalse);
    });
  });
}
