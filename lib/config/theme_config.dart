import 'package:flutter/material.dart';

/*----------------------
Theme configurations:
 ----------------------*/
ThemeData theme = ThemeData(
  primaryColor: colorScheme.primary,
  colorScheme: colorScheme,
  scaffoldBackgroundColor: colorScheme.background,
  appBarTheme: appBarTheme,
  buttonTheme: buttonThemeData,
  elevatedButtonTheme: elevatedButtonTheme,
  textButtonTheme: textButtonTheme,
  textTheme: textTheme,
  inputDecorationTheme: inputDecorationTheme,
  iconTheme: iconTheme,
  disabledColor: disabledColor,
  snackBarTheme: snackBarTheme,
  dialogTheme: dialogTheme,
  popupMenuTheme: popUpMenuTheme,
);

/*
 Color scheme for app.
 */
ColorScheme colorScheme = const ColorScheme(
    primary: Color(0xff13293d),
    primaryVariant: Color(0xff006494),
    secondary: Color(0xff1b98e0),
    secondaryVariant: Color(0xffe8f1f2),
    surface: Color(0xffe8f1f2),
    background: Color(0xffe8f1f2),
    error: Color(0xffe01a1a),
    onPrimary: Color(0xffe8f1f2),
    onSecondary: Color(0xffe8f1f2),
    onSurface: Color(0xff13293d),
    onBackground: Color(0xff13293d),
    onError: Color(0xfff2e8e8),
    brightness: Brightness.dark);

// Some extra colors
const Color disabledColor = Color(0xff76acb2);
const Color white = Color(0xffffffff);

AppBarTheme appBarTheme = AppBarTheme(
  color: colorScheme.primary,
  titleTextStyle: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
);

ButtonThemeData buttonThemeData =
    ButtonThemeData(buttonColor: colorScheme.secondary, disabledColor: const Color(0xff76acb2));

ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
      primary: colorScheme.secondary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      textStyle: TextStyle(
        color: colorScheme.onSecondary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      )),
);

// Style for disabled elevated button.
// Is not in material theme so needs to be called explicitly in code.
ButtonStyle disabledElevatedButtonStyle = ElevatedButton.styleFrom(
  primary: const Color(0xff76acb2),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  textStyle: TextStyle(
    color: colorScheme.onSecondary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
);

DialogTheme dialogTheme = DialogTheme(
  backgroundColor: colorScheme.primary,
  contentTextStyle: textTheme.headline6,
  alignment: Alignment.center
);

TextButtonThemeData textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    primary: colorScheme.secondary,
  ),
);

InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: const Color(0xffffffff),
  hintStyle: TextStyle(color: colorScheme.onSurface),
  border: const OutlineInputBorder(
    borderSide: BorderSide(
      width: 2,
      style: BorderStyle.none,
    ),
  ),
);

TextTheme textTheme = TextTheme(
  headline1: TextStyle(color: colorScheme.onPrimary),
  headline2: TextStyle(color: colorScheme.primary),
  headline3: TextStyle(color: colorScheme.primary),
  headline4: TextStyle(color: colorScheme.primary),
  headline5: TextStyle(color: colorScheme.primary),
  headline6: TextStyle(color: colorScheme.onPrimary),
  subtitle1: TextStyle(color: colorScheme.primary),
  subtitle2: TextStyle(color: colorScheme.primary),
  bodyText1: TextStyle(color: colorScheme.primary, fontSize: 25, fontWeight: FontWeight.normal),
  bodyText2: TextStyle(color: colorScheme.primary, fontSize: 20),
  caption: TextStyle(color: colorScheme.primary),
  button: TextStyle(color: colorScheme.onPrimary),
  overline: TextStyle(color: colorScheme.primary),
);

TextStyle textStyle = const TextStyle(
  inherit: true,
  fontSize: 20.0,
);

IconThemeData iconTheme = IconThemeData(
  color: colorScheme.primary,
  size: 30,
);

SnackBarThemeData snackBarTheme = SnackBarThemeData(
  backgroundColor: disabledColor,
  contentTextStyle: textTheme.bodyText2,
);

PopupMenuThemeData popUpMenuTheme = PopupMenuThemeData(
  textStyle: TextStyle(color: colorScheme.primary, fontSize: 24.0),
  color: colorScheme.surface,
  elevation: 10.0
);
