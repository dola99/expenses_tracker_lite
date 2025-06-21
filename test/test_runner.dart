import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'features/expenses/domain/expense_model_test.dart' as expense_model_test;
import 'features/currency/data/currency_service_test.dart'
    as currency_service_test;
import 'features/expenses/presentation/bloc/expense_bloc_test.dart'
    as expense_bloc_test;
import 'features/expenses/presentation/widgets/expense_widgets_test.dart'
    as expense_widgets_test;
import 'core/utils/date_utils_test.dart' as date_utils_test;

void main() {
  group('🧪 Expense Tracker Test Suite', () {
    group('📊 Domain Layer Tests', () {
      expense_model_test.main();
    });

    group('💱 Currency Service Tests', () {
      currency_service_test.main();
    });

    group('🔄 BLoC Logic Tests', () {
      expense_bloc_test.main();
    });

    group('🎨 Widget Tests', () {
      expense_widgets_test.main();
    });

    group('📅 Utility Tests', () {
      date_utils_test.main();
    });
  });
}
