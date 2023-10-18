import 'dart:io';

import 'package:flutter/material.dart';

class FrostyThemes {
  static const gray = Color.fromRGBO(18, 18, 18, 1);
  static const purple = Color(0xff9146ff);

  ThemeData createBaseTheme({
    required Brightness brightness,
    required Color colorSchemeSeed,
    Color? backgroundColor,
  }) {
    final secondaryBackground = brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade900;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: brightness,
      colorSchemeSeed: colorSchemeSeed,
      splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
      scaffoldBackgroundColor: backgroundColor,
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(style: BorderStyle.none),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(style: BorderStyle.none),
        ),
        disabledBorder: const OutlineInputBorder(
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
        tabAlignment: TabAlignment.start,
      ),
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: secondaryBackground),
        ),
        textStyle: TextStyle(
          color: brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        showCloseIcon: true,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: secondaryBackground),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        space: 0.5,
      ),
      textTheme: const TextTheme(
        // Used in alert dialog title.
        headlineSmall: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        // Used in app bar title.
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(letterSpacing: 0),
        // Used in tab bar title.
        titleSmall: TextStyle(
          fontSize: 16,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          letterSpacing: 0,
        ),
        labelMedium: TextStyle(
          letterSpacing: 0,
        ),
        labelSmall: TextStyle(
          letterSpacing: 0,
        ),
        // Used in list tile title.
        bodyLarge: TextStyle(
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          letterSpacing: 0,
        ),
      ),
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
