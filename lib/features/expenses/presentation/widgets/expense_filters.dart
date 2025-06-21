import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ExpenseFilters extends StatelessWidget {
  final String? selectedCategory;
  final String selectedDateFilter;
  final Function(String?) onCategoryChanged;
  final Function(String) onDateFilterChanged;

  const ExpenseFilters({
    super.key,
    required this.selectedCategory,
    required this.selectedDateFilter,
    required this.onCategoryChanged,
    required this.onDateFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Filter
          Row(
            children: [
              const Text(
                'Period:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedDateFilter,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Today', child: Text('Today')),
                    DropdownMenuItem(
                      value: 'This Week',
                      child: Text('This Week'),
                    ),
                    DropdownMenuItem(
                      value: 'This Month',
                      child: Text('This Month'),
                    ),
                    DropdownMenuItem(
                      value: 'This Year',
                      child: Text('This Year'),
                    ),
                    DropdownMenuItem(
                      value: 'All Time',
                      child: Text('All Time'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onDateFilterChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Filter
          Row(
            children: [
              const Text(
                'Category:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.cardWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    DropdownMenuItem(value: 'Food', child: Text('Food')),
                    DropdownMenuItem(
                      value: 'Transport',
                      child: Text('Transport'),
                    ),
                    DropdownMenuItem(
                      value: 'Shopping',
                      child: Text('Shopping'),
                    ),
                    DropdownMenuItem(
                      value: 'Entertainment',
                      child: Text('Entertainment'),
                    ),
                    DropdownMenuItem(value: 'Bills', child: Text('Bills')),
                    DropdownMenuItem(value: 'Health', child: Text('Health')),
                    DropdownMenuItem(value: 'Travel', child: Text('Travel')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: onCategoryChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
