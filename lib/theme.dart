import 'dart:io';

import 'package:flutter/material.dart';

class FrostyStyles {
  static const gray = Color.fromRGBO(18, 18, 18, 1.0);
  static const purple = Color(0xff9146ff);

  static const inputTheme = InputDecorationTheme(
    filled: true,
    contentPadding: EdgeInsets.all(10.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(style: BorderStyle.none),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(style: BorderStyle.none),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(style: BorderStyle.none),
    ),
  );

  static const tooltipTheme = TooltipThemeData(
    padding: EdgeInsets.all(10.0),
    margin: EdgeInsets.symmetric(horizontal: 5.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
    textStyle: TextStyle(color: Colors.white),
  );

  static const snackBarTheme = SnackBarThemeData(
    contentTextStyle: TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
  );

  static final lightTheme = ThemeData(
    canvasColor: Colors.white,
    splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      elevation: 0.0,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.deepPurple,
      accentColor: purple,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
    ),
    inputDecorationTheme: inputTheme,
    tooltipTheme: tooltipTheme,
    snackBarTheme: snackBarTheme,
  );

  static final darkTheme = ThemeData(
    canvasColor: gray,
    brightness: Brightness.dark,
    splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      color: gray,
      elevation: 0.0,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(backgroundColor: gray),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      accentColor: purple,
    ),
    dialogBackgroundColor: gray,
    inputDecorationTheme: inputTheme,
    tooltipTheme: tooltipTheme,
    snackBarTheme: snackBarTheme,
  );

  static final oledTheme = ThemeData(
    useMaterial3: true,
    canvasColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    splashFactory: Platform.isIOS ? NoSplash.splashFactory : null,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      color: Colors.black,
      elevation: 0.0,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      accentColor: purple,
    ),
    dialogBackgroundColor: Colors.black,
    inputDecorationTheme: inputTheme,
    tooltipTheme: tooltipTheme,
    snackBarTheme: snackBarTheme,
  );
}
