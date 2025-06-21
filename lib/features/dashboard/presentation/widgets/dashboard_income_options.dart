import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../income/presentation/add_income_screen.dart';
import '../../../income/presentation/income_list_screen.dart';

class DashboardIncomeOptions {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textDark.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Income',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),

            // Add Income Option
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: AppTheme.successGreen),
              ),
              title: const Text(
                'Add Income',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Record a new income entry'),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddIncomeScreen(),
                  ),
                );
                // No need to manually refresh - dashboard auto-refreshes via event bus
              },
            ),

            // View Income List Option
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.list_alt, color: AppTheme.successGreen),
              ),
              title: const Text(
                'View Income',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('See all your income entries'),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const IncomeListScreen(),
                  ),
                );
                // No need to manually refresh - dashboard auto-refreshes via event bus
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
