import 'package:equatable/equatable.dart';
import '../../domain/expense_model.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoadingMore extends ExpenseState {
  final List<ExpenseModel> currentExpenses;

  const ExpenseLoadingMore(this.currentExpenses);

  @override
  List<Object?> get props => [currentExpenses];
}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final bool hasReachedMax;
  final int currentPage;
  final String? activeCategory;
  final String? activeDateFilter;
  final double totalAmount;

  const ExpenseLoaded({
    required this.expenses,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.activeCategory,
    this.activeDateFilter,
    this.totalAmount = 0.0,
  });

  ExpenseLoaded copyWith({
    List<ExpenseModel>? expenses,
    bool? hasReachedMax,
    int? currentPage,
    String? activeCategory,
    String? activeDateFilter,
    double? totalAmount,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      activeCategory: activeCategory ?? this.activeCategory,
      activeDateFilter: activeDateFilter ?? this.activeDateFilter,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  List<Object?> get props => [
    expenses,
    hasReachedMax,
    currentPage,
    activeCategory,
    activeDateFilter,
    totalAmount,
  ];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;
  final List<ExpenseModel> expenses;

  const ExpenseOperationSuccess({
    required this.message,
    required this.expenses,
  });

  @override
  List<Object?> get props => [message, expenses];
}

class ExpenseAdding extends ExpenseState {
  const ExpenseAdding();
}

class ExpenseUpdating extends ExpenseState {
  final String expenseId;

  const ExpenseUpdating(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class ExpenseDeleting extends ExpenseState {
  final String expenseId;

  const ExpenseDeleting(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}
