import 'package:flutter/material.dart';

// original theme
final greenLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: Colors.green,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

final orangeLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: Colors.orange,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

final purpleLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: Colors.purple,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

final blueLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: Colors.blue[500],
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

final yellowLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: Colors.yellow,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

final indigoLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorSchemeSeed: Colors.indigo,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

// ---------- dark theme ------------//

// original green theme but dark
final greenDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.green[900],
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(size: 24 * 1.5, color: Colors.white),
);

// original green theme but dark
final orangeDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.orange[900],
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

final purpleDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.purple[900],
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

final yellowDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.yellow,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

final blueDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.blue,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);

final greyDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.grey,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 14.0, color: Colors.grey),
    displaySmall: TextStyle(fontSize: 14.0, color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    size: 24 * 1.5,
  ),
);
