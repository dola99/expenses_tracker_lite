import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../currency/data/currency_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/events/app_event_bus.dart';
import '../../domain/income_model.dart';
import 'income_event.dart';
import 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final StorageService _storageService;
  final CurrencyService _currencyService;

  IncomeBloc({StorageService? storageService, CurrencyService? currencyService})
    : _storageService = storageService ?? StorageService(),
      _currencyService = currencyService ?? CurrencyService(),
      super(const IncomeInitial()) {
    on<LoadIncomes>(_onLoadIncomes);
    on<AddIncome>(_onAddIncome);
    on<UpdateIncome>(_onUpdateIncome);
    on<DeleteIncome>(_onDeleteIncome);
  }

  Future<void> _onLoadIncomes(
    LoadIncomes event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      emit(const IncomeLoading());
      final incomes = await _getAllIncomes();
      emit(IncomeLoaded(incomes));
    } catch (e) {
      emit(IncomeError('Failed to load incomes: ${e.toString()}'));
    }
  }

  Future<void> _onAddIncome(AddIncome event, Emitter<IncomeState> emit) async {
    try {
      emit(const IncomeLoading());

      final amountInUSD = await _currencyService.convertToUSD(
        event.amount,
        event.currency,
      );

      final income = IncomeModel(
        id: const Uuid().v4(),
        category: event.category,
        amount: event.amount,
        amountInUSD: amountInUSD,
        currency: event.currency,
        description: event.description,
        date: event.date,
        createdAt: DateTime.now(),
      );

      await _saveIncome(income);

      // Notify other parts of the app that income data changed
      AppEventBus().emit(IncomeDataChanged());

      // Automatically refresh the list after successful add
      final incomes = await _getAllIncomes();
      emit(IncomeLoaded(incomes));
    } catch (e) {
      emit(IncomeError('Failed to add income: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateIncome(
    UpdateIncome event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      emit(const IncomeLoading());

      final amountInUSD = await _currencyService.convertToUSD(
        event.amount,
        event.currency,
      );

      final existingIncomes = await _getAllIncomes();
      final existingIncome = existingIncomes.firstWhere(
        (income) => income.id == event.id,
      );

      final updatedIncome = existingIncome.copyWith(
        category: event.category,
        amount: event.amount,
        amountInUSD: amountInUSD,
        currency: event.currency,
        description: event.description,
        date: event.date,
      );

      await _updateIncome(updatedIncome);

      // Notify other parts of the app that income data changed
      AppEventBus().emit(IncomeDataChanged());

      // Automatically refresh the list after successful update
      final incomes = await _getAllIncomes();
      emit(IncomeLoaded(incomes));
    } catch (e) {
      emit(IncomeError('Failed to update income: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteIncome(
    DeleteIncome event,
    Emitter<IncomeState> emit,
  ) async {
    try {
      emit(const IncomeLoading());
      await _deleteIncome(event.id);

      // Notify other parts of the app that income data changed
      AppEventBus().emit(IncomeDataChanged());

      // Automatically refresh the list after successful delete
      final incomes = await _getAllIncomes();
      emit(IncomeLoaded(incomes));
    } catch (e) {
      emit(IncomeError('Failed to delete income: ${e.toString()}'));
    }
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

  Future<void> _saveIncome(IncomeModel income) async {
    final incomesBox = _storageService.incomesBox;
    await incomesBox.put(income.id, income.toJson());
  }

  Future<void> _updateIncome(IncomeModel income) async {
    final incomesBox = _storageService.incomesBox;
    await incomesBox.put(income.id, income.toJson());
  }

  Future<void> _deleteIncome(String id) async {
    final incomesBox = _storageService.incomesBox;
    await incomesBox.delete(id);
  }
}
