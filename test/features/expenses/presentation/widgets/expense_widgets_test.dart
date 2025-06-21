import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/expenses/domain/expense_model.dart';

// Mock classes
class MockExpenseBloc extends Mock implements ExpenseBloc {}

void main() {
  group('Expense Widget Tests', () {
    late MockExpenseBloc mockExpenseBloc;

    setUp(() {
      mockExpenseBloc = MockExpenseBloc();
      // Mock the close method to return a Future<void>
      when(() => mockExpenseBloc.close()).thenAnswer((_) async {});
    });

    testWidgets('should display expenses when loaded', (
      WidgetTester tester,
    ) async {
      // Arrange
      final mockExpenses = [
        ExpenseModel.create(
          category: 'Food',
          amount: 25.50,
          currency: 'USD',
          amountInUSD: 25.50,
          date: DateTime.now(),
          description: 'Lunch',
        ),
        ExpenseModel.create(
          category: 'Transport',
          amount: 15.75,
          currency: 'USD',
          amountInUSD: 15.75,
          date: DateTime.now(),
          description: 'Bus ticket',
        ),
      ];

      when(() => mockExpenseBloc.state).thenReturn(
        ExpenseLoaded(
          expenses: mockExpenses,
          totalAmount: 41.25,
          hasReachedMax: false,
          currentPage: 1,
        ),
      );

      when(() => mockExpenseBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          ExpenseLoaded(
            expenses: mockExpenses,
            totalAmount: 41.25,
            hasReachedMax: false,
            currentPage: 1,
          ),
        ]),
      );

      // Create test widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ExpenseBloc>(
            create: (_) => mockExpenseBloc,
            child: const TestExpenseListWidget(),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('\$25.50'), findsOneWidget);
      expect(find.text('\$15.75'), findsOneWidget);
      expect(find.text('Total: \$41.25'), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockExpenseBloc.state).thenReturn(const ExpenseLoading());
      when(
        () => mockExpenseBloc.stream,
      ).thenAnswer((_) => Stream.fromIterable([const ExpenseLoading()]));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ExpenseBloc>(
            create: (_) => mockExpenseBloc,
            child: const TestExpenseListWidget(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when error occurs', (
      WidgetTester tester,
    ) async {
      // Arrange
      const errorMessage = 'Failed to load expenses';
      when(
        () => mockExpenseBloc.state,
      ).thenReturn(const ExpenseError(errorMessage));
      when(() => mockExpenseBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([const ExpenseError(errorMessage)]),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ExpenseBloc>(
            create: (_) => mockExpenseBloc,
            child: const TestExpenseListWidget(),
          ),
        ),
      );

      // Assert
      expect(find.text('Error: $errorMessage'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display empty state when no expenses', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockExpenseBloc.state).thenReturn(
        const ExpenseLoaded(
          expenses: [],
          totalAmount: 0.0,
          hasReachedMax: true,
          currentPage: 1,
        ),
      );

      when(() => mockExpenseBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const ExpenseLoaded(
            expenses: [],
            totalAmount: 0.0,
            hasReachedMax: true,
            currentPage: 1,
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ExpenseBloc>(
            create: (_) => mockExpenseBloc,
            child: const TestExpenseListWidget(),
          ),
        ),
      );

      // Assert
      expect(find.text('No expenses found'), findsOneWidget);
      expect(find.text('Add your first expense'), findsOneWidget);
    });

    group('Form Validation Tests', () {
      testWidgets('should validate expense form fields', (
        WidgetTester tester,
      ) async {
        // Create test form widget
        await tester.pumpWidget(
          const MaterialApp(home: TestExpenseFormWidget()),
        );

        // Test empty category validation
        await tester.tap(find.text('Save'));
        await tester.pump();
        expect(find.text('Category is required'), findsOneWidget);

        // Test invalid amount validation
        await tester.enterText(find.byKey(const Key('amount_field')), '-10');
        await tester.tap(find.text('Save'));
        await tester.pump();
        expect(find.text('Amount must be positive'), findsOneWidget);

        // Test valid form submission
        await tester.enterText(find.byKey(const Key('category_field')), 'Food');
        await tester.enterText(find.byKey(const Key('amount_field')), '25.50');
        await tester.tap(find.text('Save'));
        await tester.pump();

        // Should not show validation errors
        expect(find.text('Category is required'), findsNothing);
        expect(find.text('Amount must be positive'), findsNothing);
      });

      testWidgets('should handle currency selection', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(home: TestExpenseFormWidget()),
        );

        // Test currency dropdown
        await tester.tap(find.byKey(const Key('currency_dropdown')));
        await tester.pumpAndSettle();

        expect(find.text('USD'), findsWidgets);
        expect(find.text('EUR'), findsOneWidget);
        expect(find.text('GBP'), findsOneWidget);

        // Select EUR
        await tester.tap(find.text('EUR').last);
        await tester.pumpAndSettle();

        // Verify selection
        expect(find.text('EUR'), findsOneWidget);
      });
    });

    group('Pagination UI Tests', () {
      testWidgets('should show load more button when more expenses available', (
        WidgetTester tester,
      ) async {
        // Arrange
        final mockExpenses = List.generate(
          10,
          (index) => ExpenseModel.create(
            category: 'Category $index',
            amount: (index + 1) * 10.0,
            currency: 'USD',
            amountInUSD: (index + 1) * 10.0,
            date: DateTime.now(),
          ),
        );

        when(() => mockExpenseBloc.state).thenReturn(
          ExpenseLoaded(
            expenses: mockExpenses,
            totalAmount: 550.0,
            hasReachedMax: false,
            currentPage: 1,
          ),
        );

        when(() => mockExpenseBloc.stream).thenAnswer(
          (_) => Stream.fromIterable([
            ExpenseLoaded(
              expenses: mockExpenses,
              totalAmount: 550.0,
              hasReachedMax: false,
              currentPage: 1,
            ),
          ]),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<ExpenseBloc>(
              create: (_) => mockExpenseBloc,
              child: const TestExpenseListWidget(),
            ),
          ),
        );

        // Assert
        expect(find.text('Load More'), findsOneWidget);
      });

      testWidgets('should hide load more button when all expenses loaded', (
        WidgetTester tester,
      ) async {
        // Arrange
        final mockExpenses = [
          ExpenseModel.create(
            category: 'Food',
            amount: 25.50,
            currency: 'USD',
            amountInUSD: 25.50,
            date: DateTime.now(),
          ),
        ];

        when(() => mockExpenseBloc.state).thenReturn(
          ExpenseLoaded(
            expenses: mockExpenses,
            totalAmount: 25.50,
            hasReachedMax: true,
            currentPage: 1,
          ),
        );

        when(() => mockExpenseBloc.stream).thenAnswer(
          (_) => Stream.fromIterable([
            ExpenseLoaded(
              expenses: mockExpenses,
              totalAmount: 25.50,
              hasReachedMax: true,
              currentPage: 1,
            ),
          ]),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<ExpenseBloc>(
              create: (_) => mockExpenseBloc,
              child: const TestExpenseListWidget(),
            ),
          ),
        );

        // Assert
        expect(find.text('Load More'), findsNothing);
      });
    });
  });
}

// Test widget for expense list
class TestExpenseListWidget extends StatelessWidget {
  const TestExpenseListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExpenseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(onPressed: () {}, child: const Text('Retry')),
                ],
              ),
            );
          }

          if (state is ExpenseLoaded) {
            if (state.expenses.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No expenses found'),
                    Text('Add your first expense'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Text('Total: \$${state.totalAmount.toStringAsFixed(2)}'),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = state.expenses[index];
                      return ListTile(
                        title: Text(expense.category),
                        subtitle: Text(expense.description ?? ''),
                        trailing: Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                ),
                if (!state.hasReachedMax)
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Load More'),
                  ),
              ],
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

// Test widget for expense form
class TestExpenseFormWidget extends StatefulWidget {
  const TestExpenseFormWidget({super.key});

  @override
  State<TestExpenseFormWidget> createState() => _TestExpenseFormWidgetState();
}

class _TestExpenseFormWidgetState extends State<TestExpenseFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const Key('category_field'),
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('amount_field'),
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Amount must be positive';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                key: const Key('currency_dropdown'),
                value: _selectedCurrency,
                decoration: const InputDecoration(labelText: 'Currency'),
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.validate();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
