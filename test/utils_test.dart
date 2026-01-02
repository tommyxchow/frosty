import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/utils.dart';

void main() {
  group('getReadableName', () {
    test('returns display name when it equals username', () {
      expect(getReadableName('testuser', 'testuser'), 'testuser');
    });

    test('returns display name when it contains English letters (even if case differs)', () {
      // Display name contains English letters, so it's readable as-is
      // The function doesn't add username because English letters make it readable
      expect(getReadableName('TestUser', 'testuser'), 'TestUser');
    });

    test('returns display name only for numeric-only names', () {
      expect(getReadableName('12345', 'somename'), '12345');
    });

    test('returns display name only when it contains English letters', () {
      expect(getReadableName('TestName123', 'testname123'), 'TestName123');
      expect(getReadableName('User_Name', 'user_name'), 'User_Name');
    });

    test('adds username in parentheses for non-English display names', () {
      // Japanese characters
      expect(getReadableName('テスト', 'testuser'), 'テスト (testuser)');
      // Korean characters
      expect(getReadableName('테스트', 'testuser'), '테스트 (testuser)');
      // Chinese characters
      expect(getReadableName('测试', 'testuser'), '测试 (testuser)');
      // Russian characters
      expect(getReadableName('Тест', 'testuser'), 'Тест (testuser)');
    });

    test('adds username for mixed non-English with numbers', () {
      // Non-English + numbers (no English letters)
      expect(getReadableName('テスト123', 'testuser'), 'テスト123 (testuser)');
    });

    test('returns display name for mixed English and non-English', () {
      // Has English letters, so no parentheses
      expect(getReadableName('TestテストUser', 'testuser'), 'TestテストUser');
    });
  });

  group('adjustChatNameColor', () {
    // Helper to create a testable widget tree with specific theme
    Widget buildTestWidget({
      required Color scaffoldBackground,
      required Widget child,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: ThemeData(
          brightness: brightness,
          scaffoldBackgroundColor: scaffoldBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: brightness,
            surface: scaffoldBackground,
          ),
        ),
        home: Scaffold(body: child),
      );
    }

    testWidgets('brightens dark colors on dark backgrounds', (tester) async {
      late Color adjustedColor;
      const darkBackground = Color(0xFF121212);
      const darkNameColor = Color(0xFF000000); // Pure black

      await tester.pumpWidget(
        buildTestWidget(
          scaffoldBackground: darkBackground,
          child: Builder(
            builder: (context) {
              adjustedColor = adjustChatNameColor(context, darkNameColor);
              return const SizedBox();
            },
          ),
        ),
      );

      // The adjusted color should be lighter than the original
      final originalLuminance = darkNameColor.computeLuminance();
      final adjustedLuminance = adjustedColor.computeLuminance();

      expect(adjustedLuminance, greaterThan(originalLuminance));
    });

    testWidgets('darkens light colors on light backgrounds', (tester) async {
      late Color adjustedColor;
      const lightBackground = Color(0xFFFAFAFA);
      const lightNameColor = Color(0xFFFFFFFF); // Pure white

      await tester.pumpWidget(
        buildTestWidget(
          scaffoldBackground: lightBackground,
          brightness: Brightness.light,
          child: Builder(
            builder: (context) {
              adjustedColor = adjustChatNameColor(context, lightNameColor);
              return const SizedBox();
            },
          ),
        ),
      );

      // The adjusted color should be darker than the original
      final originalLuminance = lightNameColor.computeLuminance();
      final adjustedLuminance = adjustedColor.computeLuminance();

      expect(adjustedLuminance, lessThan(originalLuminance));
    });

    testWidgets('preserves colors that already meet contrast ratio',
        (tester) async {
      late Color adjustedColor;
      const darkBackground = Color(0xFF121212);
      const goodContrastColor = Color(0xFFFFFFFF); // White on dark = good contrast

      await tester.pumpWidget(
        buildTestWidget(
          scaffoldBackground: darkBackground,
          child: Builder(
            builder: (context) {
              adjustedColor = adjustChatNameColor(context, goodContrastColor);
              return const SizedBox();
            },
          ),
        ),
      );

      // Color should be unchanged or very close to original
      expect(adjustedColor, goodContrastColor);
    });

    testWidgets('uses custom target contrast ratio', (tester) async {
      late Color adjusted45;
      late Color adjusted30;
      const darkBackground = Color(0xFF121212);
      const greyColor = Color(0xFF555555);

      await tester.pumpWidget(
        buildTestWidget(
          scaffoldBackground: darkBackground,
          child: Builder(
            builder: (context) {
              adjusted45 = adjustChatNameColor(
                context,
                greyColor,
                targetContrast: 4.5,
              );
              adjusted30 = adjustChatNameColor(
                context,
                greyColor,
                targetContrast: 3.0,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Higher contrast requirement should result in a lighter color
      final lum45 = adjusted45.computeLuminance();
      final lum30 = adjusted30.computeLuminance();

      expect(lum45, greaterThanOrEqualTo(lum30));
    });

    testWidgets('uses custom background color parameter', (tester) async {
      late Color adjustedColor;
      const customBackground = Color(0xFF00FF00); // Green background

      await tester.pumpWidget(
        buildTestWidget(
          scaffoldBackground: Colors.black,
          child: Builder(
            builder: (context) {
              // Pass custom background, ignoring theme
              adjustedColor = adjustChatNameColor(
                context,
                const Color(0xFF00FF00), // Same as background
                background: customBackground,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Color should be adjusted for contrast against green, not black
      // Green on green needs adjustment
      expect(adjustedColor, isNot(const Color(0xFF00FF00)));
    });

    testWidgets('handles transparent scaffold background', (tester) async {
      late Color adjustedColor;
      const darkColor = Color(0xFF000000);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.transparent,
            colorScheme: const ColorScheme.dark(
              surface: Color(0xFF1E1E1E),
            ),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                adjustedColor = adjustChatNameColor(context, darkColor);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Should use colorScheme.surface as fallback
      // Dark color on dark surface should be adjusted
      expect(adjustedColor.computeLuminance(), greaterThan(0.0));
    });

    testWidgets('maintains hue while adjusting lightness', (tester) async {
      late Color adjustedColor;
      const darkBackground = Color(0xFF121212);
      const blueColor = Color(0xFF0000AA); // Dark blue

      await tester.pumpWidget(
        buildTestWidget(
          scaffoldBackground: darkBackground,
          child: Builder(
            builder: (context) {
              adjustedColor = adjustChatNameColor(context, blueColor);
              return const SizedBox();
            },
          ),
        ),
      );

      // Should still be recognizably blue (hue preserved)
      final originalHsl = HSLColor.fromColor(blueColor);
      final adjustedHsl = HSLColor.fromColor(adjustedColor);

      // Hue should be the same or very close
      expect(adjustedHsl.hue, closeTo(originalHsl.hue, 1.0));
    });
  });

  group('Color contrast calculation (indirect tests)', () {
    // These tests verify the contrast behavior indirectly through adjustChatNameColor

    testWidgets('common Twitch colors work on dark background', (tester) async {
      final twitchColors = [
        const Color(0xFFFF0000), // Red
        const Color(0xFF0000FF), // Blue
        const Color(0xFF00FF00), // Green
        const Color(0xFFB22222), // Firebrick
        const Color(0xFFFF69B4), // Hot pink
        const Color(0xFFDAA520), // Golden rod
      ];

      for (final color in twitchColors) {
        late Color adjusted;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF121212),
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  adjusted = adjustChatNameColor(context, color);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );

        // All adjusted colors should have reasonable luminance
        expect(
          adjusted.computeLuminance(),
          greaterThan(0.05),
          reason: 'Color $color should be readable',
        );
      }
    });
  });
}
