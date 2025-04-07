import 'package:flutter/material.dart';
import 'package:storyapp/style/app_colors.dart';
import 'package:storyapp/style/app_text_style.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorSchemeSeed: AppColors.green.color,
      brightness: Brightness.light,
      textTheme: _textTheme,
      useMaterial3: true,
      appBarTheme: _appBarTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorSchemeSeed: AppColors.green.color,
      brightness: Brightness.dark,
      textTheme: _textTheme,
      useMaterial3: true,
      appBarTheme: _appBarTheme,
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppTextStyle.displayLarge,
      displayMedium: AppTextStyle.displayMedium,
      displaySmall: AppTextStyle.displaySmall,
      headlineLarge: AppTextStyle.headlineLarge,
      headlineMedium: AppTextStyle.headlineMedium,
      headlineSmall: AppTextStyle.headlineSmall,
      titleLarge: AppTextStyle.titleLarge,
      titleMedium: AppTextStyle.titleMedium,
      titleSmall: AppTextStyle.titleSmall,
      bodyLarge: AppTextStyle.bodyLargeBold,
      bodyMedium: AppTextStyle.bodyLargeMedium,
      bodySmall: AppTextStyle.bodyLargeRegular,
      labelLarge: AppTextStyle.labelLarge,
      labelMedium: AppTextStyle.labelMedium,
      labelSmall: AppTextStyle.labelSmall,
    );
  }

  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      toolbarTextStyle: _textTheme.titleLarge,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16))),
    );
  }
}
