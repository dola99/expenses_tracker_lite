import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/expense_state_manager.dart';
import 'widgets/expense_filters.dart';
import 'widgets/expense_list_content.dart';
import 'widgets/expenses_fab.dart';
import '../../export/presentation/export_screen.dart';
import '../../import/import_dialog.dart';

class ExpensesListScreen extends StatelessWidget {
  final String? initialCategoryFilter;
  final String? initialDateFilter;

  const ExpensesListScreen({
    super.key,
    this.initialCategoryFilter,
    this.initialDateFilter,
  });

  @override
  Widget build(BuildContext context) {
    return ExpenseStateManager(
      initialCategoryFilter: initialCategoryFilter,
      initialDateFilter: initialDateFilter,
      builder:
          (
            context,
            selectedCategory,
            selectedDateFilter,
            scrollController,
            onCategoryChanged,
            onDateFilterChanged,
            onRefresh,
          ) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundGray,
              appBar: _buildAppBar(context),
              body: Column(
                children: [
                  ExpenseFilters(
                    selectedCategory: selectedCategory,
                    selectedDateFilter: selectedDateFilter,
                    onCategoryChanged: onCategoryChanged,
                    onDateFilterChanged: onDateFilterChanged,
                  ),
                  Expanded(
                    child: ExpenseListContent(
                      scrollController: scrollController,
                      onRefresh: onRefresh,
                    ),
                  ),
                ],
              ),
              floatingActionButton: const ExpensesFAB(),
            );
          },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'All Expenses',
        style: TextStyle(
          color: AppTheme.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        // Export button
        IconButton(
          onPressed: () => _navigateToExport(context),
          icon: const Icon(Icons.download, color: AppTheme.textDark, size: 24),
          tooltip: 'Export Data',
        ),
        // Import button
        IconButton(
          onPressed: () => _showImportDialog(context),
          icon: const Icon(
            Icons.upload_file,
            color: AppTheme.textDark,
            size: 24,
          ),
          tooltip: 'Import Data',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _navigateToExport(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ExportScreen()));
  }

  void _showImportDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const ImportDialog());
  }
}
