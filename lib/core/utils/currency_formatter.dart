import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormatter = NumberFormat.compact(
    locale: 'en_US',
  );

  /// List of supported currencies
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'INR',
    'BRL',
  ];

  /// Format amount with currency symbol
  static String format(double amount, {String? currencySymbol}) {
    if (currencySymbol != null) {
      return NumberFormat.currency(
        symbol: currencySymbol,
        decimalDigits: 2,
      ).format(amount);
    }
    return _currencyFormatter.format(amount);
  }

  /// Format amount in compact form (e.g., 1.2K, 1.5M)
  static String formatCompact(double amount, {String? currencySymbol}) {
    final compactAmount = _compactCurrencyFormatter.format(amount);
    return '${currencySymbol ?? '\$'}$compactAmount';
  }

  /// Format amount without currency symbol
  static String formatPlain(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  /// Get currency symbol for currency code
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'BRL':
        return 'R\$';
      default:
        return currencyCode;
    }
  }
}
