import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../domain/expense_model.dart';

class ExpenseItem extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.getCategoryColor(expense.category);
    final categoryIcon = AppTheme.getCategoryIcon(expense.category);

    return Container(
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                if (expense.description?.isNotEmpty == true) ...[
                  Text(
                    expense.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDark.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  app_date_utils.AppDateUtils.formatForDisplay(expense.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textDark.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${CurrencyFormatter.format(expense.amount, currencySymbol: CurrencyFormatter.getCurrencySymbol(expense.currency))}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorRed,
                ),
              ),
              if (expense.currency != 'USD') ...[
                const SizedBox(height: 2),
                Text(
                  '≈ \$${CurrencyFormatter.formatPlain(expense.amountInUSD)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textDark.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
