import 'package:equatable/equatable.dart';
import '../../domain/income_model.dart';

abstract class IncomeState extends Equatable {
  const IncomeState();

  @override
  List<Object?> get props => [];
}

class IncomeInitial extends IncomeState {
  const IncomeInitial();
}

class IncomeLoading extends IncomeState {
  const IncomeLoading();
}

class IncomeLoaded extends IncomeState {
  final List<IncomeModel> incomes;

  const IncomeLoaded(this.incomes);

  @override
  List<Object?> get props => [incomes];
}

class IncomeError extends IncomeState {
  final String message;

  const IncomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class IncomeOperationSuccess extends IncomeState {
  final String message;
  final List<IncomeModel> incomes;

  const IncomeOperationSuccess(this.message, this.incomes);

  @override
  List<Object?> get props => [message, incomes];
}
