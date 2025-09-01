import 'dart:io';

import 'package:flutter/material.dart';

class FrostyThemes {
  final Color colorSchemeSeed;

  const FrostyThemes({required this.colorSchemeSeed});

  ThemeData get light => createBaseTheme(
        colorScheme: ColorScheme.fromSeed(seedColor: colorSchemeSeed),
        backgroundColor: const Color.fromRGBO(248, 248, 248, 1),
      );

  ThemeData get dark => createBaseTheme(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorSchemeSeed,
          brightness: Brightness.dark,
        ),
        backgroundColor: Colors.black,
      );

  ThemeData createBaseTheme({
    required ColorScheme colorScheme,
    Color? backgroundColor,
  }) {
    final borderColor = colorScheme.outlineVariant;

    const borderWidth = 0.25;

    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: 'Inter',
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
        titleSpacing: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        filled: true,
        fillColor: colorScheme.surfaceContainer.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: backgroundColor,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        indicatorColor: Colors.transparent,
        indicatorShape: const CircleBorder(),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
      ),
      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.all(8),
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
      textTheme: TextTheme(
        // Alert dialog title
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),

        // App bar title
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),

        // Section titles
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),

        // Tab bar title
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),

        // Labels
        labelLarge: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),

        // Body text
        bodyLarge: TextStyle(letterSpacing: 0),
        bodyMedium: TextStyle(letterSpacing: 0),
        bodySmall: TextStyle(letterSpacing: 0),
      ),
    );
  }
}
