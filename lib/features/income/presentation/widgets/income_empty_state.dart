import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class IncomeEmptyState extends StatelessWidget {
  final VoidCallback onAddIncome;

  const IncomeEmptyState({super.key, required this.onAddIncome});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money,
              size: 80,
              color: AppTheme.textDark.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Income Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your income by adding your first entry',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textDark.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAddIncome,
              icon: const Icon(Icons.add),
              label: const Text('Add Income'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
