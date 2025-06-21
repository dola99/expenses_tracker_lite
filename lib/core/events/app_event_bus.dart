import 'dart:async';

class AppEventBus {
  static final AppEventBus _instance = AppEventBus._internal();
  factory AppEventBus() => _instance;
  AppEventBus._internal();

  final StreamController<AppEvent> _eventController =
      StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get eventStream => _eventController.stream;

  void emit(AppEvent event) {
    _eventController.add(event);
  }

  void dispose() {
    _eventController.close();
  }
}

abstract class AppEvent {}

class IncomeDataChanged extends AppEvent {}

class ExpenseDataChanged extends AppEvent {}
