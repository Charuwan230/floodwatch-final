// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const bg         = Color(0xFF0A0F1E);
  static const panel      = Color(0xFF0D1628);
  static const border     = Color(0xFF1A2A4A);
  static const accent     = Color(0xFF00D4FF);
  static const accentDark = Color(0xFF0066CC);
  static const safe       = Color(0xFF22C55E);
  static const safeBg     = Color(0x2022C55E);
  static const risk       = Color(0xFFF97316);
  static const riskBg     = Color(0x20F97316);
  static const flood      = Color(0xFFEF4444);
  static const floodBg    = Color(0x20EF4444);
  static const textPrimary   = Color(0xFFE2E8F0);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted     = Color(0xFF64748B);
}

class AppTextStyles {
  static const headline = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.accent, letterSpacing: 1.5,
  );
  static const title = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: 14, color: AppColors.textSecondary,
  );
  static const caption = TextStyle(
    fontSize: 12, color: AppColors.textMuted,
  );
}
