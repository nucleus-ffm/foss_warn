import 'package:flutter/material.dart';

// original theme
final greenTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSwatch(
    accentColor: Colors.green[700],
    brightness: Brightness.light,
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
    displayMedium: TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
);

// original green theme but dark
final darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSwatch(
    accentColor: Colors.green[700],
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
      displaySmall: TextStyle(fontSize: 14.0, color: Colors.white)),
);

final orangeTheme = ThemeData(
  primarySwatch: Colors.orange,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSwatch(
    accentColor: Colors.orange[700],
    brightness: Brightness.light,
  ),
  textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
      displaySmall: TextStyle(fontSize: 14.0, color: Colors.white)),
);
