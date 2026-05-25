import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Color principal único del sistema
  static const Color primary = Color(0xFF004D40);
  static const Color primaryDark = Color(0xFF004D40);
  static const Color secondary = Color(0xFF004D40);
  static const Color accent = Color(0xFF004D40);

  // Compatibilidad con nombres antiguos
  static const Color primaryGreen = primary;
  static const Color darkGreen = primary;
  static const Color accentGreen = primary;

  // Fondos y superficies
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Textos
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF94A3B8);

  // Mapa / marcadores
  static const Color parkingMarker = primary;
  static const Color mapBorder = Color(0x33004D40);

  // Estados
  static const Color success = primary;
  static const Color warning = Color(0xFFB7791F);
  static const Color error = Color(0xFFB91C1C);
  static const Color danger = error;
}
