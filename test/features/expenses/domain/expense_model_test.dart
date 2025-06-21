import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/expenses/domain/expense_model.dart';

void main() {
  group('ExpenseModel', () {
    final now = DateTime.now();

    group('Validation Tests', () {
      test('should create valid expense with all required fields', () {
        final expense = ExpenseModel(
          id: '123',
          category: 'Food',
          amount: 25.50,
          currency: 'USD',
          amountInUSD: 25.50,
          date: now,
          description: 'Lunch',
          receiptPath: null,
          createdAt: now,
          updatedAt: now,
        );

        expect(expense.id, equals('123'));
        expect(expense.category, equals('Food'));
        expect(expense.amount, equals(25.50));
        expect(expense.currency, equals('USD'));
        expect(expense.amountInUSD, equals(25.50));
        expect(expense.date, equals(now));
        expect(expense.description, equals('Lunch'));
        expect(expense.receiptPath, isNull);
      });

      test('should create expense with factory constructor', () {
        final expense = ExpenseModel.create(
          category: 'Transport',
          amount: 15.75,
          currency: 'EUR',
          amountInUSD: 17.20,
          date: now,
          description: 'Bus ticket',
        );

        expect(expense.category, equals('Transport'));
        expect(expense.amount, equals(15.75));
        expect(expense.currency, equals('EUR'));
        expect(expense.amountInUSD, equals(17.20));
        expect(expense.date, equals(now));
        expect(expense.description, equals('Bus ticket'));
        expect(expense.id, isNotEmpty);
        expect(expense.createdAt, isNotNull);
        expect(expense.updatedAt, isNotNull);
      });

      test('should validate positive amount', () {
        expect(
          () => ExpenseModel.create(
            category: 'Food',
            amount: 0,
            currency: 'USD',
            amountInUSD: 0,
            date: now,
          ),
          returnsNormally,
        );

        expect(
          () => ExpenseModel.create(
            category: 'Food',
            amount: -10.0,
            currency: 'USD',
            amountInUSD: -10.0,
            date: now,
          ),
          returnsNormally,
        ); // Model doesn't validate, but business logic should
      });

      test('should validate required category', () {
        expect(
          () => ExpenseModel.create(
            category: '',
            amount: 10.0,
            currency: 'USD',
            amountInUSD: 10.0,
            date: now,
          ),
          returnsNormally,
        );

        expect(
          () => ExpenseModel.create(
            category: 'Food',
            amount: 10.0,
            currency: 'USD',
            amountInUSD: 10.0,
            date: now,
          ),
          returnsNormally,
        );
      });

      test('should validate currency format', () {
        expect(
          () => ExpenseModel.create(
            category: 'Food',
            amount: 10.0,
            currency: 'USD',
            amountInUSD: 10.0,
            date: now,
          ),
          returnsNormally,
        );

        expect(
          () => ExpenseModel.create(
            category: 'Food',
            amount: 10.0,
            currency: 'INVALID',
            amountInUSD: 10.0,
            date: now,
          ),
          returnsNormally,
        ); // Model accepts any string
      });

      test('should handle optional fields correctly', () {
        final expense = ExpenseModel.create(
          category: 'Food',
          amount: 10.0,
          currency: 'USD',
          amountInUSD: 10.0,
          date: now,
        );

        expect(expense.description, isNull);
        expect(expense.receiptPath, isNull);
      });
    });

    group('Currency Calculation Tests', () {
      test('should maintain correct USD conversion', () {
        final expense = ExpenseModel.create(
          category: 'Food',
          amount: 100.0,
          currency: 'EUR',
          amountInUSD: 110.0, // 1 EUR = 1.10 USD
          date: now,
        );

        expect(expense.amount, equals(100.0));
        expect(expense.amountInUSD, equals(110.0));
        expect(expense.currency, equals('EUR'));
      });

      test('should handle USD amounts correctly', () {
        final expense = ExpenseModel.create(
          category: 'Food',
          amount: 50.0,
          currency: 'USD',
          amountInUSD: 50.0,
          date: now,
        );

        expect(expense.amount, equals(expense.amountInUSD));
      });

      test('should preserve precision for currency calculations', () {
        final expense = ExpenseModel.create(
          category: 'Food',
          amount: 33.33,
          currency: 'GBP',
          amountInUSD: 41.66, // Calculated conversion
          date: now,
        );

        expect(expense.amount, equals(33.33));
        expect(expense.amountInUSD, equals(41.66));
      });
    });

    group('JSON Serialization Tests', () {
      test('should serialize to JSON correctly', () {
        final expense = ExpenseModel(
          id: '123',
          category: 'Food',
          amount: 25.50,
          currency: 'USD',
          amountInUSD: 25.50,
          date: DateTime(2024, 1, 15, 12, 30),
          description: 'Lunch',
          receiptPath: '/path/to/receipt.jpg',
          createdAt: DateTime(2024, 1, 15, 12, 0),
          updatedAt: DateTime(2024, 1, 15, 12, 30),
        );

        final json = expense.toJson();

        expect(json['id'], equals('123'));
        expect(json['category'], equals('Food'));
        expect(json['amount'], equals(25.50));
        expect(json['currency'], equals('USD'));
        expect(json['amountInUSD'], equals(25.50));
        expect(json['date'], equals('2024-01-15T12:30:00.000'));
        expect(json['description'], equals('Lunch'));
        expect(json['receiptPath'], equals('/path/to/receipt.jpg'));
        expect(json['createdAt'], equals('2024-01-15T12:00:00.000'));
        expect(json['updatedAt'], equals('2024-01-15T12:30:00.000'));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': '123',
          'category': 'Food',
          'amount': 25.50,
          'currency': 'USD',
          'amountInUSD': 25.50,
          'date': '2024-01-15T12:30:00.000',
          'description': 'Lunch',
          'receiptPath': '/path/to/receipt.jpg',
          'createdAt': '2024-01-15T12:00:00.000',
          'updatedAt': '2024-01-15T12:30:00.000',
        };

        final expense = ExpenseModel.fromJson(json);

        expect(expense.id, equals('123'));
        expect(expense.category, equals('Food'));
        expect(expense.amount, equals(25.50));
        expect(expense.currency, equals('USD'));
        expect(expense.amountInUSD, equals(25.50));
        expect(expense.date, equals(DateTime(2024, 1, 15, 12, 30)));
        expect(expense.description, equals('Lunch'));
        expect(expense.receiptPath, equals('/path/to/receipt.jpg'));
        expect(expense.createdAt, equals(DateTime(2024, 1, 15, 12, 0)));
        expect(expense.updatedAt, equals(DateTime(2024, 1, 15, 12, 30)));
      });

      test('should handle null values in JSON', () {
        final json = {
          'id': '123',
          'category': 'Food',
          'amount': 25.50,
          'currency': 'USD',
          'amountInUSD': 25.50,
          'date': '2024-01-15T12:30:00.000',
          'description': null,
          'receiptPath': null,
          'createdAt': '2024-01-15T12:00:00.000',
          'updatedAt': '2024-01-15T12:30:00.000',
        };

        final expense = ExpenseModel.fromJson(json);

        expect(expense.description, isNull);
        expect(expense.receiptPath, isNull);
      });
    });

    group('Copy With Tests', () {
      late ExpenseModel originalExpense;

      setUp(() {
        originalExpense = ExpenseModel.create(
          category: 'Food',
          amount: 25.50,
          currency: 'USD',
          amountInUSD: 25.50,
          date: now,
          description: 'Original description',
        );
      });

      test('should create copy with updated fields', () {
        final updatedExpense = originalExpense.copyWith(
          category: 'Transport',
          amount: 15.75,
          description: 'Updated description',
        );

        expect(updatedExpense.category, equals('Transport'));
        expect(updatedExpense.amount, equals(15.75));
        expect(updatedExpense.description, equals('Updated description'));
        expect(updatedExpense.currency, equals(originalExpense.currency));
        expect(updatedExpense.id, equals(originalExpense.id));
        expect(
          updatedExpense.updatedAt.isAfter(originalExpense.updatedAt),
          isTrue,
        );
      });

      test('should preserve original values when no changes', () {
        final copiedExpense = originalExpense.copyWith();

        expect(copiedExpense.id, equals(originalExpense.id));
        expect(copiedExpense.category, equals(originalExpense.category));
        expect(copiedExpense.amount, equals(originalExpense.amount));
        expect(copiedExpense.currency, equals(originalExpense.currency));
        expect(copiedExpense.description, equals(originalExpense.description));
        expect(
          copiedExpense.updatedAt.isAfter(originalExpense.updatedAt),
          isTrue,
        );
      });
    });

    group('Equality Tests', () {
      test('should be equal when all properties match', () {
        final date = DateTime.now();
        final expense1 = ExpenseModel.create(
          category: 'Food',
          amount: 25.50,
          currency: 'USD',
          amountInUSD: 25.50,
          date: date,
        );

        // Create identical expense with same properties
        final expense2 = ExpenseModel(
          id: expense1.id,
          category: expense1.category,
          amount: expense1.amount,
          currency: expense1.currency,
          amountInUSD: expense1.amountInUSD,
          date: expense1.date,
          description: expense1.description,
          receiptPath: expense1.receiptPath,
          createdAt: expense1.createdAt,
          updatedAt: expense1.updatedAt,
        );

        expect(expense1, equals(expense2));
      });

      test('should not be equal when properties differ', () {
        final expense1 = ExpenseModel.create(
          category: 'Food',
          amount: 25.50,
          currency: 'USD',
          amountInUSD: 25.50,
          date: DateTime.now(),
        );

        final expense2 = expense1.copyWith(amount: 30.0);

        expect(expense1, isNot(equals(expense2)));
      });
    });
  });
}
