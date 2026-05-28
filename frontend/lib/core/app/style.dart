import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../assets/colors/Colors.dart';

final lightTheme = _getTheme();
final titleThemeStyle = _getTitleTheme();

const _primary = ColorConstants.kPrimaryColor;
const _secondary = ColorConstants.kSecondaryColor;
const _border = ColorConstants.kGray4;

const _background = Colors.white;
const _lightest = Colors.white;
const _darkest = ColorConstants.kGray1;
const _divider = ColorConstants.kGray5;
const _disabled = Colors.grey;

const _red = Colors.red;

final _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  // Primary
  primary: _primary,
  onPrimary: _lightest,
  primaryContainer: _primary.withOpacity(0.2),
  onPrimaryContainer: _lightest,
  // Secondary
  secondary: _secondary,
  onSecondary: _darkest,
  secondaryContainer: _secondary.withOpacity(0.2),
  onSecondaryContainer: _darkest,
  // Error
  error: _red,
  onError: _lightest,
  // Background
  background: _background,
  onBackground: _darkest,
  // Surface
  surface: _lightest,
  onSurface: _darkest,
  // Outline
  outline: _divider,
);

ThemeData _getTheme() {
  final colorScheme = _lightColorScheme;
  final monteserratTextTheme = _getMonteserratTextTheme(colorScheme);
  var nunitoTextTheme = getNunitoTextTheme(colorScheme);
  final primaryTextTheme = monteserratTextTheme;

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(71),
  );
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 18,
  );

  var buttonTextStyle = primaryTextTheme.displaySmall;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: monteserratTextTheme,
    primaryTextTheme: primaryTextTheme,
    scaffoldBackgroundColor: colorScheme.background,
    disabledColor: _disabled,
    dividerTheme: const DividerThemeData(
      color: _divider,
      space: 1,
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      labelStyle: monteserratTextTheme.labelSmall,
      side: const BorderSide(
        width: 0,
      ),
    ),
    cardTheme: const CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        side: BorderSide(
          width: 1,
          color: _divider,
        ),
      ),
      color: _background,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _background,
      surfaceTintColor: colorScheme.background,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      labelType: NavigationRailLabelType.all,
      groupAlignment: 0,
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: monteserratTextTheme.bodyLarge,
      backgroundColor: _secondary,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.background,
      surfaceTintColor: colorScheme.background,
      titleTextStyle: monteserratTextTheme.titleLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _darkest,
      contentTextStyle: primaryTextTheme.displaySmall,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colorScheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),
      border: const OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border),
        borderRadius: BorderRadius.all(Radius.circular(71)),
      ),
      enabledBorder: const OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border),
        borderRadius: BorderRadius.all(Radius.circular(71)),
      ),
      focusedBorder: const OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border),
        borderRadius: BorderRadius.all(Radius.circular(71)),
      ),
      hintStyle: monteserratTextTheme.bodySmall,
      labelStyle: monteserratTextTheme.bodySmall!.copyWith(
        color: Colors.black38,
        fontWeight: FontWeight.normal,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: Colors.white,
      iconSize: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: buttonTextStyle,
        elevation: 1,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        side: BorderSide(
          color: colorScheme.primary,
          width: 1,
        ),
        foregroundColor: colorScheme.primary,
        textStyle: buttonTextStyle,
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        foregroundColor: colorScheme.primary,
        textStyle: buttonTextStyle,
      ),
    ),
  );
}

ThemeData _getTitleTheme() {
  final colorScheme = _lightColorScheme;
  var nunitoTextTheme = getNunitoTextTheme(colorScheme);
  final primaryTextTheme = nunitoTextTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: nunitoTextTheme,
    primaryTextTheme: primaryTextTheme,
  );
}

const minFontSize = 12.0;

TextTheme getNunitoTextTheme(ColorScheme colorScheme) {
  const color = ColorConstants.kGray2;
  const headingWeight = FontWeight.w700;

  const textTheme = TextTheme(
    // Headline
    headlineLarge: TextStyle(
      fontSize: minFontSize * 3.57, //50,
      color: color,
      fontWeight: headingWeight,
    ),
    headlineMedium: TextStyle(
      fontSize: minFontSize * 3.21, //45,
      color: color,
      fontWeight: headingWeight,
    ),
    headlineSmall: TextStyle(
      fontSize: minFontSize * 2.857, //40,
      color: color,
      fontWeight: headingWeight,
    ),

    // Title
    titleLarge: TextStyle(
      fontSize: minFontSize * 2.285, //32,
      color: color,
      fontWeight: headingWeight,
    ),
    titleMedium: TextStyle(
      fontSize: minFontSize * 1.71, //24,
      color: color,
      fontWeight: headingWeight,
    ),
    titleSmall: TextStyle(
      fontSize: minFontSize * 1.43, //20,
      color: color,
      fontWeight: FontWeight.w600,
    ),
  );
  return GoogleFonts.nunitoTextTheme(textTheme);
}

TextTheme _getMonteserratTextTheme(ColorScheme colorScheme) {
  const color = ColorConstants.kGray1;
  const bodyWeight = FontWeight.w400;

  const textTheme = TextTheme(
    // Display
    displayLarge: TextStyle(
      fontSize: minFontSize * 1.43, //20,
      color: color,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      fontSize: minFontSize * 1.285, //18,
      color: color,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: TextStyle(
      fontSize: minFontSize * 1.15, //16,
      color: color,
      fontWeight: FontWeight.w600,
    ),

    // Body
    bodyLarge: TextStyle(
      fontSize: minFontSize * 1.43, //20,
      color: color,
      fontWeight: bodyWeight,
    ),
    bodyMedium: TextStyle(
      fontSize: minFontSize * 1.285, //18,
      color: color,
      fontWeight: bodyWeight,
    ),
    bodySmall: TextStyle(
      fontSize: minFontSize * 1.15, //16
      color: color,
      fontWeight: bodyWeight,
    ),

    // Label
    labelLarge: TextStyle(
      fontSize: minFontSize, //14
      color: color,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      fontSize: minFontSize, //14
      color: color,
      fontWeight: bodyWeight,
    ),
  );

  return GoogleFonts.nunitoTextTheme(textTheme);
}
