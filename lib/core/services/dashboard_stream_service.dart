import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage/storage_service.dart';

class DashboardStreamService {
  static final DashboardStreamService _instance =
      DashboardStreamService._internal();
  factory DashboardStreamService() => _instance;
  DashboardStreamService._internal();

  final StorageService _storageService = StorageService();
  final StreamController<bool> _dataChangedController =
      StreamController<bool>.broadcast();

  StreamSubscription<BoxEvent>? _expensesSubscription;
  StreamSubscription<BoxEvent>? _incomesSubscription;

  Stream<bool> get dataChangedStream => _dataChangedController.stream;

  void initialize() {
    // Listen to expenses box changes
    _expensesSubscription = _storageService.expensesBox.watch().listen((event) {
      _dataChangedController.add(true);
    });

    // Listen to incomes box changes
    _incomesSubscription = _storageService.incomesBox.watch().listen((event) {
      _dataChangedController.add(true);
    });
  }

  void dispose() {
    _expensesSubscription?.cancel();
    _incomesSubscription?.cancel();
    _dataChangedController.close();
  }
}
