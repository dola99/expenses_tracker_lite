import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../domain/income_model.dart';
import 'income_item.dart';

class IncomeGroupedList extends StatelessWidget {
  final List<IncomeModel> incomes;
  final Function(IncomeModel) onEditIncome;
  final Function(IncomeModel) onDeleteIncome;

  const IncomeGroupedList({
    super.key,
    required this.incomes,
    required this.onEditIncome,
    required this.onDeleteIncome,
  });

  @override
  Widget build(BuildContext context) {
    // Group incomes by month
    final groupedIncomes = <String, List<IncomeModel>>{};
    for (final income in incomes) {
      final monthKey = app_date_utils.AppDateUtils.formatMonthYear(income.date);
      groupedIncomes.putIfAbsent(monthKey, () => []).add(income);
    }

    return ListView.builder(
      itemCount: groupedIncomes.entries.length,
      itemBuilder: (context, index) {
        final entries = groupedIncomes.entries.toList();
        final entry = entries[index];
        final monthYear = entry.key;
        final monthIncomes = entry.value;
        final monthTotal = monthIncomes.fold(
          0.0,
          (sum, income) => sum + income.amountInUSD,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthYear,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '+${CurrencyFormatter.format(monthTotal)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
            ),

            // Month Incomes
            ...monthIncomes.map(
              (income) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IncomeItem(
                  income: income,
                  onTap: () => onEditIncome(income),
                  onDelete: () => onDeleteIncome(income),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
