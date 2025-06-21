import 'package:equatable/equatable.dart';
import '../../domain/currency_rate_model.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {
  const CurrencyInitial();
}

class CurrencyLoading extends CurrencyState {
  const CurrencyLoading();
}

class CurrencyLoaded extends CurrencyState {
  final CurrencyRateModel rates;
  final List<String> availableCurrencies;
  final String selectedCurrency;

  const CurrencyLoaded({
    required this.rates,
    required this.availableCurrencies,
    required this.selectedCurrency,
  });

  CurrencyLoaded copyWith({
    CurrencyRateModel? rates,
    List<String>? availableCurrencies,
    String? selectedCurrency,
  }) {
    return CurrencyLoaded(
      rates: rates ?? this.rates,
      availableCurrencies: availableCurrencies ?? this.availableCurrencies,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
    );
  }

  @override
  List<Object?> get props => [rates, availableCurrencies, selectedCurrency];
}

class CurrencyError extends CurrencyState {
  final String message;
  final CurrencyRateModel? fallbackRates;

  const CurrencyError({required this.message, this.fallbackRates});

  @override
  List<Object?> get props => [message, fallbackRates];
}

class CurrencyConverting extends CurrencyState {
  const CurrencyConverting();
}

class CurrencyConverted extends CurrencyState {
  final double originalAmount;
  final String fromCurrency;
  final String toCurrency;
  final double convertedAmount;

  const CurrencyConverted({
    required this.originalAmount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.convertedAmount,
  });

  @override
  List<Object?> get props => [
    originalAmount,
    fromCurrency,
    toCurrency,
    convertedAmount,
  ];
}

class CurrencyRefreshing extends CurrencyState {
  final CurrencyRateModel currentRates;

  const CurrencyRefreshing(this.currentRates);

  @override
  List<Object?> get props => [currentRates];
}
