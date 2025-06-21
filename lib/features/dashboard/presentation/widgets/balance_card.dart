import 'package:expense_tracker/features/dashboard/presentation/widgets/income_expense_item.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../income/presentation/income_list_screen.dart';
import '../../../expenses/presentation/expenses_list_screen.dart';
import '../bloc/dashboard_state.dart';
import 'animated_balance_display.dart';

class BalanceCard extends StatelessWidget {
  final DashboardSummary summary;

  const BalanceCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF1E3A8A), // Deeper blue
            AppTheme.lightBlue,
            Color(0xFF3B82F6), // Lighter accent
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          // Primary shadow for depth
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: -2,
          ),
          // Secondary shadow for more depth
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
          // Inner highlight
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 0,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Total Balance and Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.white.withValues(alpha: 0.95),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Balance Amount with Animation
            AnimatedBalanceDisplay(balance: summary.totalBalance),

            // // Balance Status Indicator
            // BalanceStatusIndicator(
            //   currentBalance: summary.totalBalance,
            //   averageAmount: 5000.0,
            // ),
            const SizedBox(height: 24),

            // Income and Expenses Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const IncomeListScreen(),
                        ),
                      );
                    },
                    child: IncomeExpenseItem(
                      icon: Icons.arrow_downward,
                      label: 'Income',
                      amount: summary.totalIncome,
                      isIncome: true,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ExpensesListScreen(),
                        ),
                      );
                    },
                    child: IncomeExpenseItem(
                      icon: Icons.arrow_upward,
                      label: 'Expenses',
                      amount: summary.totalExpenses,
                      isIncome: false,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
