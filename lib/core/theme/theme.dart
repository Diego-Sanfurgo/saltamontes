import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: lightColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.surface,
      foregroundColor: lightColorScheme.onSurface,
    ),
    searchBarTheme: _searchBarThemeData,
    elevatedButtonTheme: _elevatedBtnThemeDataLight,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
      foregroundColor: darkColorScheme.onSurface,
    ),
    searchBarTheme: _searchBarThemeData,
    elevatedButtonTheme: _elevatedBtnThemeDataDark,
  );
}

SearchBarThemeData _searchBarThemeData = SearchBarThemeData(
  elevation: const WidgetStatePropertyAll(0),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      side: const BorderSide(color: Colors.green),
    ),
  ),
  backgroundColor: const WidgetStatePropertyAll(Colors.white),
  hintStyle: WidgetStatePropertyAll(TextStyle(color: Colors.grey[600])),
);

ElevatedButtonThemeData _elevatedBtnThemeDataDark = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.darkPrimaryColor,
    foregroundColor: AppColors.darkPrimaryFgColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    fixedSize: Size(double.infinity, 56),
  ),
);

ElevatedButtonThemeData _elevatedBtnThemeDataLight = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.lightPrimaryColor,
    foregroundColor: AppColors.lightPrimaryFgColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    fixedSize: Size(double.infinity, 56),
  ),
);
