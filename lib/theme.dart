import 'dart:io';

import 'package:flutter/material.dart';

class FrostyThemes {
  final Color colorSchemeSeed;

  const FrostyThemes({required this.colorSchemeSeed});

  ThemeData createBaseTheme({
    required Brightness brightness,
    required Color colorSchemeSeed,
    Color? backgroundColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colorSchemeSeed,
      brightness: brightness,
    );

    final borderColor = colorScheme.outlineVariant;

    const borderWidth = 0.5;

    return ThemeData(
      fontFamily: 'Inter',
      brightness: brightness,
      colorScheme: colorScheme,
      splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
      scaffoldBackgroundColor: backgroundColor,
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        shape: Border(
          bottom: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: backgroundColor,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        textStyle: TextStyle(
          color: colorScheme.onSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        showCloseIcon: true,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        thickness: borderWidth,
        space: borderWidth,
        color: borderColor,
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
      colorSchemeSeed: colorSchemeSeed,
      backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
    );

    return theme;
  }

  ThemeData get dark {
    final theme = createBaseTheme(
      brightness: Brightness.dark,
      colorSchemeSeed: colorSchemeSeed,
      backgroundColor: Colors.black,
    );

    return theme;
  }
}
