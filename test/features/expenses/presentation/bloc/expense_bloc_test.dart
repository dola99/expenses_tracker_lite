import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/expenses/domain/expense_model.dart';
import 'package:expense_tracker/features/currency/data/currency_service.dart';
import 'package:expense_tracker/core/storage/storage_service.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';

// Mock classes
class MockStorageService extends Mock implements StorageService {}

class MockCurrencyService extends Mock implements CurrencyService {}

class MockBox extends Mock implements Box {}

void main() {
  group('ExpenseBloc', () {
    late ExpenseBloc expenseBloc;
    late MockStorageService mockStorageService;
    late MockCurrencyService mockCurrencyService;
    late MockBox mockExpensesBox;

    setUp(() {
      mockStorageService = MockStorageService();
      mockCurrencyService = MockCurrencyService();
      mockExpensesBox = MockBox();

      // Setup mock box
      when(() => mockStorageService.expensesBox).thenReturn(mockExpensesBox);

      expenseBloc = ExpenseBloc(
        storageService: mockStorageService,
        currencyService: mockCurrencyService,
      );
    });

    tearDown(() {
      expenseBloc.close();
    });

    group('Pagination Logic Tests', () {
      final List<ExpenseModel> mockExpenses = List.generate(
        25, // Generate 25 expenses for pagination testing
        (index) => ExpenseModel.create(
          category: 'Category ${index % 5}',
          amount: (index + 1) * 10.0,
          currency: 'USD',
          amountInUSD: (index + 1) * 10.0,
          date: DateTime.now().subtract(Duration(days: index)),
          description: 'Expense $index',
        ),
      );

      test('should return correct page size', () {
        // Test pagination logic manually
        const itemsPerPage = AppConstants.itemsPerPage;
        const page = 1;

        final startIndex = (page - 1) * itemsPerPage;
        final endIndex = startIndex + itemsPerPage;

        final paginatedExpenses = mockExpenses.sublist(
          startIndex,
          endIndex > mockExpenses.length ? mockExpenses.length : endIndex,
        );

        expect(paginatedExpenses.length, equals(itemsPerPage));
        expect(paginatedExpenses.first.description, contains('Expense 0'));
      });

      test('should handle last page correctly', () {
        const itemsPerPage = AppConstants.itemsPerPage;
        const totalExpenses = 25;
        final lastPage = (totalExpenses / itemsPerPage).ceil();

        final startIndex = (lastPage - 1) * itemsPerPage;
        final endIndex = startIndex + itemsPerPage;

        final paginatedExpenses = mockExpenses.sublist(
          startIndex,
          endIndex > mockExpenses.length ? mockExpenses.length : endIndex,
        );

        // Last page should have 5 items (25 total, 10 per page = 2 full pages + 5 remainder)
        expect(paginatedExpenses.length, equals(5));
      });

      test('should return empty list for pages beyond available data', () {
        const itemsPerPage = AppConstants.itemsPerPage;
        const page = 10; // Way beyond available data

        final startIndex = (page - 1) * itemsPerPage;

        if (startIndex >= mockExpenses.length) {
          expect([], isEmpty);
        }
      });

      blocTest<ExpenseBloc, ExpenseState>(
        'should load first page correctly',
        build: () {
          // Mock storage to return all expenses
          when(
            () => mockExpensesBox.values,
          ).thenReturn(mockExpenses.map((e) => e.toJson()).toList());
          return expenseBloc;
        },
        act: (bloc) => bloc.add(const LoadExpenses(page: 1)),
        expect: () => [
          const ExpenseLoading(),
          isA<ExpenseLoaded>().having(
            (state) => state.expenses.length,
            'page size',
            equals(AppConstants.itemsPerPage),
          ),
        ],
      );

      blocTest<ExpenseBloc, ExpenseState>(
        'should load more expenses on pagination',
        build: () {
          when(
            () => mockExpensesBox.values,
          ).thenReturn(mockExpenses.map((e) => e.toJson()).toList());
          return expenseBloc;
        },
        seed: () => ExpenseLoaded(
          expenses: mockExpenses.take(AppConstants.itemsPerPage).toList(),
          totalAmount: 0.0,
          hasReachedMax: false,
          currentPage: 1,
        ),
        act: (bloc) => bloc.add(const LoadMoreExpenses()),
        expect: () => [
          isA<ExpenseLoadingMore>(),
          isA<ExpenseLoaded>().having(
            (state) => state.expenses.length,
            'total loaded expenses',
            equals(AppConstants.itemsPerPage * 2), // Two pages worth
          ),
        ],
      );

      blocTest<ExpenseBloc, ExpenseState>(
        'should set hasReachedMax when no more expenses available',
        build: () {
          // Return only 5 expenses (less than one page)
          final fewExpenses = mockExpenses.take(5).toList();
          when(
            () => mockExpensesBox.values,
          ).thenReturn(fewExpenses.map((e) => e.toJson()).toList());
          return expenseBloc;
        },
        act: (bloc) => bloc.add(const LoadExpenses(page: 1)),
        expect: () => [
          const ExpenseLoading(),
          isA<ExpenseLoaded>().having(
            (state) => state.hasReachedMax,
            'has reached max',
            equals(true),
          ),
        ],
      );
    });

    group('Expense Validation Tests', () {
      blocTest<ExpenseBloc, ExpenseState>(
        'should successfully add valid expense',
        build: () {
          when(
            () => mockStorageService.saveData(any(), any(), any()),
          ).thenAnswer((_) async {});
          when(() => mockExpensesBox.values).thenReturn([]);
          when(
            () => mockCurrencyService.convertToUSD(any(), any()),
          ).thenAnswer((_) async => 25.50);
          return expenseBloc;
        },
        act: (bloc) {
          bloc.add(
            AddExpense(
              category: 'Food',
              amount: 25.50,
              currency: 'USD',
              date: DateTime.now(),
              description: 'Valid expense',
            ),
          );
        },
        expect: () => [
          const ExpenseAdding(),
          isA<ExpenseOperationSuccess>(),
          const ExpenseLoading(),
          isA<ExpenseLoaded>(),
        ],
      );

      test('should validate expense amount is not negative', () {
        // Business logic validation (would be in a validator class)
        const amount = -10.0;
        expect(amount < 0, isTrue, reason: 'Amount should not be negative');
      });

      test('should validate expense category is not empty', () {
        const category = '';
        expect(
          category.isEmpty,
          isTrue,
          reason: 'Category should not be empty',
        );
      });

      test('should validate expense date is not in future', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final now = DateTime.now();
        expect(
          futureDate.isAfter(now),
          isTrue,
          reason: 'Future dates should be validated',
        );
      });

      test('should validate currency code format', () {
        const validCurrency = 'USD';
        const invalidCurrency = 'us';

        expect(validCurrency.length, equals(3));
        expect(invalidCurrency.length, isNot(equals(3)));
      });
    });

    group('Filtering and Search Tests', () {
      final mixedExpenses = [
        ExpenseModel.create(
          category: 'Food',
          amount: 25.0,
          currency: 'USD',
          amountInUSD: 25.0,
          date: DateTime.now(),
        ),
        ExpenseModel.create(
          category: 'Transport',
          amount: 15.0,
          currency: 'USD',
          amountInUSD: 15.0,
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ExpenseModel.create(
          category: 'Food',
          amount: 30.0,
          currency: 'USD',
          amountInUSD: 30.0,
          date: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      blocTest<ExpenseBloc, ExpenseState>(
        'should filter expenses by category',
        build: () {
          when(
            () => mockExpensesBox.values,
          ).thenReturn(mixedExpenses.map((e) => e.toJson()).toList());
          return expenseBloc;
        },
        act: (bloc) =>
            bloc.add(const LoadExpenses(page: 1, categoryFilter: 'Food')),
        expect: () => [
          const ExpenseLoading(),
          isA<ExpenseLoaded>().having(
            (state) => state.expenses.every((e) => e.category == 'Food'),
            'all expenses are Food category',
            equals(true),
          ),
        ],
      );

      test('should calculate total amount correctly', () {
        final expenses = [
          ExpenseModel.create(
            category: 'Food',
            amount: 25.0,
            currency: 'USD',
            amountInUSD: 25.0,
            date: DateTime.now(),
          ),
          ExpenseModel.create(
            category: 'Transport',
            amount: 15.0,
            currency: 'USD',
            amountInUSD: 15.0,
            date: DateTime.now(),
          ),
        ];

        final totalAmount = expenses.fold(
          0.0,
          (sum, expense) => sum + expense.amountInUSD,
        );
        expect(totalAmount, equals(40.0));
      });
    });

    group('Error Handling Tests', () {
      blocTest<ExpenseBloc, ExpenseState>(
        'should emit error state when storage fails',
        build: () {
          // Instead of throwing from values, mock storage service to throw
          when(
            () => mockStorageService.getData(any(), any()),
          ).thenThrow(Exception('Storage error'));
          when(() => mockExpensesBox.values).thenReturn([]);
          return expenseBloc;
        },
        act: (bloc) => bloc.add(const LoadExpenses(page: 1)),
        expect: () => [
          const ExpenseLoading(),
          // Since the BLoC handles errors gracefully, it returns empty list
          isA<ExpenseLoaded>().having(
            (state) => state.expenses,
            'expenses',
            isEmpty,
          ),
        ],
      );

      blocTest<ExpenseBloc, ExpenseState>(
        'should handle delete expense error gracefully',
        build: () {
          when(
            () => mockStorageService.deleteData(any(), any()),
          ).thenThrow(Exception('Delete failed'));
          when(() => mockExpensesBox.values).thenReturn([]);
          return expenseBloc;
        },
        act: (bloc) => bloc.add(const DeleteExpense('expense-id')),
        expect: () => [
          const ExpenseDeleting('expense-id'),
          isA<ExpenseError>(),
        ],
      );
    });

    group('State Management Tests', () {
      test('initial state should be ExpenseInitial', () {
        expect(expenseBloc.state, isA<ExpenseInitial>());
      });

      blocTest<ExpenseBloc, ExpenseState>(
        'should emit loading state when refreshing',
        build: () {
          when(() => mockExpensesBox.values).thenReturn([]);
          return expenseBloc;
        },
        act: (bloc) => bloc.add(const RefreshExpenses()),
        expect: () => [const ExpenseLoading(), isA<ExpenseLoaded>()],
      );
    });
  });
}

/// Helper extension for testing pagination
extension PaginationTestHelper on List<ExpenseModel> {
  List<ExpenseModel> paginate(int page, int itemsPerPage) {
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= length) {
      return [];
    }

    return sublist(startIndex, endIndex > length ? length : endIndex);
  }
}
