import 'dart:io';

import 'package:flutter/material.dart';

class FrostyThemes {
  static const purple = Color(0xff9146ff);

  ThemeData createBaseTheme({
    required Brightness brightness,
    required Color colorSchemeSeed,
    Color? backgroundColor,
  }) {
    final isDark = brightness == Brightness.dark;

    final secondaryBackgroundColor = isDark
        ? const Color.fromRGBO(18, 18, 18, 1)
        : const Color.fromRGBO(238, 238, 238, 1);

    final hintColor = isDark ? Colors.grey.shade600 : Colors.grey.shade600;

    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;

    const borderWidth = 0.25;

    return ThemeData(
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
        shape: Border(
          bottom: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        filled: true,
        fillColor: secondaryBackgroundColor,
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
        hintStyle: TextStyle(
          color: hintColor,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: backgroundColor,
        height: 64,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      tabBarTheme: const TabBarTheme(
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
      ),
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        textStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
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
      listTileTheme: ListTileThemeData(
        subtitleTextStyle: TextStyle(
          color: hintColor,
          fontSize: 14,
        ),
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
      colorSchemeSeed: purple,
      backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
    );

    return theme;
  }

  ThemeData get dark {
    final theme = createBaseTheme(
      brightness: Brightness.dark,
      colorSchemeSeed: purple,
      backgroundColor: Colors.black,
    );

    return theme;
  }
}
