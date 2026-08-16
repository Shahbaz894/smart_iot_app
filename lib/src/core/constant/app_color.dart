
import "package:flutter/material.dart";

abstract class AppColors {
  // ---------------------------------------------------------------------------
  // BRAND / PRIMARY
  // // ---------------------------------------------------------------------------
  // static const Color primary = Color(0xFFB6F000); // Neon green
  // static const Color primarySoft = Color(0xFF9EDC00);
  // static const Color primaryDark = Color(0xFF7AA800);
  static const Color primary = colorPrimary;
  static const Color primarySoft = colorPrimaryLight;
  static const Color primaryDark = colorPrimaryDark;

  static const Color accent = Color(0xFFFF9800); // Alerts / upgrade


  //static const Color darkBgSoft = Color(0xFF0F91D0);
  static const Color darkBgSoft = Color(0xFF0B1120);
  static const Color darkSurfaceSoft = Color(0xFF111827);
  static const Color darkCardSoft = Color(0xFF172033);
  static const Color darkBorderSoft = Color(0xFF263244);
  static const Color textMutedSoft = Color(0xFF94A3B8);
  static const Color mintAccent = Color(0xFF6EE7B7);
  static const Color mintAccentDark = Color(0xFF06281C);



  // ---------------------------------------------------------------------------
  // NEUTRAL COLORS
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
  static const Color backgroundDark = Color(0xFF1A1A1A); // improved contrast
  static const Color backgroundLight = offWhite;

  static const Color surfaceDark = Color(0xFF242424); // smoother than 2A2A2A
  static const Color surfaceLight = white;

  static const Color cardDark = Color(0xFF2D2D2D);
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
  static const Color borderDark = Color(0xFF383838); // improved visibility
  static const Color borderLight = gray300;

  static const Color dividerDark = gray700;
  static const Color dividerLight = gray300;

  // ---------------------------------------------------------------------------
  // SWITCH / TOGGLE (Cleaned + unified)
  // ---------------------------------------------------------------------------
  static const Color switchOn = Color(0xFF4CAF50);
  static const Color switchOff = Color(0xFFE53935);

  static const Color switchThumbOn = white;
  static const Color switchThumbOff = white;

  static const Color switchDisabled = gray600;

  // ---------------------------------------------------------------------------
  // SLIDER COLORS
  // ---------------------------------------------------------------------------
  static const Color sliderActive = primary;
  static const Color sliderInactiveDark = gray700;
  static const Color sliderInactiveLight = gray300;

  static const Color greenLight = Color(0xFF66BB6A);
  static const Color green = Color(0xFF2E7D32);
  static const Color greenDark = Color(0xFF145A20);

  static const Color sliderPowerActive = green;
  static const Color sliderPowerLight = greenLight;
  static const Color sliderPowerDark = greenDark;
  static const Color sliderPowerInactive = gray600;

  static const Color sliderTempCold = blueLight;
  static const Color sliderTempNormal = Color(0xFF00BCD4);
  static const Color sliderTempHot = red;

  static const Color sliderSignalLow = yellow;
  static const Color sliderSignalHigh = green;

  static const Color sliderDisabled = gray500;

  // ---------------------------------------------------------------------------
  // SEMANTIC COLORS (STATUS)
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ---------------------------------------------------------------------------
  // IOT DEVICE STATES (NEW - IMPORTANT)
  // ---------------------------------------------------------------------------
  static const Color deviceOnline = Color(0xFF22C55E);
  static const Color deviceOffline = gray500;
  static const Color motorRunning = Color(0xFF00E676);
  static const Color motorStopped = gray500;
  static const Color fault = Color(0xFFFF3B30);

  // ---------------------------------------------------------------------------
  // UTILITY COLORS
  // ---------------------------------------------------------------------------
  static const Color red = Color(0xFFE53935);

  static const Color yellow = Color(0xFFFDD835);
  static const Color purple = Color(0xFF8E24AA);

  // ---------------------------------------------------------------------------
  // BLUE SHADES (Charts / telemetry)
  // ---------------------------------------------------------------------------
  static const Color blueLight = Color(0xFF64B5F6);
  static const Color blue = Color(0xFF1E88E5);
  static const Color blueDark = Color(0xFF0D47A1);
  // ---------------------------------------------------------------------------
// AABNEX BRAND COLORS
// ---------------------------------------------------------------------------

  static const Color colorPrimary = Color(0xFF1565C0);
  static const Color colorPrimaryDark =  Color(0xFF0F91D0);
  static const Color colorPrimaryLight = Color(0xFF42A5F5);

  static const Color colorElectricBlue = Color(0xFF2979FF);
  static const Color colorLedBlue = Color(0xFF00B0FF);

  static const Color colorDeviceBlack = Color(0xFF111827);
  static const Color colorDeviceDark = Color(0xFF172033);

  static const Color colorDeviceWhite = Color(0xFFFFFFFF);
  static const Color colorDeviceGray = Color(0xFFE5E7EB);

  static const Color colorSignalOnline = Color(0xFF22C55E);
  static const Color colorSignalOffline = Color(0xFF9CA3AF);

  static const Color colorDanger = Color(0xFFE53935);
  static const Color colorWarning = Color(0xFFFFB300);

  static const Color colorSplashTop = Color(0xFF1976D2);
  static const Color colorSplashBottom = Color(0xFF0D47A1);

  // ---------------------------------------------------------------------------
  // STATES
  // ---------------------------------------------------------------------------
  static const Color disabledDark = gray700;
  static const Color disabledLight = gray300;

  static const Color shadowDark = Colors.black54;
  static const Color shadowLight = Colors.black12;
}