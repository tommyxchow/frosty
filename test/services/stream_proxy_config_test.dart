import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/services/stream_proxy_config.dart';

void main() {
  group('StreamProxyConfig', () {
    test('toMethodChannelPayload serializes settings for Android bridge', () {
      final config = StreamProxyConfig(
        mode: StreamProxyMode.ttvLolPro,
        currentChannelLogin: 'Streamer',
        proxyUrls: const [
          'proxy.example.com:3128',
          'https://user:pass@proxy.example.com:443',
        ],
        whitelistedChannels: const ['Whitelisted_Channel'],
        debugLogging: false,
      );

      expect(config.toMethodChannelPayload(), {
        'mode': 'ttvLolPro',
        'currentChannelLogin': 'streamer',
        'proxyUrls': [
          'proxy.example.com:3128',
          'https://user:pass@proxy.example.com:443',
        ],
        'whitelistedChannels': ['whitelisted_channel'],
        'debugLogging': false,
      });
    });
  });

  group('stream proxy validators', () {
    test('accepts supported HTTP and HTTPS proxy URL formats', () {
      expect(validateStreamProxyUrl('proxy.example.com:3128'), isNull);
      expect(validateStreamProxyUrl('http://proxy.example.com:8080'), isNull);
      expect(
        validateStreamProxyUrl('https://user:pass@proxy.example.com:443'),
        isNull,
      );
    });

    test('rejects unsupported or incomplete proxy URL formats', () {
      expect(validateStreamProxyUrl(''), isNotNull);
      expect(
        validateStreamProxyUrl('socks://proxy.example.com:1080'),
        isNotNull,
      );
      expect(validateStreamProxyUrl('https://proxy.example.com'), isNotNull);
      expect(validateStreamProxyUrl('example.com:notaport'), isNotNull);
    });

    test('accepts valid channel whitelist entries', () {
      expect(validateStreamProxyChannelLogin('streamer_name123'), isNull);
    });

    test('rejects invalid channel whitelist entries', () {
      expect(validateStreamProxyChannelLogin('streamer name'), isNotNull);
      expect(validateStreamProxyChannelLogin('streamer/name'), isNotNull);
    });
  });
}
