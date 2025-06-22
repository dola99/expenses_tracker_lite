import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/import_service.dart';
import '../expenses/presentation/bloc/expense_bloc.dart';
import '../expenses/presentation/bloc/expense_event.dart';
import '../income/presentation/bloc/income_bloc.dart';
import '../income/presentation/bloc/income_event.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  bool _isImporting = false;

  Future<void> _handleImport() async {
    setState(() {
      _isImporting = true;
    });

    try {
      final result = await ImportService.importFromFile();

      if (!mounted) return;

      if (result.cancelled) {
        Navigator.pop(context);
        return;
      }

      if (result.success) {
        // Add imported expenses to the expenses bloc
        if (result.expenses.isNotEmpty) {
          for (final expense in result.expenses) {
            context.read<ExpenseBloc>().add(
              AddExpense(
                category: expense.category,
                amount: expense.amount,
                currency: expense.currency,
                date: expense.date,
                description: expense.description,
                receiptPath: expense.receiptPath,
              ),
            );
          }
        }

        // Add imported incomes to the income bloc
        if (result.incomes.isNotEmpty) {
          for (final income in result.incomes) {
            context.read<IncomeBloc>().add(
              AddIncome(
                category: income.category,
                amount: income.amount,
                currency: income.currency,
                date: income.date,
                description: income.description,
              ),
            );
          }
        }

        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully imported ${result.totalItems} items '
              '(${result.expenses.length} expenses, ${result.incomes.length} incomes)',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      } else {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Import failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.upload_file, color: Colors.blue),
          SizedBox(width: 8),
          Text('Import Data'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import expenses and income from external files.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Supported formats:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '• CSV files with headers: Date, Amount, Category, Description',
          ),
          const Text('• JSON backup files from this app'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CSV Format Tips:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• Include "Date", "Amount", "Category" columns\n'
                  '• Add "Type" column with "income" or "expense" for mixed data\n'
                  '• Dates can be YYYY-MM-DD or MM/DD/YYYY format',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
          if (_isImporting) ...[
            const SizedBox(height: 16),
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Importing data...'),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isImporting ? null : _handleImport,
          child: _isImporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Choose File'),
        ),
      ],
    );
  }
}
