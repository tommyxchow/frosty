import "dart:convert";
import "package:flutter_test/flutter_test.dart";
import "package:frosty/models/emotes.dart";

void main() {
  group("Twitch", () {
    test("emote should parse correctly", () {
      const sampleJson = """
        {
          "id": "304456832",
          "name": "twitchdevPitchfork",
          "images": {
            "url_1x": "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/light/1.0",
            "url_2x": "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/light/2.0",
            "url_4x": "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/light/3.0"
          },
          "tier": "1000",
          "emote_type": "subscriptions",
          "emote_set_id": "301590448",
          "format": [
            "static"
          ],
          "scale": [
            "1.0",
            "2.0",
            "3.0"
          ],
          "theme_mode": [
            "light",
            "dark"
          ]
        }
      """;

      final decoded = jsonDecode(sampleJson);
      final emote = EmoteTwitch.fromJson(decoded);

      expect(emote.id, "304456832");
      expect(emote.name, "twitchdevPitchfork");
      expect(emote.images.url1x, "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/light/1.0");
      expect(emote.images.url2x, "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/light/2.0");
      expect(emote.images.url4x, "https://static-cdn.jtvnw.net/emoticons/v2/304456832/static/light/3.0");
      expect(emote.tier, "1000");
      expect(emote.emoteType, "subscriptions");
      expect(emote.emoteSetId, "301590448");
      expect(emote.format, ["static"]);
      expect(emote.scale, ["1.0", "2.0", "3.0"]);
      expect(emote.themeMode, ["light", "dark"]);
    });
  });

  group("BTTV", () {
    test("emote should parse correctly", () {
      const emoteTrollFace = """
        {
          "id":"54fa8f1401e468494b85b537",
          "code":":tf:",
          "imageType":"png",
          "userId":"5561169bd6b9d206222a8c19"
        }
      """;

      final json = jsonDecode(emoteTrollFace);
      final emote = EmoteBTTVGlobal.fromJson(json);

      expect(emote.id, "54fa8f1401e468494b85b537");
      expect(emote.code, ":tf:");
      expect(emote.imageType, "png");
      expect(emote.userId, "5561169bd6b9d206222a8c19");
    });

    test("shared emote should parse correctly", () {
      const emoteEZ = """
        {
          "id": "5590b223b344e2c42a9e28e3",
          "code": "EZ",
          "imageType": "png",
          "user": {
            "id": "558f7862b344e2c42a9e2822",
            "name": "helloboat",
            "displayName": "helloboat",
            "providerId": "39819556"
          }
        }
      """;

      final decoded = jsonDecode(emoteEZ);
      final emote = EmoteBTTVShared.fromJson(decoded);

      expect(emote.id, "5590b223b344e2c42a9e28e3");
      expect(emote.code, "EZ");
      expect(emote.imageType, "png");
      expect(emote.user.id, "558f7862b344e2c42a9e2822");
      expect(emote.user.name, "helloboat");
      expect(emote.user.displayName, "helloboat");
      expect(emote.user.providerId, "39819556");
    });

    test("global emotes should parse correctly", () {
      const sampleJson = """
        [
          {"id":"54fa903b01e468494b85b53f","code":"DatSauce","imageType":"png","userId":"5561169bd6b9d206222a8c19"},
          {"id":"54fa909b01e468494b85b542","code":"ForeverAlone","imageType":"png","userId":"5561169bd6b9d206222a8c19"},
          {"id":"54fa90ba01e468494b85b543","code":"GabeN","imageType":"png","userId":"5561169bd6b9d206222a8c19"},
          {"id":"54fa90f201e468494b85b545","code":"HailHelix","imageType":"png","userId":"5561169bd6b9d206222a8c19"}
        ]
      """;

      final decoded = jsonDecode(sampleJson) as List;
      final List<EmoteBTTVGlobal> emotes = decoded.map((emote) => EmoteBTTVGlobal.fromJson(emote)).toList();
      expect(emotes.length, 4);

      final emoteIds = ["54fa903b01e468494b85b53f", "54fa909b01e468494b85b542", "54fa90ba01e468494b85b543", "54fa90f201e468494b85b545"];
      final emoteCodes = ["DatSauce", "ForeverAlone", "GabeN", "HailHelix"];
      final userIds = ["5561169bd6b9d206222a8c19", "5561169bd6b9d206222a8c19", "5561169bd6b9d206222a8c19", "5561169bd6b9d206222a8c19"];

      emotes.asMap().forEach((index, emote) {
        expect(emote.id, emoteIds[index]);
        expect(emote.code, emoteCodes[index]);
        expect(emote.imageType, "png");
        expect(emote.userId, userIds[index]);
      });
    });

    test("channel emotes should parse correctly", () {
      const sampleJson = """
        {"id":"5509bd19a607044d1a3dd1bb",
          "bots":[
            "emotestats",
            "hnlbot"
          ],
          "channelEmotes":[
            {
              "id":"5509bd3ba607044d1a3dd1bc",
              "code":"sodaTP",
              "imageType":"png",
              "userId":"5509bd19a607044d1a3dd1bb"
            }
          ],
          "sharedEmotes":[
            {
              "id": "5ed3bde8f54be95e2a838279",
              "code": "pugPls",
              "imageType": "gif",
              "user": {
                "id": "5c5510a1c0a5642a696190d9",
                "name": "wolfabelle",
                "displayName": "Wolfabelle",
                "providerId": "190146087"
              }
            }
          ]
        }
      """;

      final decoded = jsonDecode(sampleJson);
      final result = EmoteBTTVChannel.fromJson(decoded);

      expect(result.id, "5509bd19a607044d1a3dd1bb");
      expect(result.bots, ["emotestats", "hnlbot"]);

      final channelEmote = result.channelEmotes.first;

      expect(channelEmote.id, "5509bd3ba607044d1a3dd1bc");
      expect(channelEmote.code, "sodaTP");
      expect(channelEmote.imageType, "png");
      expect(channelEmote.userId, "5509bd19a607044d1a3dd1bb");

      final sharedEmote = result.sharedEmotes.first;

      expect(sharedEmote.id, "5ed3bde8f54be95e2a838279");
      expect(sharedEmote.code, "pugPls");
      expect(sharedEmote.imageType, "gif");
      expect(sharedEmote.user.id, "5c5510a1c0a5642a696190d9");
      expect(sharedEmote.user.name, "wolfabelle");
      expect(sharedEmote.user.displayName, "Wolfabelle");
      expect(sharedEmote.user.providerId, "190146087");
    });
  });

  group("FFZ", () {
    test("emote should parse correctly", () {
      const sampleJson = """
        {
          "id": 317897,
          "user": {
            "id": 84534,
            "name": "vulpeshd",
            "displayName": "VulpesHD"
          },
          "code": "peepoPog",
          "images": {
            "1x": "https://cdn.betterttv.net/frankerfacez_emote/317897/1",
            "2x": "https://cdn.betterttv.net/frankerfacez_emote/317897/2",
            "4x": null
          },
          "imageType": "png"
        }
      """;

      final json = jsonDecode(sampleJson);
      final emote = EmoteFFZ.fromJson(json);

      expect(emote.id, 317897);
      expect(emote.user.id, 84534);
      expect(emote.user.name, "vulpeshd");
      expect(emote.user.displayName, "VulpesHD");
      expect(emote.code, "peepoPog");
      expect(emote.images.url1x, "https://cdn.betterttv.net/frankerfacez_emote/317897/1");
      expect(emote.images.url2x, "https://cdn.betterttv.net/frankerfacez_emote/317897/2");
      expect(emote.images.url4x, null);
      expect(emote.imageType, "png");
    });
  });

  group("7TV", () {
    test("global emote should parse correctly", () {
      const sampleGlobal7TVEmote = """
        {
          "id": "603ca884faf3a00014dff0ab",
          "name": "gachiBASS",
          "owner": null,
          "visibility": 2,
          "visibility_simple": [
            "GLOBAL"
          ],
          "mime": "image/gif",
          "status": 3,
          "tags": [
            
          ],
          "width": [
            32,
            48,
            76,
            128
          ],
          "height": [
            32,
            48,
            76,
            128
          ],
          "urls": [
            [
              "1",
              "https://cdn.7tv.app/emote/603ca884faf3a00014dff0ab/1x"
            ],
            [
              "2",
              "https://cdn.7tv.app/emote/603ca884faf3a00014dff0ab/2x"
            ],
            [
              "3",
              "https://cdn.7tv.app/emote/603ca884faf3a00014dff0ab/3x"
            ],
            [
              "4",
              "https://cdn.7tv.app/emote/603ca884faf3a00014dff0ab/4x"
            ]
          ]
        }
      """;

      final json = jsonDecode(sampleGlobal7TVEmote);
      final emote = Emote7TV.fromJson(json);

      expect(emote.id, "603ca884faf3a00014dff0ab");
      expect(emote.name, "gachiBASS");
      expect(emote.owner, null);
      expect(emote.visibility, 2);
      expect(emote.visibilitySimple, ["GLOBAL"]);
      expect(emote.mime, "image/gif");
      expect(emote.status, 3);
      expect(emote.tags, []);
      expect(emote.width, [32, 48, 76, 128]);
      expect(emote.height, [32, 48, 76, 128]);

      final urls = [
        ["1", "https://cdn.7tv.app/emote/603ca884faf3a00014dff0ab/1x"],
        ["2", "https://cdn.7tv.app/emote/603ca884faf3a00014dff0ab/2x"],
        ["3", "https://cdn.7tv.app/emote/603ca884faf3a00014dff0ab/3x"],
        ["4", "https://cdn.7tv.app/emote/603ca884faf3a00014dff0ab/4x"],
      ];

      expect(emote.urls, urls);
    });

    test("channel emote should parse correctly", () {
      const sampleEmote = """
        {
          "id": "603caea243b9e100141caf4f",
          "name": "TrollDespair",
          "owner": {
            "id": "603cae2496832ffa78c758cd",
            "twitch_id": "",
            "login": "swyfty_",
            "display_name": "swyfty_",
            "role": {
              "id": "000000000000000000000000",
              "name": "",
              "position": 0,
              "color": 0,
              "allowed": 523,
              "denied": 0,
              "default": true
            }
          },
          "visibility": 0,
          "visibility_simple": [
            
          ],
          "mime": "image/png",
          "status": 3,
          "tags": [
            
          ],
          "width": [
            32,
            48,
            76,
            128
          ],
          "height": [
            32,
            48,
            76,
            128
          ],
          "urls": [
            [
              "1",
              "https://cdn.7tv.app/emote/603caea243b9e100141caf4f/1x"
            ],
            [
              "2",
              "https://cdn.7tv.app/emote/603caea243b9e100141caf4f/2x"
            ],
            [
              "3",
              "https://cdn.7tv.app/emote/603caea243b9e100141caf4f/3x"
            ],
            [
              "4",
              "https://cdn.7tv.app/emote/603caea243b9e100141caf4f/4x"
            ]
          ]
        }
      """;

      final json = jsonDecode(sampleEmote);
      final emote = Emote7TV.fromJson(json);

      expect(emote.id, "603caea243b9e100141caf4f");
      expect(emote.name, "TrollDespair");

      expect(emote.owner, isNotNull);
      expect(emote.owner?.id, "603cae2496832ffa78c758cd");
      expect(emote.owner?.twitchId, "");
      expect(emote.owner?.login, "swyfty_");
      expect(emote.owner?.displayName, "swyfty_");
      expect(emote.owner?.role.id, "000000000000000000000000");
      expect(emote.owner?.role.name, "");
      expect(emote.owner?.role.position, 0);
      expect(emote.owner?.role.color, 0);
      expect(emote.owner?.role.allowed, 523);
      expect(emote.owner?.role.denied, 0);
      expect(emote.owner?.role.defaults, true);

      expect(emote.visibility, 0);
      expect(emote.visibilitySimple, []);
      expect(emote.mime, "image/png");
      expect(emote.status, 3);
      expect(emote.tags, []);
      expect(emote.width, [32, 48, 76, 128]);
      expect(emote.height, [32, 48, 76, 128]);

      final urls = [
        ["1", "https://cdn.7tv.app/emote/603caea243b9e100141caf4f/1x"],
        ["2", "https://cdn.7tv.app/emote/603caea243b9e100141caf4f/2x"],
        ["3", "https://cdn.7tv.app/emote/603caea243b9e100141caf4f/3x"],
        ["4", "https://cdn.7tv.app/emote/603caea243b9e100141caf4f/4x"],
      ];

      expect(emote.urls, urls);
    });
  });
}
