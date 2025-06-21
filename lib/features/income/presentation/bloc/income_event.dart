import 'package:equatable/equatable.dart';

abstract class IncomeEvent extends Equatable {
  const IncomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadIncomes extends IncomeEvent {
  const LoadIncomes();
}

class AddIncome extends IncomeEvent {
  final String category;
  final double amount;
  final String currency;
  final String? description;
  final DateTime date;

  const AddIncome({
    required this.category,
    required this.amount,
    required this.currency,
    this.description,
    required this.date,
  });

  @override
  List<Object?> get props => [category, amount, currency, description, date];
}

class UpdateIncome extends IncomeEvent {
  final String id;
  final String category;
  final double amount;
  final String currency;
  final String? description;
  final DateTime date;

  const UpdateIncome({
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
    this.description,
    required this.date,
  });

  @override
  List<Object?> get props => [
    id,
    category,
    amount,
    currency,
    description,
    date,
  ];
}

class DeleteIncome extends IncomeEvent {
  final String id;

  const DeleteIncome(this.id);

  @override
  List<Object?> get props => [id];
}
