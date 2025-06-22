import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/income_model.dart';
import 'bloc/income_bloc.dart';
import 'bloc/income_event.dart';
import 'bloc/income_state.dart';
import 'add_income_screen.dart';
import 'widgets/income_summary_card.dart';
import 'widgets/income_empty_state.dart';
import 'widgets/income_grouped_list.dart';
import '../../export/presentation/export_screen.dart';
import '../../import/import_dialog.dart';

class IncomeListScreen extends StatelessWidget {
  const IncomeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IncomeBloc()..add(const LoadIncomes()),
      child: const IncomeListView(),
    );
  }
}

class IncomeListView extends StatelessWidget {
  const IncomeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: _buildAppBar(context),
      body: BlocBuilder<IncomeBloc, IncomeState>(
        builder: (context, state) {
          if (state is IncomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IncomeError) {
            return _buildErrorState(context, state.message);
          }

          if (state is IncomeLoaded) {
            final incomes = state.incomes;

            if (incomes.isEmpty) {
              return IncomeEmptyState(
                onAddIncome: () => _navigateToAddIncome(context),
              );
            }

            return _buildIncomesList(context, incomes);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundGray,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Income History',
        style: TextStyle(
          color: AppTheme.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
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

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textLight),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<IncomeBloc>().add(const LoadIncomes());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomesList(BuildContext context, List<IncomeModel> incomes) {
    return Column(
      children: [
        // Summary Card
        Padding(
          padding: const EdgeInsets.all(20),
          child: IncomeSummaryCard(incomes: incomes),
        ),
        // Income List
        Expanded(
          child: IncomeGroupedList(
            incomes: incomes,
            onEditIncome: (income) => _navigateToEditIncome(context, income),
            onDeleteIncome: (income) => _showDeleteDialog(context, income),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _navigateToAddIncome(context),
      backgroundColor: AppTheme.primaryBlue,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _navigateToAddIncome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddIncomeScreen()),
    );
  }

  void _navigateToEditIncome(BuildContext context, IncomeModel income) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddIncomeScreen(income: income)),
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

  void _showDeleteDialog(BuildContext context, IncomeModel income) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Income'),
        content: const Text(
          'Are you sure you want to delete this income entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<IncomeBloc>().add(DeleteIncome(income.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
