import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../domain/income_model.dart';

class IncomeItem extends StatelessWidget {
  final IncomeModel income;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const IncomeItem({
    super.key,
    required this.income,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(income.category);
    final categoryIcon = _getCategoryIcon(income.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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

                // Income Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        income.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (income.description?.isNotEmpty == true) ...[
                        Text(
                          income.description!,
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
                        app_date_utils.AppDateUtils.formatForDisplay(
                          income.date,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textDark.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount and Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${CurrencyFormatter.format(income.amount, currencySymbol: CurrencyFormatter.getCurrencySymbol(income.currency))}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    if (income.currency != 'USD') ...[
                      const SizedBox(height: 2),
                      Text(
                        '≈ \$${CurrencyFormatter.formatPlain(income.amountInUSD)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textDark.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppTheme.textDark.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case IncomeCategories.salary:
        return const Color(0xFF2E7D32); // Green
      case IncomeCategories.freelance:
        return const Color(0xFF1976D2); // Blue
      case IncomeCategories.business:
        return const Color(0xFF7B1FA2); // Purple
      case IncomeCategories.investment:
        return const Color(0xFFD32F2F); // Red
      case IncomeCategories.rental:
        return const Color(0xFFF57C00); // Orange
      case IncomeCategories.bonus:
        return const Color(0xFF388E3C); // Light Green
      case IncomeCategories.gift:
        return const Color(0xFFE91E63); // Pink
      case IncomeCategories.other:
        return const Color(0xFF616161); // Grey
      default:
        return const Color(0xFF616161);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case IncomeCategories.salary:
        return Icons.work;
      case IncomeCategories.freelance:
        return Icons.laptop;
      case IncomeCategories.business:
        return Icons.business;
      case IncomeCategories.investment:
        return Icons.trending_up;
      case IncomeCategories.rental:
        return Icons.home;
      case IncomeCategories.bonus:
        return Icons.card_giftcard;
      case IncomeCategories.gift:
        return Icons.redeem;
      case IncomeCategories.other:
        return Icons.attach_money;
      default:
        return Icons.attach_money;
    }
  }
}
