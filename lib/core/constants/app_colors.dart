import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Green Palette ─────────────────────────────────────────────────
  static const Color primary       = Color(0xFF1E402D); // dark elegant green
  static const Color primaryDark   = Color(0xFF11261B); // darker green
  static const Color primaryLight  = Color(0xFF22C55E); // light green accent
  static const Color primarySurface= Color(0xFFDCFCE7); // subtle green tint bg

  // ── Secondary / Accent ───────────────────────────────────────────────────
  static const Color secondary     = Color(0xFF16A34A); // bright green accent
  static const Color accent        = Color(0xFF86EFAC); // softer green

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background    = Color(0xFFFAFAFA); // off-white
  static const Color surface       = Color(0xFFFFFFFF); // card/surface white
  static const Color surfaceAlt    = Color(0xFFF1F5F9); // slightly grey surface

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color card          = Colors.white;
  static const Color textDark      = Color(0xFF0F172A); // near black
  static const Color textMedium    = Color(0xFF334155); // dark grey
  static const Color textGrey      = Color(0xFF64748B); // slate grey
  static const Color textLight     = Color(0xFF94A3B8); // light grey

  // ── Gradient helpers ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF204834), Color(0xFF122C1F)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E402D), Color(0xFF163223)],
  );

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color statusMenunggu     = Color(0xFFF59E0B);
  static const Color statusDiverifikasi = Color(0xFF3B82F6);
  static const Color statusSelesai      = Color(0xFF16A34A);
  static const Color statusDitolak      = Color(0xFFEF4444);

  static Color statusColor(String status) {
    switch (status) {
      case 'menunggu_konfirmasi':
        return statusMenunggu;
      case 'diverifikasi':
        return statusDiverifikasi;
      case 'selesai':
        return statusSelesai;
      case 'ditolak':
        return statusDitolak;
      case 'diproses':
        return statusDiverifikasi;
      default:
        return textGrey;
    }
  }
}
