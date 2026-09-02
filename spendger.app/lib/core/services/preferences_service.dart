import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/currency_formatter.dart';
import 'biometric_service.dart';

class PreferencesService {
  static const String _keyBiometric = 'spendger_biometric_enabled';
  static const String _keyThemeMode = 'spendger_theme_mode';
  static const String _keyCurrencySymbol = 'spendger_currency_symbol';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // 1. Initialize Biometrics
    final biometric = _prefs.getBool(_keyBiometric) ?? false;
    BiometricService.cachedBiometricEnabled = biometric;

    // 2. Initialize Currency Symbol
    final currency = _prefs.getString(_keyCurrencySymbol);
    if (currency != null && currency.isNotEmpty) {
      CurrencyFormatter.currencySymbol = currency;
      if (currency == '₹') CurrencyFormatter.currencyCode = 'INR';
      if (currency == '\$') CurrencyFormatter.currencyCode = 'USD';
      if (currency == '€') CurrencyFormatter.currencyCode = 'EUR';
      if (currency == '£') CurrencyFormatter.currencyCode = 'GBP';
      if (currency == 'AED') CurrencyFormatter.currencyCode = 'AED';
    }
  }

  // Biometric
  static bool get isBiometricEnabled => _prefs.getBool(_keyBiometric) ?? false;

  static Future<void> setBiometricEnabled(bool enabled) async {
    BiometricService.cachedBiometricEnabled = enabled;
    await _prefs.setBool(_keyBiometric, enabled);
  }

  // Theme Mode
  static ThemeMode getInitialThemeMode() {
    final modeStr = _prefs.getString(_keyThemeMode);
    if (modeStr == 'light') return ThemeMode.light;
    if (modeStr == 'system') return ThemeMode.system;
    return ThemeMode.dark;
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    String modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.system) modeStr = 'system';
    await _prefs.setString(_keyThemeMode, modeStr);
  }

  // Currency
  static Future<void> setCurrencySymbol(String symbol) async {
    CurrencyFormatter.currencySymbol = symbol;
    if (symbol == '₹') CurrencyFormatter.currencyCode = 'INR';
    if (symbol == '\$') CurrencyFormatter.currencyCode = 'USD';
    if (symbol == '€') CurrencyFormatter.currencyCode = 'EUR';
    if (symbol == '£') CurrencyFormatter.currencyCode = 'GBP';
    if (symbol == 'AED') CurrencyFormatter.currencyCode = 'AED';
    await _prefs.setString(_keyCurrencySymbol, symbol);
  }
}
