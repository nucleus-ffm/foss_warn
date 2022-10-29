import 'package:flutter/material.dart';

// original theme
final greenTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSwatch(
    accentColor: Colors.green[700],
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    headline1: TextStyle(
        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
    headline2: TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    bodyText1: TextStyle(fontSize: 14.0, color: Colors.grey),
    headline3: TextStyle(fontSize: 14.0, color: Colors.white),
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
  textTheme: const TextTheme(
      headline1: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      headline2: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      bodyText1: TextStyle(fontSize: 14.0, color: Colors.grey),
      headline3: TextStyle(fontSize: 14.0, color: Colors.white)),
);

final orangeTheme = ThemeData(
  primarySwatch: Colors.orange,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSwatch(
    accentColor: Colors.orange[700],
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
      headline1: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      headline2: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      bodyText1: TextStyle(fontSize: 14.0, color: Colors.grey),
      headline3: TextStyle(fontSize: 14.0, color: Colors.white)),
);
