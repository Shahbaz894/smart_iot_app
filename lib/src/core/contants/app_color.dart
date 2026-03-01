import 'package:flutter/material.dart';

/// Centralized color system for the Smart IoT App
/// Supports Light & Dark themes
/// Designed for dashboards & real-time IoT controls
abstract class AppColors {
  // ---------------------------------------------------------------------------
  // BRAND / PRIMARY
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFFB6F000); // Neon green
  static const Color primarySoft = Color(0xFF9EDC00);
  static const Color primaryDark = Color(0xFF7AA800);

  static const Color accent = Color(0xFFFF9800); // Orange (upgrade, alert)

  // ---------------------------------------------------------------------------
  // NEUTRAL COLORS (White / Black / Gray)
  // ---------------------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF2F2F2);

  static const Color black = Color(0xFF000000);

  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // ---------------------------------------------------------------------------
  // BACKGROUND & SURFACE
  // ---------------------------------------------------------------------------
  static const Color backgroundDark = Color(0xFF1E1E1E);
  static const Color backgroundLight = offWhite;

  static const Color surfaceDark = Color(0xFF2A2A2A);
  static const Color surfaceLight = white;

  static const Color cardDark = Color(0xFF2F2F2F);
  static const Color cardLight = white;

  // ---------------------------------------------------------------------------
  // TEXT COLORS
  // ---------------------------------------------------------------------------
  static const Color textPrimaryDark = white;
  static const Color textSecondaryDark = gray400;
  static const Color textDisabledDark = gray600;

  static const Color textPrimaryLight = gray900;
  static const Color textSecondaryLight = gray700;
  static const Color textDisabledLight = gray500;

  // ---------------------------------------------------------------------------
  // ICON COLORS
  // ---------------------------------------------------------------------------
  static const Color iconActive = primary;
  static const Color iconInactiveDark = gray500;
  static const Color iconInactiveLight = gray600;

  // ---------------------------------------------------------------------------
  // BORDER / DIVIDER
  // ---------------------------------------------------------------------------
  static const Color borderDark = gray800;
  static const Color borderLight = gray300;

  static const Color dividerDark = gray700;
  static const Color dividerLight = gray300;

  // ---------------------------------------------------------------------------
  // SWITCH / TOGGLE
  // ---------------------------------------------------------------------------
  //static const Color switchOn = primary;
  static const Color switchOffDark = gray700;
  static const Color switchOffLight = gray400;

  static const Color switchThumbOn = white;
  static const Color switchThumbOffDark = gray300;
  static const Color switchThumbOffLight = white;
  // ---------------------------------------------------------------------------
// SWITCH / TOGGLE
// ---------------------------------------------------------------------------

// Track
  static const Color switchOn = Color(0xFF4CAF50);   // Green (ON)
  static const Color switchOff = Color(0xFFE53935);  // Red (OFF)

// Thumb
  //static const Color switchThumbOn = white;
  static const Color switchThumbOff = white;

// Disabled
  static const Color switchDisabled = gray600;



// SLIDER COLORS
// ---------------------------------------------------------------------------

// Default (Brightness / Level)
  static const Color sliderActive = primary;
  static const Color sliderInactiveDark = gray700;
  static const Color sliderInactiveLight = gray300;

// Power / Intensity
  static const Color sliderPowerActive = green;
  static const Color sliderPowerInactive = gray600;

// Temperature
  static const Color sliderTempCold = blueLight;
  static const Color sliderTempNormal = Color(0xFF00BCD4); // Cyan
  static const Color sliderTempHot = red;

// Audio / Signal
  static const Color sliderSignalLow = yellow;
  static const Color sliderSignalHigh = green;

// Disabled
  static const Color sliderDisabled = gray500;


  // ---------------------------------------------------------------------------
  // SEMANTIC COLORS (Status)
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Yellow
  static const Color error = Color(0xFFF44336);   // Red
  static const Color info = Color(0xFF2196F3);    // Blue

  // ---------------------------------------------------------------------------
  // UTILITY COLORS (Direct usage)
  // ---------------------------------------------------------------------------
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF43A047);
  static const Color yellow = Color(0xFFFDD835);
  static const Color purple = Color(0xFF8E24AA);

  // ---------------------------------------------------------------------------
  // BLUE SHADES (Charts, Gauges, Info)
  // ---------------------------------------------------------------------------
  static const Color blueLight = Color(0xFF64B5F6);
  static const Color blue = Color(0xFF1E88E5);
  static const Color blueDark = Color(0xFF0D47A1);

  // ---------------------------------------------------------------------------
  // STATES
  // ---------------------------------------------------------------------------
  static const Color disabledDark = gray700;
  static const Color disabledLight = gray300;

  static const Color shadowDark = Colors.black54;
  static const Color shadowLight = Colors.black12;
}
