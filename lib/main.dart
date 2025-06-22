import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'core/network/network_service.dart';
import 'features/currency/data/currency_service.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_event.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'features/expenses/presentation/bloc/expense_event.dart';
import 'features/income/presentation/bloc/income_bloc.dart';
import 'features/income/presentation/bloc/income_event.dart';
import 'features/currency/presentation/bloc/currency_bloc.dart';
import 'features/currency/presentation/bloc/currency_event.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure status bar for white background on Android and iOS
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.light, // Dark icons for white background
      statusBarBrightness: Brightness.dark, // For iOS
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await _initializeServices();
  runApp(const ExpenseTrackerApp());
}

Future<void> _initializeServices() async {
  await StorageService().initialize();
  NetworkService().initialize();
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardBloc()..add(LoadDashboardData()),
        ),
        BlocProvider(create: (context) => ExpenseBloc()..add(LoadExpenses())),
        BlocProvider(create: (context) => IncomeBloc()..add(LoadIncomes())),
        BlocProvider(
          create: (context) =>
              CurrencyBloc(currencyService: CurrencyService())
                ..add(LoadCurrencyRates()),
        ),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
