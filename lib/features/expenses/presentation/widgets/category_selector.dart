import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/constants/app_constants.dart';

class CategorySelector extends StatefulWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  List<String> _customCategories = [];
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadCustomCategories();
  }

  void _loadCustomCategories() {
    final customCategories = _storageService.getData<List<dynamic>>(
      AppConstants.userPrefsBoxKey,
      'custom_categories',
    );
    if (customCategories != null) {
      setState(() {
        _customCategories = customCategories.cast<String>();
      });
    }
  }

  Future<void> _saveCustomCategories() async {
    await _storageService.saveData(
      AppConstants.userPrefsBoxKey,
      'custom_categories',
      _customCategories,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = [
      ...AppConstants.defaultCategories.take(5), // First 5 default categories
      ..._customCategories,
    ];

    return Column(
      children: [
        // Display categories in a grid layout
        ..._buildCategoryGrid(allCategories),
      ],
    );
  }

  List<Widget> _buildCategoryGrid(List<String> categories) {
    final List<Widget> rows = [];
    const int itemsPerRow = 3;

    for (int i = 0; i < categories.length; i += itemsPerRow) {
      final rowCategories = categories.skip(i).take(itemsPerRow).toList();

      // Add empty slots to complete the row
      while (rowCategories.length < itemsPerRow && rows.isEmpty) {
        // Only add the "Add" button to the first row if there's space
        break;
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...rowCategories.map(
                (category) => _buildCategoryItem(
                  category,
                  _getCategoryIcon(category),
                  _getCategoryColor(category),
                ),
              ),
              // Add the "Add Category" button to the first row if there's space
              if (rows.isEmpty && rowCategories.length < itemsPerRow)
                _buildCategoryAddButton(),
              // Fill remaining slots with empty containers
              ...List.generate(
                itemsPerRow -
                    rowCategories.length -
                    (rows.isEmpty && rowCategories.length < itemsPerRow
                        ? 1
                        : 0),
                (index) => Container(width: 80),
              ),
            ],
          ),
        ),
      );
    }

    // If no categories exist or add button wasn't added, add it as a separate row
    if (categories.isEmpty ||
        (categories.length >= 3 && categories.length % 3 == 0)) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryAddButton(),
              Container(width: 80),
              Container(width: 80),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildCategoryItem(String category, IconData icon, Color color) {
    final isSelected = widget.selectedCategory == category;

    return GestureDetector(
      onTap: () => widget.onCategorySelected(category),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 28),
            const SizedBox(height: 4),
            Text(
              _getCategoryDisplayName(category),
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textDark,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAddButton() {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.textLight,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppTheme.textMedium, size: 24),
            const SizedBox(height: 4),
            Text(
              'Add\nCategory',
              style: TextStyle(
                color: AppTheme.textMedium,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return Icons.movie;
      case 'groceries':
        return Icons.shopping_cart;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transportation':
        return Icons.directions_car;
      case 'rent':
        return Icons.home;
      case 'food':
        return Icons.restaurant;
      case 'bills':
        return Icons.receipt;
      case 'healthcare':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'others':
        return Icons.category;
      default:
        return Icons.label;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
        return AppTheme.entertainmentOrange;
      case 'groceries':
        return AppTheme.groceryBlue;
      case 'shopping':
        return AppTheme.shoppingYellow;
      case 'transportation':
        return AppTheme.transportPurple;
      case 'rent':
        return AppTheme.rentGreen;
      case 'food':
        return const Color(0xFFFF6B6B);
      case 'bills':
        return const Color(0xFF4ECDC4);
      case 'healthcare':
        return const Color(0xFFFF8A65);
      case 'education':
        return const Color(0xFF7986CB);
      case 'travel':
        return const Color(0xFF9CCC65);
      case 'others':
        return const Color(0xFF90A4AE);
      default:
        return AppTheme.primaryBlue;
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final TextEditingController controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Custom Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter category name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final categoryName = controller.text.trim();
                if (categoryName.isNotEmpty) {
                  Navigator.of(context).pop(categoryName);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _customCategories.add(result);
      });
      await _saveCustomCategories();
      widget.onCategorySelected(result);
    }
  }

  String _getCategoryDisplayName(String category) {
    // Shorten long category names for display
    switch (category) {
      case 'Transportation':
        return 'Transport';
      case 'Entertainment':
        return 'Fun';
      default:
        return category;
    }
  }
}
