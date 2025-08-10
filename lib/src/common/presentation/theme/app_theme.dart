import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_journal/src/common/common.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: false,
  fontFamily: GoogleFonts.raleway().fontFamily,
  primaryColor: lightPrimary,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: lightAccent,
    primary: lightPrimary,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: lightBG,
  appBarTheme: AppBarTheme(
    backgroundColor: lightBG,
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: GoogleFonts.raleway().fontFamily,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
  ),
  cardColor: lightCardColor,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: lightBG,
  ),
  tabBarTheme: TabBarTheme(
    indicatorColor: lightAccent,
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.all(darkAccent),
    overlayColor: WidgetStateProperty.all(darkAccent),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: false,
  fontFamily: GoogleFonts.raleway().fontFamily,
  brightness: Brightness.dark,
  primaryColor: darkPrimary,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: darkAccent,
    primary: darkPrimary,
    brightness: Brightness.dark,
  ),
  cardColor: darkCardColor,
  scaffoldBackgroundColor: darkBG,
  appBarTheme: AppBarTheme(
    backgroundColor: darkBG,
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: GoogleFonts.raleway().fontFamily,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: darkBG,
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: darkBG,
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.all(darkAccent),
    overlayColor: WidgetStateProperty.all(darkAccent),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
  ),
);
