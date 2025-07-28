import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Woonkly Brand Colors
const primaryColor = Color(0xFF00BFFF);     // Primary brand color
const secondaryColor = Color(0xFF40E0D0);   // Secondary brand color
const primaryLight = Color(0xFF87CEEB);     // Light variant
const primaryDark = Color(0xFF0099CC);      // Dark variant

// System Colors
const Color greyLight = Color(0xFFF8F9FA);
const Color greyColor = Color(0xFF6C757D);
const Color errorColor = Color(0xFFE53E3E);
const Color successColor = Color(0xFF38A169);
const Color warningColor = Color(0xFFD69E2E);

// Surface Colors
const Color surfaceLight = Color(0xFFFFFFFF);
const Color surfaceDark = Color(0xFF1A1A1A);
const Color cardLight = Color(0xFFFAFAFA);
const Color cardDark = Color(0xFF2D2D2D);

// Light Theme Colors
const Color lightThemeBgColor = Color(0xFFF0F8FF);
const Color lightThemeTextColor = Color(0xFF2D3748);
const Color lightThemeSecondaryText = Color(0xFF718096);

// Dark Theme Colors
const Color darkThemeBgColor = Color(0xFF0F0F23);
const Color darkThemeTextColor = Color(0xFFE2E8F0);
const Color darkPrimaryContainer = Color(0xFF1A1A2E);
const Color darkSecondaryContainer = Color(0xFF16213E);

//
// Be careful when changing others below unless you have a specific need.
//

// Other defaults - updated for modern design
const double defaultPadding = 20.0;
const double defaultMargin = 20.0;
const double defaultRadius = 20.0;
const double smallRadius = 12.0;
const double largeRadius = 28.0;

/// Default Border Radius
final BorderRadius borderRadius = BorderRadius.circular(defaultRadius);
final BorderRadius smallBorderRadius = BorderRadius.circular(smallRadius);
final BorderRadius largeBorderRadius = BorderRadius.circular(largeRadius);

/// Default Bottom Sheet Radius
const BorderRadius bottomSheetRadius = BorderRadius.only(
  topLeft: Radius.circular(24),
  topRight: Radius.circular(24),
);

/// Default Top Sheet Radius
const BorderRadius topSheetRadius = BorderRadius.only(
  bottomLeft: Radius.circular(24),
  bottomRight: Radius.circular(24),
);

/// Modern Box Shadow
final List<BoxShadow> boxShadow = [
  BoxShadow(
    blurRadius: 20,
    spreadRadius: 0,
    offset: const Offset(0, 4),
    color: Colors.black.withOpacity(0.08),
  ),
];

/// Subtle Box Shadow
final List<BoxShadow> subtleShadow = [
  BoxShadow(
    blurRadius: 8,
    spreadRadius: 0,
    offset: const Offset(0, 2),
    color: Colors.black.withOpacity(0.04),
  ),
];

/// Card Shadow
final List<BoxShadow> cardShadow = [
  BoxShadow(
    blurRadius: 16,
    spreadRadius: -2,
    offset: const Offset(0, 8),
    color: Colors.black.withOpacity(0.12),
  ),
];

const Duration duration = Duration(milliseconds: 300);

// Modern gradient definitions
const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF00BFFF), // Sky Blue
    Color(0xFF87CEEB), // Light Sky Blue
  ],
);

const LinearGradient darkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
  ],
);

// New modern gradients
const LinearGradient modernPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF00BFFF), // Sky Blue
    Color(0xFF40E0D0), // Turquoise
    Color(0xFF87CEEB), // Light Sky Blue
  ],
);

const LinearGradient modernDarkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0F0F23),
  ],
);

const LinearGradient glassGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0x33FFFFFF),
    Color(0x11FFFFFF),
  ],
);

// <-- Get system overlay theme style -->
SystemUiOverlayStyle getSystemOverlayStyle(bool isDarkMode) {
  final Brightness brightness = isDarkMode ? Brightness.dark : Brightness.light;

  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    // iOS only
    statusBarBrightness: brightness,
    // Android only
    statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    // Android only
    systemNavigationBarColor:
        isDarkMode ? darkThemeBgColor : lightThemeBgColor,
    // Android only
    systemNavigationBarIconBrightness:
        isDarkMode ? Brightness.light : Brightness.dark,
  );
}
