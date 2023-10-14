import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FrostyThemes {
  static const gray = Color.fromRGBO(18, 18, 18, 1);
  static const purple = Color(0xff9146ff);

  ThemeData createBaseTheme({
    required Brightness brightness,
    required Color colorSchemeSeed,
    Color? backgroundColor,
  }) {
    final baseTheme = ThemeData(
      useMaterial3: true,

      brightness: brightness,
      colorSchemeSeed: colorSchemeSeed,
      splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
      scaffoldBackgroundColor: backgroundColor,
      // canvasColor: backgroundColor,
      bottomSheetTheme: const BottomSheetThemeData(showDragHandle: true),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(style: BorderStyle.none),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(style: BorderStyle.none),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(style: BorderStyle.none),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      tabBarTheme: const TabBarTheme(
        dividerColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: const Border(),
        ),
        textStyle: const TextStyle(color: Colors.white),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      textTheme: textTheme,
    );
  }

  ThemeData get light {
    final theme = createBaseTheme(
      brightness: Brightness.light,
      colorSchemeSeed: purple,
      backgroundColor: Colors.white,
    );

    return theme;
  }

  ThemeData get dark {
    final theme = createBaseTheme(
      brightness: Brightness.dark,
      colorSchemeSeed: purple,
      backgroundColor: gray,
    );

    return theme;
  }

  ThemeData get black {
    final theme = createBaseTheme(
      brightness: Brightness.dark,
      colorSchemeSeed: purple,
      backgroundColor: Colors.black,
    );

    return theme;
  }
}
