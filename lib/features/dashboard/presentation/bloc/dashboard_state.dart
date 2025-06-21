import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final String selectedDateFilter;
  final List<CategoryExpense> categoryBreakdown;

  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.selectedDateFilter,
    required this.categoryBreakdown,
  });

  @override
  List<Object?> get props => [
    totalBalance,
    totalIncome,
    totalExpenses,
    selectedDateFilter,
    categoryBreakdown,
  ];
}

class CategoryExpense extends Equatable {
  final String category;
  final double amount;
  final int count;

  const CategoryExpense({
    required this.category,
    required this.amount,
    required this.count,
  });

  @override
  List<Object?> get props => [category, amount, count];
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;

  const DashboardLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class DashboardRefreshing extends DashboardState {
  final DashboardSummary currentSummary;

  const DashboardRefreshing(this.currentSummary);

  @override
  List<Object?> get props => [currentSummary];
}
