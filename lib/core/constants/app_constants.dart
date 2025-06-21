class AppConstants {
  // API Configuration
  static const String currencyApiBaseUrl = 'https://open.er-api.com/v6/latest';
  static const String baseCurrency = 'USD';

  // Pagination
  static const int itemsPerPage = 10;

  // Storage Keys
  static const String expensesBoxKey = 'expenses';
  static const String incomesBoxKey = 'incomes';
  static const String userPrefsBoxKey = 'user_preferences';
  static const String currencyRatesBoxKey = 'currency_rates';

  // Default Categories
  static const List<String> defaultCategories = [
    'Groceries',
    'Entertainment',
    'Transportation',
    'Rent',
    'Shopping',
    'Food',
    'Bills',
    'Healthcare',
    'Education',
    'Travel',
    'Others',
  ];

  // Supported Currencies
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'INR',
    'BRL',
  ];

  // Date Filter Options
  static const List<String> dateFilterOptions = [
    'This Month',
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'This Year',
    'All Time',
  ];

  // Validation
  static const double maxExpenseAmount = 999999.99;
  static const double minExpenseAmount = 0.01;

  // Network Timeouts
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
}
