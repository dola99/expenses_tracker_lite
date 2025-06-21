import 'package:flutter/foundation.dart';

import '../../../core/network/network_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/currency_rate_model.dart';

class CurrencyService {
  final NetworkService _networkService;
  final StorageService _storageService;

  CurrencyService({
    NetworkService? networkService,
    StorageService? storageService,
  }) : _networkService = networkService ?? NetworkService(),
       _storageService = storageService ?? StorageService();

  /// Get latest currency rates from API or cache
  Future<CurrencyRateModel> getCurrencyRates() async {
    try {
      // Try to get cached rates first
      final cachedRates = _getCachedRates();
      if (cachedRates != null && !cachedRates.isStale) {
        return cachedRates;
      }

      // Check internet connection
      final hasInternet = await _networkService.hasInternetConnection();
      if (!hasInternet) {
        if (cachedRates != null) {
          // Return stale data if no internet
          return cachedRates;
        }
        throw NetworkException(
          'No internet connection and no cached data available.',
          type: NetworkExceptionType.noInternet,
        );
      }

      // Fetch fresh rates from API
      final freshRates = await _fetchRatesFromApi();
      await _cacheRates(freshRates);

      return freshRates;
    } catch (e) {
      // If API fails, try to return cached data
      final cachedRates = _getCachedRates();
      if (cachedRates != null) {
        return cachedRates;
      }
      rethrow;
    }
  }

  /// Convert amount between currencies
  Future<double> convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;

    final rates = await getCurrencyRates();
    return rates.convertAmount(amount, fromCurrency, toCurrency);
  }

  /// Convert amount to USD (base currency)
  Future<double> convertToUSD(double amount, String fromCurrency) async {
    return convertCurrency(amount, fromCurrency, AppConstants.baseCurrency);
  }

  /// Get available currencies
  Future<List<String>> getAvailableCurrencies() async {
    try {
      final rates = await getCurrencyRates();
      final currencies = [rates.baseCurrency, ...rates.rates.keys];
      return currencies.toSet().toList()..sort();
    } catch (e) {
      // Return default currencies if API fails
      return AppConstants.supportedCurrencies;
    }
  }

  /// Fetch rates from API
  Future<CurrencyRateModel> _fetchRatesFromApi() async {
    final url =
        '${AppConstants.currencyApiBaseUrl}/${AppConstants.baseCurrency}';

    final response = await _networkService.get(url);

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;

      if (data['result'] == 'success') {
        return CurrencyRateModel.fromApiResponse(data);
      } else {
        throw NetworkException(
          'API returned error: ${data['error-type'] ?? 'Unknown error'}',
          type: NetworkExceptionType.serverError,
        );
      }
    } else {
      throw NetworkException(
        'Failed to fetch currency rates',
        type: NetworkExceptionType.serverError,
        statusCode: response.statusCode,
      );
    }
  }

  /// Get cached rates from storage
  CurrencyRateModel? _getCachedRates() {
    try {
      final data = _storageService.getData<Map>(
        AppConstants.currencyRatesBoxKey,
        'latest_rates',
      );

      if (data != null) {
        return CurrencyRateModel.fromJson(data.cast<String, dynamic>());
      }
    } catch (e) {
      debugPrint('Error reading cached rates: $e');
    }
    return null;
  }

  /// Cache rates to storage
  Future<void> _cacheRates(CurrencyRateModel rates) async {
    try {
      await _storageService.saveData(
        AppConstants.currencyRatesBoxKey,
        'latest_rates',
        rates.toJson(),
      );
    } catch (e) {
      debugPrint('Error caching rates: $e');
    }
  }

  /// Clear cached rates
  Future<void> clearCache() async {
    await _storageService.deleteData(
      AppConstants.currencyRatesBoxKey,
      'latest_rates',
    );
  }
}
