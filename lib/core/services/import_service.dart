import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../features/expenses/domain/expense_model.dart';
import '../../features/income/domain/income_model.dart';
import '../constants/app_constants.dart';

class ImportService {
  static const String _tag = 'ImportService';

  /// Import data from a file
  static Future<ImportResult> importFromFile() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult.cancelled();
      }

      final file = result.files.first;
      final fileExtension = file.extension?.toLowerCase();

      if (fileExtension == 'csv') {
        return await _importFromCSV(file);
      } else if (fileExtension == 'json') {
        return await _importFromJSON(file);
      } else {
        return ImportResult.error(
          'Unsupported file format. Please select a CSV or JSON file.',
        );
      }
    } catch (e) {
      debugPrint('$_tag: Error importing file: $e');
      return ImportResult.error('Failed to import file: ${e.toString()}');
    }
  }

  /// Import from CSV file
  static Future<ImportResult> _importFromCSV(PlatformFile file) async {
    try {
      String csvContent;

      if (kIsWeb) {
        if (file.bytes != null) {
          csvContent = utf8.decode(file.bytes!);
        } else {
          return ImportResult.error('Failed to read file content on web.');
        }
      } else {
        if (file.path == null) {
          return ImportResult.error('File path is null.');
        }
        final csvFile = File(file.path!);
        csvContent = await csvFile.readAsString();
      }

      // Parse CSV
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvContent,
      );

      if (csvTable.isEmpty) {
        return ImportResult.error('CSV file is empty.');
      }

      // Check if it's expenses or income based on headers
      final headers = csvTable.first
          .map((e) => e.toString().toLowerCase())
          .toList();

      if (headers.contains('category') && headers.contains('amount')) {
        if (headers.contains('expense') || headers.contains('type')) {
          // Try to determine if it's expenses or income
          return await _parseExpensesAndIncomeFromCSV(csvTable);
        } else {
          // Assume it's expenses if no clear indicator
          return await _parseExpensesFromCSV(csvTable);
        }
      } else {
        return ImportResult.error(
          'Invalid CSV format. Required columns: Date, Amount, Category, Description',
        );
      }
    } catch (e) {
      debugPrint('$_tag: Error parsing CSV: $e');
      return ImportResult.error('Failed to parse CSV file: ${e.toString()}');
    }
  }

  /// Import from JSON file
  static Future<ImportResult> _importFromJSON(PlatformFile file) async {
    try {
      String jsonContent;

      if (kIsWeb) {
        if (file.bytes != null) {
          jsonContent = utf8.decode(file.bytes!);
        } else {
          return ImportResult.error('Failed to read file content on web.');
        }
      } else {
        if (file.path == null) {
          return ImportResult.error('File path is null.');
        }
        final jsonFile = File(file.path!);
        jsonContent = await jsonFile.readAsString();
      }

      final Map<String, dynamic> data = json.decode(jsonContent);

      List<ExpenseModel> expenses = [];
      List<IncomeModel> incomes = [];

      // Parse expenses
      if (data.containsKey('expenses')) {
        final expensesData = data['expenses'] as List;
        for (final expenseData in expensesData) {
          try {
            final expense = ExpenseModel.fromJson(expenseData);
            expenses.add(expense);
          } catch (e) {
            debugPrint('$_tag: Failed to parse expense: $e');
          }
        }
      }

      // Parse incomes
      if (data.containsKey('incomes')) {
        final incomesData = data['incomes'] as List;
        for (final incomeData in incomesData) {
          try {
            final income = IncomeModel.fromJson(incomeData);
            incomes.add(income);
          } catch (e) {
            debugPrint('$_tag: Failed to parse income: $e');
          }
        }
      }

      return ImportResult.success(expenses, incomes);
    } catch (e) {
      debugPrint('$_tag: Error parsing JSON: $e');
      return ImportResult.error('Failed to parse JSON file: ${e.toString()}');
    }
  }

  /// Parse expenses from CSV
  static Future<ImportResult> _parseExpensesFromCSV(
    List<List<dynamic>> csvTable,
  ) async {
    final List<ExpenseModel> expenses = [];
    final headers = csvTable.first
        .map((e) => e.toString().toLowerCase())
        .toList();

    // Find column indices
    final dateIndex = _findColumnIndex(headers, [
      'date',
      'created_at',
      'timestamp',
    ]);
    final amountIndex = _findColumnIndex(headers, ['amount', 'cost', 'price']);
    final categoryIndex = _findColumnIndex(headers, [
      'category',
      'type',
      'expense_category',
    ]);
    final descriptionIndex = _findColumnIndex(headers, [
      'description',
      'note',
      'memo',
      'title',
    ]);

    if (dateIndex == -1 || amountIndex == -1 || categoryIndex == -1) {
      return ImportResult.error(
        'Required columns not found. Need: Date, Amount, Category',
      );
    }

    // Parse data rows (skip header)
    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];

      try {
        final dateStr = row[dateIndex].toString();
        final amountStr = row[amountIndex].toString();
        final categoryStr = row[categoryIndex].toString();
        final description = descriptionIndex != -1
            ? row[descriptionIndex].toString()
            : '';

        // Parse date
        DateTime date;
        try {
          date = DateTime.parse(dateStr);
        } catch (e) {
          // Try different date formats
          final parts = dateStr.split(RegExp(r'[\/\-\.]'));
          if (parts.length == 3) {
            date = DateTime(
              int.parse(parts[2]),
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
          } else {
            continue; // Skip invalid date
          }
        }

        // Parse amount
        final amount = double.tryParse(
          amountStr.replaceAll(RegExp(r'[^\d\.]'), ''),
        );
        if (amount == null || amount <= 0) continue;

        // Parse category
        final category = _parseExpenseCategory(categoryStr);

        final expense = ExpenseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          amount: amount,
          category: category,
          description: description.isNotEmpty
              ? description
              : 'Imported expense',
          date: date,
          currency: 'USD', // Default currency
          amountInUSD: amount, // Assume USD for now
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expenses.add(expense);
      } catch (e) {
        debugPrint('$_tag: Failed to parse row $i: $e');
        continue; // Skip invalid rows
      }
    }

    return ImportResult.success(expenses, []);
  }

  /// Parse both expenses and income from CSV with type column
  static Future<ImportResult> _parseExpensesAndIncomeFromCSV(
    List<List<dynamic>> csvTable,
  ) async {
    final List<ExpenseModel> expenses = [];
    final List<IncomeModel> incomes = [];
    final headers = csvTable.first
        .map((e) => e.toString().toLowerCase())
        .toList();

    // Find column indices
    final dateIndex = _findColumnIndex(headers, [
      'date',
      'created_at',
      'timestamp',
    ]);
    final amountIndex = _findColumnIndex(headers, ['amount', 'cost', 'price']);
    final categoryIndex = _findColumnIndex(headers, [
      'category',
      'type',
      'expense_category',
    ]);
    final descriptionIndex = _findColumnIndex(headers, [
      'description',
      'note',
      'memo',
      'title',
    ]);
    final typeIndex = _findColumnIndex(headers, [
      'type',
      'transaction_type',
      'kind',
    ]);

    if (dateIndex == -1 || amountIndex == -1 || categoryIndex == -1) {
      return ImportResult.error(
        'Required columns not found. Need: Date, Amount, Category',
      );
    }

    // Parse data rows (skip header)
    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];

      try {
        final dateStr = row[dateIndex].toString();
        final amountStr = row[amountIndex].toString();
        final categoryStr = row[categoryIndex].toString();
        final description = descriptionIndex != -1
            ? row[descriptionIndex].toString()
            : '';
        final typeStr = typeIndex != -1
            ? row[typeIndex].toString().toLowerCase()
            : '';

        // Parse date
        DateTime date;
        try {
          date = DateTime.parse(dateStr);
        } catch (e) {
          final parts = dateStr.split(RegExp(r'[\/\-\.]'));
          if (parts.length == 3) {
            date = DateTime(
              int.parse(parts[2]),
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
          } else {
            continue;
          }
        }

        // Parse amount
        final amount = double.tryParse(
          amountStr.replaceAll(RegExp(r'[^\d\.]'), ''),
        );
        if (amount == null || amount <= 0) continue;

        final isIncome =
            typeStr.contains('income') ||
            typeStr.contains('earning') ||
            typeStr.contains('+');

        if (isIncome) {
          final category = _parseIncomeCategory(categoryStr);
          final income = IncomeModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            amount: amount,
            category: category,
            description: description.isNotEmpty
                ? description
                : 'Imported income',
            date: date,
            currency: 'USD',
            amountInUSD: amount,
            createdAt: DateTime.now(),
          );
          incomes.add(income);
        } else {
          final category = _parseExpenseCategory(categoryStr);
          final expense = ExpenseModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            amount: amount,
            category: category,
            description: description.isNotEmpty
                ? description
                : 'Imported expense',
            date: date,
            currency: 'USD',
            amountInUSD: amount,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          expenses.add(expense);
        }
      } catch (e) {
        debugPrint('$_tag: Failed to parse row $i: $e');
        continue;
      }
    }

    return ImportResult.success(expenses, incomes);
  }

  /// Find column index by possible names
  static int _findColumnIndex(
    List<String> headers,
    List<String> possibleNames,
  ) {
    for (final name in possibleNames) {
      final index = headers.indexWhere((header) => header.contains(name));
      if (index != -1) return index;
    }
    return -1;
  }

  /// Parse expense category from string
  static String _parseExpenseCategory(String categoryStr) {
    final category = categoryStr.toLowerCase().trim();

    if (category.contains('food') ||
        category.contains('restaurant') ||
        category.contains('meal')) {
      return AppConstants.defaultCategories.firstWhere(
        (cat) => cat.toLowerCase().contains('food'),
        orElse: () => 'Food',
      );
    } else if (category.contains('transport') ||
        category.contains('travel') ||
        category.contains('car') ||
        category.contains('fuel')) {
      return AppConstants.defaultCategories.firstWhere(
        (cat) => cat.toLowerCase().contains('transport'),
        orElse: () => 'Transportation',
      );
    } else if (category.contains('health') ||
        category.contains('medical') ||
        category.contains('hospital')) {
      return AppConstants.defaultCategories.firstWhere(
        (cat) => cat.toLowerCase().contains('health'),
        orElse: () => 'Healthcare',
      );
    } else if (category.contains('shop') ||
        category.contains('retail') ||
        category.contains('store')) {
      return AppConstants.defaultCategories.firstWhere(
        (cat) => cat.toLowerCase().contains('shop'),
        orElse: () => 'Shopping',
      );
    } else if (category.contains('entertain') ||
        category.contains('movie') ||
        category.contains('game')) {
      return AppConstants.defaultCategories.firstWhere(
        (cat) => cat.toLowerCase().contains('entertain'),
        orElse: () => 'Entertainment',
      );
    } else if (category.contains('education') ||
        category.contains('school') ||
        category.contains('course')) {
      return AppConstants.defaultCategories.firstWhere(
        (cat) => cat.toLowerCase().contains('education'),
        orElse: () => 'Education',
      );
    } else if (category.contains('bill') ||
        category.contains('utility') ||
        category.contains('rent')) {
      return AppConstants.defaultCategories.firstWhere(
        (cat) => cat.toLowerCase().contains('bill'),
        orElse: () => 'Bills',
      );
    } else {
      return 'Others';
    }
  }

  /// Parse income category from string
  static String _parseIncomeCategory(String categoryStr) {
    final category = categoryStr.toLowerCase().trim();

    if (category.contains('salary') ||
        category.contains('wage') ||
        category.contains('job')) {
      return IncomeCategories.salary;
    } else if (category.contains('freelance') ||
        category.contains('contract') ||
        category.contains('gig')) {
      return IncomeCategories.freelance;
    } else if (category.contains('business') ||
        category.contains('profit') ||
        category.contains('revenue')) {
      return IncomeCategories.business;
    } else if (category.contains('invest') ||
        category.contains('stock') ||
        category.contains('dividend')) {
      return IncomeCategories.investment;
    } else if (category.contains('rental') ||
        category.contains('rent') ||
        category.contains('property')) {
      return IncomeCategories.rental;
    } else if (category.contains('bonus') ||
        category.contains('award') ||
        category.contains('commission')) {
      return IncomeCategories.bonus;
    } else if (category.contains('gift') || category.contains('present')) {
      return IncomeCategories.gift;
    } else {
      return IncomeCategories.other;
    }
  }
}

/// Result of import operation
class ImportResult {
  final bool success;
  final String? error;
  final List<ExpenseModel> expenses;
  final List<IncomeModel> incomes;
  final bool cancelled;

  ImportResult._(
    this.success,
    this.error,
    this.expenses,
    this.incomes,
    this.cancelled,
  );

  factory ImportResult.success(
    List<ExpenseModel> expenses,
    List<IncomeModel> incomes,
  ) {
    return ImportResult._(true, null, expenses, incomes, false);
  }

  factory ImportResult.error(String error) {
    return ImportResult._(false, error, [], [], false);
  }

  factory ImportResult.cancelled() {
    return ImportResult._(false, null, [], [], true);
  }

  int get totalItems => expenses.length + incomes.length;
}
