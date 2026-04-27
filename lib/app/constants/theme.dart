import 'package:flutter/material.dart';
import 'package:incauca_labs/app/constants/colors.dart';

final ThemeData lightTheme = ThemeData(
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.background,
    onPrimary: Colors.white,
    onSecondary: AppColors.dark,
    onSurface: AppColors.dark,
    error: Colors.red,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.background,
    contentTextStyle: TextStyle(color: AppColors.dark),
  ),
);

final ThemeData darkTheme = ThemeData(
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.dark,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    error: Colors.red.shade200,
    onError: Colors.black,
  ),
  scaffoldBackgroundColor: AppColors.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.dark,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
);