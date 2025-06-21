import 'package:equatable/equatable.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrencyRates extends CurrencyEvent {
  const LoadCurrencyRates();
}

class RefreshCurrencyRates extends CurrencyEvent {
  const RefreshCurrencyRates();
}

class ConvertCurrency extends CurrencyEvent {
  final double amount;
  final String fromCurrency;
  final String toCurrency;

  const ConvertCurrency({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object?> get props => [amount, fromCurrency, toCurrency];
}

class UpdateSelectedCurrency extends CurrencyEvent {
  final String currency;

  const UpdateSelectedCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}
