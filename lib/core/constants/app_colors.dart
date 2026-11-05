import 'package:flutter/material.dart';

/// Paleta de colores oficial de CafeterIA ESCOM.
///
/// Inspirada en los colores institucionales del IPN (guinda/vino)
/// con acentos modernos en verde esmeralda para la cafetería.
class AppColors {
  AppColors._();

  // ── Primario: Guinda IPN ──────────────────────────────────
  static const Color primary = Color(0xFF6D1F3E);
  static const Color primaryLight = Color(0xFF9C4063);
  static const Color primaryDark = Color(0xFF430019);

  // ── Secundario: Verde Esmeralda (cafetería / naturaleza) ──
  static const Color secondary = Color(0xFF2E7D52);
  static const Color secondaryLight = Color(0xFF5AAD7E);
  static const Color secondaryDark = Color(0xFF005029);

  // ── Acento: Naranja Cálido (apetitoso) ───────────────────
  static const Color accent = Color(0xFFE87C2D);
  static const Color accentLight = Color(0xFFFFAD5B);
  static const Color accentDark = Color(0xFFB04D00);

  // ── Neutrales ─────────────────────────────────────────────
  static const Color background = Color(0xFFF8F4F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EAE4);

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // ── Texto ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textDisabled = Color(0xFFB0B0B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Estados de pedido ─────────────────────────────────────
  static const Color statusPending = Color(0xFFF59E0B);    // Amarillo
  static const Color statusConfirmed = Color(0xFF3B82F6);  // Azul
  static const Color statusPreparing = Color(0xFFF97316);  // Naranja
  static const Color statusReady = Color(0xFF22C55E);      // Verde
  static const Color statusDelivered = Color(0xFF6B7280);  // Gris
  static const Color statusCancelled = Color(0xFFEF4444);  // Rojo

  // ── Utilidad ──────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  static const Color divider = Color(0xFFE5E0DB);
  static const Color shadow = Color(0x1A000000);
}
