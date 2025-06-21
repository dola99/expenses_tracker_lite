import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../expenses/domain/expense_model.dart';
import '../../../expenses/presentation/bloc/expense_bloc.dart';
import '../../../expenses/presentation/bloc/expense_event.dart';
import '../../../expenses/presentation/bloc/expense_state.dart';

class RecentExpensesList extends StatelessWidget {
  final String dateFilter;

  const RecentExpensesList({super.key, required this.dateFilter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is ExpenseLoaded) {
          if (state.expenses.isEmpty) {
            return _buildEmptyState();
          }

          // Show only recent 5 expenses for dashboard
          final recentExpenses = state.expenses.take(5).toList();

          return Column(
            children: recentExpenses.map((expense) {
              return _buildExpenseItem(expense);
            }).toList(),
          );
        }

        if (state is ExpenseError) {
          return _buildErrorState(state.message, context);
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildExpenseItem(ExpenseModel expense) {
    final categoryColor = AppTheme.getCategoryColor(expense.category);
    final categoryIcon = AppTheme.getCategoryIcon(expense.category);

    return Container(
      key: ValueKey(expense.id), // Add unique key based on expense ID
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(categoryIcon, color: categoryColor, size: 24),
          ),
          const SizedBox(width: 16),

          // Expense Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.description ?? 'Monthly',
                  style: const TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Amount and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${CurrencyFormatter.format(expense.amount, currencySymbol: CurrencyFormatter.getCurrencySymbol(expense.currency))}',
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.getRelativeTime(expense.date),
                style: const TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              color: AppTheme.textMedium,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses by adding your first expense',
            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text(
            'Error loading expenses',
            style: TextStyle(
              color: AppTheme.textMedium,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ExpenseBloc>().add(
                LoadExpenses(page: 1, dateFilter: dateFilter),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
