import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String currencySymbol = '₹'; // Default to INR, configurable in settings
  static String currencyCode = 'INR';

  static String format(double amount, {bool showSymbol = true, bool compact = false}) {
    if (compact) {
      if (amount.abs() >= 10000000) {
        return '${showSymbol ? '$currencySymbol ' : ''}${(amount / 10000000).toStringAsFixed(2)} Cr';
      } else if (amount.abs() >= 100000) {
        return '${showSymbol ? '$currencySymbol ' : ''}${(amount / 100000).toStringAsFixed(2)} L';
      } else if (amount.abs() >= 1000) {
        return '${showSymbol ? '$currencySymbol ' : ''}${(amount / 1000).toStringAsFixed(1)} k';
      }
    }

    final formatter = NumberFormat.currency(
      symbol: showSymbol ? '$currencySymbol ' : '',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount) {
    return format(amount, compact: true);
  }
}
