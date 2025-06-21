import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/currency_service.dart';
import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyService _currencyService;
  final StorageService _storageService;

  CurrencyBloc({
    required CurrencyService currencyService,
    StorageService? storageService,
  }) : _currencyService = currencyService,
       _storageService = storageService ?? StorageService(),
       super(const CurrencyInitial()) {
    on<LoadCurrencyRates>(_onLoadCurrencyRates);
    on<RefreshCurrencyRates>(_onRefreshCurrencyRates);
    on<ConvertCurrency>(_onConvertCurrency);
    on<UpdateSelectedCurrency>(_onUpdateSelectedCurrency);
  }

  Future<void> _onLoadCurrencyRates(
    LoadCurrencyRates event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      emit(const CurrencyLoading());

      final rates = await _currencyService.getCurrencyRates();
      final availableCurrencies = await _currencyService
          .getAvailableCurrencies();
      final selectedCurrency = _storageService.getSelectedCurrency();

      emit(
        CurrencyLoaded(
          rates: rates,
          availableCurrencies: availableCurrencies,
          selectedCurrency: selectedCurrency,
        ),
      );
    } catch (e) {
      emit(
        CurrencyError(
          message: 'Failed to load currency rates: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshCurrencyRates(
    RefreshCurrencyRates event,
    Emitter<CurrencyState> emit,
  ) async {
    final currentState = state;

    try {
      if (currentState is CurrencyLoaded) {
        emit(CurrencyRefreshing(currentState.rates));
      } else {
        emit(const CurrencyLoading());
      }

      // Clear cache to force fresh data
      await _currencyService.clearCache();

      final rates = await _currencyService.getCurrencyRates();
      final availableCurrencies = await _currencyService
          .getAvailableCurrencies();
      final selectedCurrency = _storageService.getSelectedCurrency();

      emit(
        CurrencyLoaded(
          rates: rates,
          availableCurrencies: availableCurrencies,
          selectedCurrency: selectedCurrency,
        ),
      );
    } catch (e) {
      emit(
        CurrencyError(
          message: 'Failed to refresh currency rates: ${e.toString()}',
          fallbackRates: currentState is CurrencyLoaded
              ? currentState.rates
              : null,
        ),
      );
    }
  }

  Future<void> _onConvertCurrency(
    ConvertCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      emit(const CurrencyConverting());

      final convertedAmount = await _currencyService.convertCurrency(
        event.amount,
        event.fromCurrency,
        event.toCurrency,
      );

      emit(
        CurrencyConverted(
          originalAmount: event.amount,
          fromCurrency: event.fromCurrency,
          toCurrency: event.toCurrency,
          convertedAmount: convertedAmount,
        ),
      );

      // Return to loaded state
      add(const LoadCurrencyRates());
    } catch (e) {
      emit(
        CurrencyError(message: 'Failed to convert currency: ${e.toString()}'),
      );
    }
  }

  Future<void> _onUpdateSelectedCurrency(
    UpdateSelectedCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      await _storageService.saveSelectedCurrency(event.currency);

      final currentState = state;
      if (currentState is CurrencyLoaded) {
        emit(currentState.copyWith(selectedCurrency: event.currency));
      }
    } catch (e) {
      emit(
        CurrencyError(
          message: 'Failed to update selected currency: ${e.toString()}',
        ),
      );
    }
  }
}
