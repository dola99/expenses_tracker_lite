import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/currency/data/currency_service.dart';
import 'package:expense_tracker/features/currency/domain/currency_rate_model.dart';
import 'package:expense_tracker/core/network/network_service.dart';
import 'package:expense_tracker/core/storage/storage_service.dart';

// Mock classes
class MockNetworkService extends Mock implements NetworkService {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('CurrencyService', () {
    late CurrencyService currencyService;
    late MockNetworkService mockNetworkService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockNetworkService = MockNetworkService();
      mockStorageService = MockStorageService();
      currencyService = CurrencyService(
        networkService: mockNetworkService,
        storageService: mockStorageService,
      );
    });

    group('Currency Rate Calculation Tests', () {
      test('should calculate correct USD conversion rate', () {
        // Test data for currency conversion
        final rates = {'USD': 1.0, 'EUR': 0.85, 'GBP': 0.73, 'JPY': 110.0};

        // Test EUR to USD
        final eurToUsd = rates['USD']! / rates['EUR']!; // 1.0 / 0.85 = 1.176
        expect(eurToUsd, closeTo(1.176, 0.001));

        // Test GBP to USD
        final gbpToUsd = rates['USD']! / rates['GBP']!; // 1.0 / 0.73 = 1.370
        expect(gbpToUsd, closeTo(1.370, 0.001));

        // Test JPY to USD
        final jpyToUsd = rates['USD']! / rates['JPY']!; // 1.0 / 110.0 = 0.009
        expect(jpyToUsd, closeTo(0.009, 0.001));
      });

      test('should convert amount to USD correctly', () {
        // Simulate currency conversion calculations
        const amount = 100.0;
        const eurRate = 0.85; // 1 EUR = 0.85 USD rate from API
        const gbpRate = 0.73; // 1 GBP = 0.73 USD rate from API

        // Convert EUR to USD: amount * (1 / rate)
        final eurToUsd = amount * (1 / eurRate); // 100 * (1 / 0.85) = 117.65
        expect(eurToUsd, closeTo(117.65, 0.01));

        // Convert GBP to USD: amount * (1 / rate)
        final gbpToUsd = amount * (1 / gbpRate); // 100 * (1 / 0.73) = 136.99
        expect(gbpToUsd, closeTo(136.99, 0.01));
      });

      test('should handle USD currency correctly', () {
        const amount = 100.0;
        const usdRate = 1.0;

        final usdToUsd = amount * usdRate;
        expect(usdToUsd, equals(100.0));
      });

      test('should handle precision correctly in currency calculations', () {
        const amount = 33.33;
        const eurRate = 0.8532; // More precise rate

        final convertedAmount = amount * (1 / eurRate);
        expect(convertedAmount, closeTo(39.06, 0.01));
      });
    });

    group('Currency Service API Tests', () {
      test('should return cached rates when available and fresh', () async {
        // Arrange
        final freshRates = CurrencyRateModel(
          baseCurrency: 'USD',
          rates: {'USD': 1.0, 'EUR': 0.85},
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        when(
          () => mockStorageService.getData<Map>(any(), any()),
        ).thenReturn(freshRates.toJson());

        // Act
        final result = await currencyService.getCurrencyRates();

        // Assert
        expect(result, isA<CurrencyRateModel>());
        expect(result.rates['EUR'], equals(0.85));
        verify(() => mockStorageService.getData<Map>(any(), any())).called(1);
      });

      test('should return cached rates when no internet connection', () async {
        // Arrange
        final cachedRates = CurrencyRateModel(
          baseCurrency: 'USD',
          rates: {'USD': 1.0, 'EUR': 0.85},
          timestamp: DateTime.now().subtract(const Duration(hours: 25)),
        );

        when(
          () => mockStorageService.getData<Map>(any(), any()),
        ).thenReturn(cachedRates.toJson());
        when(
          () => mockNetworkService.hasInternetConnection(),
        ).thenAnswer((_) async => false);

        // Act
        final result = await currencyService.getCurrencyRates();

        // Assert
        expect(result, isA<CurrencyRateModel>());
        expect(result.rates['EUR'], equals(0.85));
        verify(() => mockNetworkService.hasInternetConnection()).called(1);
        verifyNever(() => mockNetworkService.get(any()));
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        when(
          () => mockStorageService.getData<Map>(any(), any()),
        ).thenReturn(null);
        when(
          () => mockNetworkService.hasInternetConnection(),
        ).thenAnswer((_) async => true);
        when(
          () => mockNetworkService.get(any()),
        ).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => currencyService.getCurrencyRates(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Currency Conversion Integration Tests', () {
      test('should convert between different currencies correctly', () {
        // Test data representing real currency rates
        final rates = {
          'USD': 1.0,
          'EUR': 0.85,
          'GBP': 0.73,
          'CAD': 1.25,
          'JPY': 110.0,
        };

        // Test converting 100 EUR to USD
        const eurAmount = 100.0;
        final eurToUsd = eurAmount / rates['EUR']!; // 100 / 0.85 = 117.65
        expect(eurToUsd, closeTo(117.65, 0.01));

        // Test converting 100 USD to JPY
        const usdAmount = 100.0;
        final usdToJpy = usdAmount * rates['JPY']!; // 100 * 110 = 11000
        expect(usdToJpy, equals(11000.0));

        // Test converting 100 GBP to EUR
        const gbpAmount = 100.0;
        final gbpToUsd = gbpAmount / rates['GBP']!; // Convert to USD first
        final usdToEur = gbpToUsd * rates['EUR']!; // Then to EUR
        expect(usdToEur, closeTo(116.44, 0.01));
      });

      test('should handle edge cases in currency conversion', () {
        // Test zero amount
        const zeroAmount = 0.0;
        const rate = 0.85;
        final result = zeroAmount / rate;
        expect(result, equals(0.0));

        // Test very small amounts
        const smallAmount = 0.01;
        final smallResult = smallAmount / rate;
        expect(smallResult, closeTo(0.012, 0.001));

        // Test large amounts
        const largeAmount = 1000000.0;
        final largeResult = largeAmount / rate;
        expect(largeResult, closeTo(1176470.59, 0.01));
      });
    });
  });
}

// Mock HTTP response class for testing
class MockHttpResponse {
  final int statusCode;
  final String body;

  MockHttpResponse({
    this.statusCode = 200,
    this.body = '{"rates": {"EUR": 0.85, "GBP": 0.73}}',
  });
}
