import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/constant/app_color.dart';



class AppTheme {
  AppTheme._();

  /// 🌞 Light Theme
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,

      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primary,

      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.red,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.switchThumbOn
              : AppColors.switchThumbOff,
        ),
        trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.switchOn
              : AppColors.switchOff,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.sliderActive,
        inactiveTrackColor: AppColors.sliderInactiveLight,
        thumbColor: AppColors.primary,
      ),

      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
      ),
    );
  }

  /// 🌙 Dark Theme
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primary,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.red,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
              ? AppColors.switchOn
              : AppColors.switchOff,
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.sliderActive,
        inactiveTrackColor: AppColors.sliderInactiveDark,
        thumbColor: AppColors.primary,
      ),

      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
      ),
    );
  }
}
