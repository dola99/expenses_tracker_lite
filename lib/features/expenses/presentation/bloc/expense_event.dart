import 'package:equatable/equatable.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {
  final int page;
  final String? categoryFilter;
  final String? dateFilter;

  const LoadExpenses({this.page = 1, this.categoryFilter, this.dateFilter});

  @override
  List<Object?> get props => [page, categoryFilter, dateFilter];
}

class AddExpense extends ExpenseEvent {
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String? description;
  final String? receiptPath;

  const AddExpense({
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    this.description,
    this.receiptPath,
  });

  @override
  List<Object?> get props => [
    category,
    amount,
    currency,
    date,
    description,
    receiptPath,
  ];
}

class UpdateExpense extends ExpenseEvent {
  final String expenseId;
  final String? category;
  final double? amount;
  final String? currency;
  final DateTime? date;
  final String? description;
  final String? receiptPath;

  const UpdateExpense({
    required this.expenseId,
    this.category,
    this.amount,
    this.currency,
    this.date,
    this.description,
    this.receiptPath,
  });

  @override
  List<Object?> get props => [
    expenseId,
    category,
    amount,
    currency,
    date,
    description,
    receiptPath,
  ];
}

class DeleteExpense extends ExpenseEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class LoadMoreExpenses extends ExpenseEvent {
  final String? categoryFilter;
  final String? dateFilter;

  const LoadMoreExpenses({this.categoryFilter, this.dateFilter});

  @override
  List<Object?> get props => [categoryFilter, dateFilter];
}

class FilterExpenses extends ExpenseEvent {
  final String? categoryFilter;
  final String? dateFilter;

  const FilterExpenses({this.categoryFilter, this.dateFilter});

  @override
  List<Object?> get props => [categoryFilter, dateFilter];
}

class RefreshExpenses extends ExpenseEvent {
  const RefreshExpenses();
}
