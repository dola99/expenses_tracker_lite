import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'currency_rate_model.g.dart';

@HiveType(typeId: 1)
class CurrencyRateModel extends Equatable {
  @HiveField(0)
  final String baseCurrency;

  @HiveField(1)
  final Map<String, double> rates;

  @HiveField(2)
  final DateTime timestamp;

  const CurrencyRateModel({
    required this.baseCurrency,
    required this.rates,
    required this.timestamp,
  });

  /// Convert amount from one currency to another
  double convertAmount(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;

    // If base currency is the target, divide by the rate
    if (baseCurrency == toCurrency) {
      final rate = rates[fromCurrency];
      if (rate == null) throw Exception('Rate not found for $fromCurrency');
      return amount / rate;
    }

    // If base currency is the source, multiply by the rate
    if (baseCurrency == fromCurrency) {
      final rate = rates[toCurrency];
      if (rate == null) throw Exception('Rate not found for $toCurrency');
      return amount * rate;
    }

    // Convert through base currency
    final fromRate = rates[fromCurrency];
    final toRate = rates[toCurrency];

    if (fromRate == null) throw Exception('Rate not found for $fromCurrency');
    if (toRate == null) throw Exception('Rate not found for $toCurrency');

    final amountInBase = amount / fromRate;
    return amountInBase * toRate;
  }

  /// Get rate for a specific currency
  double? getRate(String currency) {
    if (currency == baseCurrency) return 1.0;
    return rates[currency];
  }

  /// Check if rates are stale (older than 1 hour)
  bool get isStale {
    final now = DateTime.now();
    return now.difference(timestamp).inHours > 1;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'rates': rates,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    final ratesMap = json['rates'] as Map;
    final convertedRates = <String, double>{};

    // Convert all rate values to double to handle both int and double
    ratesMap.forEach((key, value) {
      convertedRates[key as String] = (value as num).toDouble();
    });

    return CurrencyRateModel(
      baseCurrency: json['baseCurrency'] as String,
      rates: convertedRates,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Create from API response
  factory CurrencyRateModel.fromApiResponse(Map<String, dynamic> response) {
    final ratesMap = response['rates'] as Map;
    final convertedRates = <String, double>{};

    // Convert all rate values to double to handle both int and double from API
    ratesMap.forEach((key, value) {
      convertedRates[key as String] = (value as num).toDouble();
    });

    return CurrencyRateModel(
      baseCurrency: response['base_code'] as String,
      rates: convertedRates,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [baseCurrency, rates, timestamp];

  @override
  String toString() {
    return 'CurrencyRateModel(baseCurrency: $baseCurrency, ratesCount: ${rates.length}, timestamp: $timestamp)';
  }
}
