import 'package:flutter/material.dart';

/// Design token constants derived from the Product Design System Document.
/// All values are compile-time constants — never derived from Theme or BuildContext.

class AppColors {
  AppColors._();

  static const primary    = Color(0xFF4F46E5); // Indigo
  static const success    = Color(0xFF16A34A); // Green
  static const warning    = Color(0xFFF59E0B); // Amber
  static const error      = Color(0xFFDC2626); // Red

  static const background = Color(0xFFF9FAFB); // Light grey page background
  static const surface    = Colors.white;
}

class AppSpacing {
  AppSpacing._();

  static const xs  = 4.0;
  static const sm  = 8.0;
  static const md  = 16.0;
  static const lg  = 24.0;
  static const xl  = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  AppRadius._();

  static const small  = 8.0;
  static const medium = 16.0;
  static const large  = 24.0;
  static const hero   = 28.0;
}

class AppDurations {
  AppDurations._();

  static const fast   = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow   = Duration(milliseconds: 350);
}

class AppTypography {
  AppTypography._();

  static const hero = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
  );

  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    fontSize: 14,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
