import 'package:flutter/material.dart';

// const mainColour = Color(0xFFFB5824);
const mainColour = Color(0xFFD71921);
const LightBGtext = Color(0xFFD7DBE1);
const DarkText = Color(0xFF748297);
ThemeData lightMode = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFF0F2F5),
  brightness: Brightness.light,
  useMaterial3: true,
  //Ntype
  fontFamily: 'Ntype',
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xFF2A2733)),
    ),
  ),
  floatingActionButtonTheme:
      const FloatingActionButtonThemeData(backgroundColor: mainColour,),
  colorScheme: const ColorScheme.light(
    // surface: Color(0xFFEAEDF4),
    primary: Color(0xFF2A2733),
    secondary: Colors.blue,
    inversePrimary: Colors.blue,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  fontFamily: 'Ntype',
  cardColor: const Color.fromARGB(255, 22, 22, 22),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: mainColour,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(
        const Color(0xFF2A2733),
      ),
    ),
  ),
  colorScheme: const ColorScheme.dark(
    surface: Colors.black,
    primary: Color.fromARGB(255, 22, 22, 22),
    secondary: Colors.deepPurpleAccent,
    inversePrimary: Colors.brown,
  ),
);
