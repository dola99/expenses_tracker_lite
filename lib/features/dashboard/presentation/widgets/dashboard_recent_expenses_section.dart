import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../expenses/presentation/expenses_list_screen.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
import 'recent_expenses_list.dart';

class DashboardRecentExpensesSection extends StatelessWidget {
  final DashboardState state;

  const DashboardRecentExpensesSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Expenses',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  final currentState = context.read<DashboardBloc>().state;
                  final dateFilter = currentState is DashboardLoaded
                      ? currentState.summary.selectedDateFilter
                      : 'This Month';

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ExpensesListScreen(initialDateFilter: dateFilter),
                    ),
                  );
                },
                child: const Text(
                  'see all',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent Expenses List
          if (state is DashboardLoaded)
            RecentExpensesList(
              dateFilter: (state as DashboardLoaded).summary.selectedDateFilter,
            )
          else if (state is DashboardLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No recent expenses'),
              ),
            ),
        ],
      ),
    );
  }
}
