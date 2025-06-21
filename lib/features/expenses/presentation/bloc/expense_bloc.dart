import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../currency/data/currency_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/expense_model.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final StorageService _storageService;
  final CurrencyService _currencyService;

  static const int _itemsPerPage = AppConstants.itemsPerPage;

  ExpenseBloc({
    StorageService? storageService,
    CurrencyService? currencyService,
  }) : _storageService = storageService ?? StorageService(),
       _currencyService = currencyService ?? CurrencyService(),
       super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<LoadMoreExpenses>(_onLoadMoreExpenses);
    on<FilterExpenses>(_onFilterExpenses);
    on<RefreshExpenses>(_onRefreshExpenses);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(const ExpenseLoading());

      final allExpenses = await _getAllExpenses();
      final filteredExpenses = _applyFilters(
        allExpenses,
        categoryFilter: event.categoryFilter,
        dateFilter: event.dateFilter,
      );

      final paginatedExpenses = _paginateExpenses(
        filteredExpenses,
        page: event.page,
      );

      final totalAmount = _calculateTotalAmount(filteredExpenses);

      emit(
        ExpenseLoaded(
          expenses: paginatedExpenses,
          hasReachedMax: paginatedExpenses.length < _itemsPerPage,
          currentPage: event.page,
          activeCategory: event.categoryFilter,
          activeDateFilter: event.dateFilter,
          totalAmount: totalAmount,
        ),
      );
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: ${e.toString()}'));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(const ExpenseAdding());

      // Convert amount to USD
      final amountInUSD = await _currencyService.convertToUSD(
        event.amount,
        event.currency,
      );

      // Create new expense
      final expense = ExpenseModel.create(
        category: event.category,
        amount: event.amount,
        currency: event.currency,
        amountInUSD: amountInUSD,
        date: event.date,
        description: event.description,
        receiptPath: event.receiptPath,
      );

      // Save to storage
      await _saveExpense(expense);

      // Emit event to update dashboard
      AppEventBus().emit(ExpenseDataChanged());

      // Reload expenses
      final allExpenses = await _getAllExpenses();

      emit(
        ExpenseOperationSuccess(
          message: 'Expense added successfully',
          expenses: allExpenses,
        ),
      );

      // Auto-reload the current view
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to add expense: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseUpdating(event.expenseId));

      final allExpenses = await _getAllExpenses();
      final expenseIndex = allExpenses.indexWhere(
        (e) => e.id == event.expenseId,
      );

      if (expenseIndex == -1) {
        emit(const ExpenseError('Expense not found'));
        return;
      }

      final currentExpense = allExpenses[expenseIndex];

      // Calculate new USD amount if currency or amount changed
      double amountInUSD = currentExpense.amountInUSD;
      if (event.amount != null || event.currency != null) {
        final newAmount = event.amount ?? currentExpense.amount;
        final newCurrency = event.currency ?? currentExpense.currency;
        amountInUSD = await _currencyService.convertToUSD(
          newAmount,
          newCurrency,
        );
      }

      // Update expense
      final updatedExpense = currentExpense.copyWith(
        category: event.category,
        amount: event.amount,
        currency: event.currency,
        amountInUSD: amountInUSD,
        date: event.date,
        description: event.description,
        receiptPath: event.receiptPath,
      );

      // Save updated expense
      await _saveExpense(updatedExpense);

      // Emit event to update dashboard
      AppEventBus().emit(ExpenseDataChanged());

      // Reload expenses
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to update expense: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseDeleting(event.expenseId));

      // Delete from storage
      await _storageService.deleteData(
        AppConstants.expensesBoxKey,
        event.expenseId,
      );

      // Emit event to update dashboard
      AppEventBus().emit(ExpenseDataChanged());

      // Reload expenses
      add(const LoadExpenses());
    } catch (e) {
      emit(ExpenseError('Failed to delete expense: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreExpenses(
    LoadMoreExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ExpenseLoaded || currentState.hasReachedMax) {
      return;
    }

    try {
      emit(ExpenseLoadingMore(currentState.expenses));

      final allExpenses = await _getAllExpenses();
      final filteredExpenses = _applyFilters(
        allExpenses,
        categoryFilter: event.categoryFilter,
        dateFilter: event.dateFilter,
      );

      final nextPage = currentState.currentPage + 1;
      final newExpenses = _paginateExpenses(filteredExpenses, page: nextPage);

      final updatedExpenses = List<ExpenseModel>.from(currentState.expenses)
        ..addAll(newExpenses);

      emit(
        currentState.copyWith(
          expenses: updatedExpenses,
          hasReachedMax: newExpenses.length < _itemsPerPage,
          currentPage: nextPage,
        ),
      );
    } catch (e) {
      emit(ExpenseError('Failed to load more expenses: ${e.toString()}'));
    }
  }

  Future<void> _onFilterExpenses(
    FilterExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    add(
      LoadExpenses(
        page: 1,
        categoryFilter: event.categoryFilter,
        dateFilter: event.dateFilter,
      ),
    );
  }

  Future<void> _onRefreshExpenses(
    RefreshExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    String? categoryFilter;
    String? dateFilter;

    if (currentState is ExpenseLoaded) {
      categoryFilter = currentState.activeCategory;
      dateFilter = currentState.activeDateFilter;
    }

    add(
      LoadExpenses(
        page: 1,
        categoryFilter: categoryFilter,
        dateFilter: dateFilter,
      ),
    );
  }

  // Helper methods

  Future<List<ExpenseModel>> _getAllExpenses() async {
    try {
      final expensesBox = _storageService.expensesBox;
      final expenses = expensesBox.values
          .cast<Map>()
          .map((data) => ExpenseModel.fromJson(data.cast<String, dynamic>()))
          .toList();

      // Sort by date (newest first)
      expenses.sort((a, b) => b.date.compareTo(a.date));

      return expenses;
    } catch (e) {
      return [];
    }
  }

  List<ExpenseModel> _applyFilters(
    List<ExpenseModel> expenses, {
    String? categoryFilter,
    String? dateFilter,
  }) {
    var filtered = expenses;

    // Apply category filter
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      filtered = filtered
          .where(
            (expense) =>
                expense.category.toLowerCase() == categoryFilter.toLowerCase(),
          )
          .toList();
    }

    // Apply date filter
    if (dateFilter != null && dateFilter.isNotEmpty) {
      final dateRange = AppDateUtils.getDateRangeForFilter(dateFilter);
      filtered = filtered
          .where(
            (expense) => AppDateUtils.isDateInRange(expense.date, dateRange),
          )
          .toList();
    }

    return filtered;
  }

  List<ExpenseModel> _paginateExpenses(
    List<ExpenseModel> expenses, {
    required int page,
  }) {
    final startIndex = (page - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= expenses.length) {
      return [];
    }

    return expenses.sublist(
      startIndex,
      endIndex > expenses.length ? expenses.length : endIndex,
    );
  }

  double _calculateTotalAmount(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amountInUSD);
  }

  Future<void> _saveExpense(ExpenseModel expense) async {
    await _storageService.saveData(
      AppConstants.expensesBoxKey,
      expense.id,
      expense.toJson(),
    );
  }
}
