// lib/core/utils/currency_formatter.dart
import 'package:intl/intl.dart';

class KenyanCurrencyFormatter {
  static String format(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'sw_KE',
      symbol: 'KES ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatDouble(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'sw_KE',
      symbol: 'KES ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatOdds(double odds) {
    return odds.toStringAsFixed(2);
  }

  static String formatShort(int amount) {
    if (amount >= 1000000) {
      return 'KES ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'KES ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'KES $amount';
  }
}