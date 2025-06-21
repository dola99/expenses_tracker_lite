import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../features/expenses/domain/expense_model.dart';
import '../../features/currency/domain/currency_rate_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _expensesBox = AppConstants.expensesBoxKey;
  static const String _incomesBox = AppConstants.incomesBoxKey;
  static const String _userPrefsBox = AppConstants.userPrefsBoxKey;
  static const String _currencyRatesBox = AppConstants.currencyRatesBoxKey;

  Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CurrencyRateModelAdapter());
    }

    await Hive.openBox(_expensesBox);
    await Hive.openBox(_incomesBox);
    await Hive.openBox(_userPrefsBox);
    await Hive.openBox(_currencyRatesBox);
  }

  Box get expensesBox => Hive.box(_expensesBox);

  Box get incomesBox => Hive.box(_incomesBox);

  Box get userPrefsBox => Hive.box(_userPrefsBox);

  Box get currencyRatesBox => Hive.box(_currencyRatesBox);

  Future<void> saveData(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  T? getData<T>(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key) as T?;
  }

  Future<void> deleteData(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  bool hasData(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.containsKey(key);
  }

  Iterable<dynamic> getKeys(String boxName) {
    final box = Hive.box(boxName);
    return box.keys;
  }

  Iterable<dynamic> getValues(String boxName) {
    final box = Hive.box(boxName);
    return box.values;
  }

  Future<void> close() async {
    await Hive.close();
  }

  Future<void> saveSelectedCurrency(String currency) async {
    await saveData(_userPrefsBox, 'selected_currency', currency);
  }

  String getSelectedCurrency() {
    return getData<String>(_userPrefsBox, 'selected_currency') ?? 'USD';
  }

  Future<void> saveUserName(String name) async {
    await saveData(_userPrefsBox, 'user_name', name);
  }

  String getUserName() {
    return getData<String>(_userPrefsBox, 'user_name') ?? 'Shihab Rahman';
  }

  Future<void> saveProfileImagePath(String path) async {
    await saveData(_userPrefsBox, 'profile_image_path', path);
  }

  String? getProfileImagePath() {
    return getData<String>(_userPrefsBox, 'profile_image_path');
  }

  Future<void> saveCurrencyRates(Map<String, double> rates) async {
    final data = {
      'rates': rates,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await saveData(_currencyRatesBox, 'latest_rates', data);
  }

  Map<String, double>? getCurrencyRates() {
    final data = getData<Map>(_currencyRatesBox, 'latest_rates');
    if (data == null) return null;

    // Check if data is older than 1 hour
    final timestamp = data['timestamp'] as int?;
    if (timestamp != null) {
      final dataTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      if (now.difference(dataTime).inHours > 1) {
        return null; // Data is stale
      }
    }

    final rates = data['rates'] as Map?;
    return rates?.cast<String, double>();
  }
}
