import 'package:flutter/material.dart';

class AppColors {
  // Brand / Theme Accents
  static const primary = Color(0xFF6366F1); // Indigo
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4338CA);
  
  static const secondary = Color(0xFF0EA5E9); // Sky
  static const accent = Color(0xFF8B5CF6); // Violet

  // Financial Domain Accents
  static const income = Color(0xFF10B981); // Emerald
  static const incomeLight = Color(0xFF34D399);
  static const incomeBg = Color(0xFF064E3B);

  static const expense = Color(0xFFF43F5E); // Rose
  static const expenseLight = Color(0xFFFB7185);
  static const expenseBg = Color(0xFF881337);

  static const loan = Color(0xFFF59E0B); // Amber
  static const loanLight = Color(0xFFFBBF24);
  static const loanBg = Color(0xFF78350F);

  static const investment = Color(0xFF8B5CF6); // Purple
  static const chitty = Color(0xFFEC4899); // Pink
  static const gold = Color(0xFFEAB308); // Gold Yellow
  static const sip = Color(0xFF06B6D4); // Cyan

  // Budget Alert Zones
  static const budgetSafe = Color(0xFF10B981); // < 75%
  static const budgetWarning = Color(0xFFF59E0B); // 75% - 99%
  static const budgetBreached = Color(0xFFEF4444); // >= 100%

  // Dark OLED Palette
  static const darkBackground = Color(0xFF090D16);
  static const darkSurface = Color(0xFF131B2E);
  static const darkSurfaceElevated = Color(0xFF1E293B);
  static const darkCardBorder = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextMuted = Color(0xFF64748B);

  // Light Palette
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceElevated = Color(0xFFF1F5F9);
  static const lightCardBorder = Color(0xFFE2E8F0);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightTextMuted = Color(0xFF94A3B8);
}
