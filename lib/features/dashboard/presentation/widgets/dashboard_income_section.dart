import 'package:flutter/material.dart';
import '../bloc/dashboard_state.dart';
import 'income_card.dart';

class DashboardIncomeSection extends StatelessWidget {
  final DashboardState state;

  const DashboardIncomeSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is DashboardLoaded) {
      final loadedState = state as DashboardLoaded;
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: IncomeCard(
          totalIncome: loadedState.summary.totalIncome,
          selectedPeriod: loadedState.summary.selectedDateFilter,
          // No need for callback - dashboard auto-refreshes via event bus
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
