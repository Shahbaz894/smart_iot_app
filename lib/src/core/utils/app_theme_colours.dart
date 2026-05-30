// import "package:flutter/material.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
//
// class AppThemeColors {
//   AppThemeColors._();
//
//   static bool isDark(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark;
//   }
//
//   // =========================
//   // MAIN BACKGROUNDS
//   // =========================
//
//   static Color background(BuildContext context) {
//     return isDark(context)
//         ? AppColors.darkBgSoft
//         : AppColors.backgroundLight;
//   }
//
//   static Color surface(BuildContext context) {
//     return isDark(context)
//         ? AppColors.darkSurfaceSoft
//         : AppColors.surfaceLight;
//   }
//
//   static Color card(BuildContext context) {
//     return isDark(context)
//         ? AppColors.darkCardSoft
//         : AppColors.cardLight;
//   }
//
//   static Color input(BuildContext context) {
//     return isDark(context)
//         ? AppColors.darkSurfaceSoft
//         : AppColors.gray100;
//   }
//
//   // =========================
//   // TEXT COLORS
//   // =========================
//
//   static Color text(BuildContext context) {
//     return isDark(context)
//         ? AppColors.textPrimaryDark
//         : AppColors.textPrimaryLight;
//   }
//
//   static Color subText(BuildContext context) {
//     return isDark(context)
//         ? AppColors.textMutedSoft
//         : AppColors.textSecondaryLight;
//   }
//
//   static Color hint(BuildContext context) {
//     return isDark(context)
//         ? AppColors.gray400
//         : AppColors.gray500;
//   }
//
//   // =========================
//   // BORDERS & SHADOWS
//   // =========================
//
//   static Color border(BuildContext context) {
//     return isDark(context)
//         ? AppColors.darkBorderSoft
//         : AppColors.borderLight;
//   }
//
//   static Color shadow(BuildContext context) {
//     return isDark(context)
//         ? AppColors.shadowDark
//         : AppColors.shadowLight;
//   }
//
//   static List<BoxShadow> cardShadow(BuildContext context) {
//     return [
//       BoxShadow(
//         color: shadow(context),
//         blurRadius: isDark(context) ? 18 : 20,
//         offset: const Offset(0, 10),
//       ),
//     ];
//   }
//
//   // =========================
//   // APPBAR
//   // =========================
//
//   static Color appBar(BuildContext context) {
//     return isDark(context)
//         ? AppColors.darkSurfaceSoft
//         : AppColors.primary;
//   }
//
//   static Color appBarText(BuildContext context) {
//     return isDark(context)
//         ? AppColors.white
//         : AppColors.white;
//   }
//
//   // =========================
//   // STATUS COLORS
//   // =========================
//
//   static Color success(BuildContext context) {
//     return AppColors.success;
//   }
//
//   static Color error(BuildContext context) {
//     return AppColors.error;
//   }
//
//   static Color warning(BuildContext context) {
//     return AppColors.warning;
//   }
//
//   static Color info(BuildContext context) {
//     return AppColors.info;
//   }
//
//   static Color primary(BuildContext context) {
//     return AppColors.primary;
//   }
//
//   // =========================
//   // BUTTONS
//   // =========================
//
//   static Color button(BuildContext context) {
//     return AppColors.primary;
//   }
//
//   static Color buttonText(BuildContext context) {
//     return isDark(context)
//         ? AppColors.black
//         : AppColors.white;
//   }
//
//   static Color disabledButton(BuildContext context) {
//     return isDark(context)
//         ? AppColors.disabledDark
//         : AppColors.disabledLight;
//   }
//
//   // =========================
//   // DECORATIONS
//   // =========================
//
//   static BoxDecoration cardDecoration(BuildContext context) {
//     return BoxDecoration(
//       color: card(context),
//       borderRadius: BorderRadius.circular(24),
//       border: Border.all(
//         color: border(context),
//       ),
//       boxShadow: cardShadow(context),
//     );
//   }
//
//   static BoxDecoration surfaceDecoration(BuildContext context) {
//     return BoxDecoration(
//       color: surface(context),
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(
//         color: border(context),
//       ),
//     );
//   }
//
//   static InputDecoration inputDecoration(
//       BuildContext context, {
//         required String hint,
//         required IconData icon,
//       }) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: TextStyle(
//         color: hintColor(context),
//       ),
//       prefixIcon: Icon(
//         icon,
//         color: primary(context),
//       ),
//       filled: true,
//       fillColor: input(context),
//
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(18),
//         borderSide: BorderSide(
//           color: border(context),
//         ),
//       ),
//
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(18),
//         borderSide: BorderSide(
//           color: border(context),
//         ),
//       ),
//
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(18),
//         borderSide: BorderSide(
//           color: primary(context),
//           width: 1.5,
//         ),
//       ),
//     );
//   }
//
//   // =========================
//   // EXTRA
//   // =========================
//
//   static Color hintColor(BuildContext context) {
//     return isDark(context)
//         ? AppColors.gray500
//         : AppColors.gray500;
//   }
//
//   static Color divider(BuildContext context) {
//     return border(context);
//   }
//
//   static Color icon(BuildContext context) {
//     return text(context);
//   }
//
//   static Color iconMuted(BuildContext context) {
//     return subText(context);
//   }
// }

import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

class AppThemeColors {
  AppThemeColors._();

  static Color background(BuildContext context) {
    return AppColors.darkBgSoft;
  }

  static Color surface(BuildContext context) {
    return AppColors.darkSurfaceSoft;
  }

  static Color card(BuildContext context) {
    return AppColors.darkCardSoft;
  }

  static Color text(BuildContext context) {
    return AppColors.textPrimaryDark;
  }

  static Color subText(BuildContext context) {
    return AppColors.textMutedSoft;
  }

  static Color border(BuildContext context) {
    return AppColors.darkBorderSoft;
  }

  static Color input(BuildContext context) {
    return AppColors.darkSurfaceSoft;
  }

  static Color shadow(BuildContext context) {
    return AppColors.shadowDark;
  }

  static Color appBar(BuildContext context) {
    return AppColors.darkSurfaceSoft;
  }

  static Color appBarText(BuildContext context) {
    return AppColors.white;
  }

  static Color primary(BuildContext context) {
    return AppColors.primary;
  }

  static Color success(BuildContext context) {
    return AppColors.success;
  }

  static Color error(BuildContext context) {
    return AppColors.error;
  }

  static Color warning(BuildContext context) {
    return AppColors.warning;
  }

  static Color info(BuildContext context) {
    return AppColors.info;
  }

  static Color disabledButton(BuildContext context) {
    return AppColors.disabledDark;
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    return [
      BoxShadow(
        color: AppColors.shadowDark,
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: card(context),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: border(context)),
      boxShadow: cardShadow(context),
    );
  }

  static BoxDecoration surfaceDecoration(BuildContext context) {
    return BoxDecoration(
      color: surface(context),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: border(context)),
    );
  }
}