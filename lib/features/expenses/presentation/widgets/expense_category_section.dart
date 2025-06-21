import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/category_selector.dart';

class ExpenseCategorySection extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const ExpenseCategorySection({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Entertainment',
          style: TextStyle(color: AppTheme.textLight, fontSize: 14),
        ),
        const SizedBox(height: 16),
        CategorySelector(
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
        ),
      ],
    );
  }
}
