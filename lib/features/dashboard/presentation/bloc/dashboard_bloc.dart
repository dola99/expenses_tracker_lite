import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../../expenses/domain/expense_model.dart';
import '../../../income/domain/income_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final StorageService _storageService;
  StreamSubscription<AppEvent>? _eventSubscription;

  DashboardBloc({StorageService? storageService})
    : _storageService = storageService ?? StorageService(),
      super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<UpdateDateFilter>(_onUpdateDateFilter);

    // Listen to app events for auto-refresh
    _eventSubscription = AppEventBus().eventStream.listen((event) {
      if (event is IncomeDataChanged || event is ExpenseDataChanged) {
        add(const RefreshDashboard());
      }
    });
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(const DashboardLoading());

      final summary = await _calculateDashboardSummary(
        dateFilter: event.dateFilter ?? 'This Month',
      );

      emit(DashboardLoaded(summary));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    try {
      if (currentState is DashboardLoaded) {
        emit(DashboardRefreshing(currentState.summary));
      } else {
        emit(const DashboardLoading());
      }

      final summary = await _calculateDashboardSummary(
        dateFilter: currentState is DashboardLoaded
            ? currentState.summary.selectedDateFilter
            : 'This Month',
      );

      emit(DashboardLoaded(summary));
    } catch (e) {
      emit(DashboardError('Failed to refresh dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDateFilter(
    UpdateDateFilter event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(const DashboardLoading());

      final summary = await _calculateDashboardSummary(
        dateFilter: event.dateFilter,
      );

      emit(DashboardLoaded(summary));
    } catch (e) {
      emit(DashboardError('Failed to update filter: ${e.toString()}'));
    }
  }

  Future<DashboardSummary> _calculateDashboardSummary({
    required String dateFilter,
  }) async {
    final allExpenses = await _getAllExpenses();
    final filteredExpenses = _filterExpensesByDate(allExpenses, dateFilter);

    final allIncomes = await _getAllIncomes();
    final filteredIncomes = _filterIncomesByDate(allIncomes, dateFilter);

    final totalExpenses = filteredExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amountInUSD,
    );

    final totalIncome = filteredIncomes.fold(
      0.0,
      (sum, income) => sum + income.amountInUSD,
    );

    final totalBalance = totalIncome - totalExpenses;

    final categoryBreakdown = _calculateCategoryBreakdown(filteredExpenses);

    return DashboardSummary(
      totalBalance: totalBalance,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      selectedDateFilter: dateFilter,
      categoryBreakdown: categoryBreakdown,
    );
  }

  Future<List<ExpenseModel>> _getAllExpenses() async {
    try {
      final expensesBox = _storageService.expensesBox;
      final expenses = expensesBox.values
          .cast<Map>()
          .map((data) => ExpenseModel.fromJson(data.cast<String, dynamic>()))
          .toList();

      expenses.sort((a, b) => b.date.compareTo(a.date));

      return expenses;
    } catch (e) {
      return [];
    }
  }

  List<ExpenseModel> _filterExpensesByDate(
    List<ExpenseModel> expenses,
    String dateFilter,
  ) {
    final dateRange = AppDateUtils.getDateRangeForFilter(dateFilter);
    return expenses
        .where((expense) => AppDateUtils.isDateInRange(expense.date, dateRange))
        .toList();
  }

  List<CategoryExpense> _calculateCategoryBreakdown(
    List<ExpenseModel> expenses,
  ) {
    final categoryMap = <String, List<ExpenseModel>>{};

    for (final expense in expenses) {
      categoryMap.putIfAbsent(expense.category, () => []).add(expense);
    }

    return categoryMap.entries.map((entry) {
      final category = entry.key;
      final categoryExpenses = entry.value;
      final totalAmount = categoryExpenses.fold(
        0.0,
        (sum, expense) => sum + expense.amountInUSD,
      );

      return CategoryExpense(
        category: category,
        amount: totalAmount,
        count: categoryExpenses.length,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
  }

  Future<List<IncomeModel>> _getAllIncomes() async {
    try {
      final incomesBox = _storageService.incomesBox;
      final incomes = incomesBox.values
          .cast<Map>()
          .map((data) => IncomeModel.fromJson(data.cast<String, dynamic>()))
          .toList();

      incomes.sort((a, b) => b.date.compareTo(a.date));
      return incomes;
    } catch (e) {
      return [];
    }
  }

  List<IncomeModel> _filterIncomesByDate(
    List<IncomeModel> incomes,
    String dateFilter,
  ) {
    final dateRange = AppDateUtils.getDateRangeForFilter(dateFilter);
    return incomes
        .where((income) => AppDateUtils.isDateInRange(income.date, dateRange))
        .toList();
  }
}
