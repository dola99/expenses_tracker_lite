import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_state.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_balance_section.dart';
import 'widgets/dashboard_income_section.dart';
import 'widgets/dashboard_recent_expenses_section.dart';
import 'widgets/dashboard_fab.dart';
import 'widgets/export_import_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: DashboardHeader(state: state)),

              // Balance Card
              SliverToBoxAdapter(child: DashboardBalanceSection(state: state)),

              // Income Card
              SliverToBoxAdapter(child: DashboardIncomeSection(state: state)),

              // Export/Import Card
              const SliverToBoxAdapter(child: ExportImportCard()),

              // Recent Expenses
              SliverToBoxAdapter(
                child: DashboardRecentExpensesSection(state: state),
              ),

              // Add some bottom padding to ensure FAB doesn't cover content
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: const DashboardFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
