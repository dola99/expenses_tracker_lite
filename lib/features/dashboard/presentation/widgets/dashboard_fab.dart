import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/animation_service.dart';
import '../../../expenses/presentation/add_expense_screen.dart';
import '../../../export/presentation/export_screen.dart';
import '../../../import/import_dialog.dart';
import 'dashboard_income_options.dart';

class DashboardFAB extends StatefulWidget {
  const DashboardFAB({super.key});

  @override
  State<DashboardFAB> createState() => _DashboardFABState();
}

class _DashboardFABState extends State<DashboardFAB>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 300, // Fixed height to prevent layout issues
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Backdrop overlay (only shows when expanded)
          if (_isExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleExpansion,
                child: AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    return Container(
                      color: Colors.black.withValues(
                        alpha: 0.3 * _expandAnimation.value,
                      ),
                    );
                  },
                ),
              ),
            ),

          // Sub FABs
          ..._buildSubFABs(),

          // Main FAB
          Positioned(
            bottom: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 3.14159 * 2,
                  child: FloatingActionButton(
                    onPressed: _toggleExpansion,
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isExpanded
                          ? const Icon(Icons.close, key: ValueKey('close'))
                          : const Icon(Icons.add, key: ValueKey('add')),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubFABs() {
    final buttons = [
      {
        'icon': Icons.remove,
        'label': 'Expense',
        'color': Colors.red,
        'offset': 70.0,
      },
      {
        'icon': Icons.add,
        'label': 'Income',
        'color': AppTheme.successGreen,
        'offset': 130.0,
      },
      {
        'icon': Icons.upload_file,
        'label': 'Import',
        'color': Colors.orange,
        'offset': 190.0,
      },
      {
        'icon': Icons.download,
        'label': 'Export',
        'color': Colors.blue,
        'offset': 250.0,
      },
    ];

    return buttons.map((button) {
      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Positioned(
            bottom: (button['offset'] as double) * _expandAnimation.value,
            right: 0,
            child: Transform.scale(
              scale: _expandAnimation.value,
              child: Opacity(
                opacity: _expandAnimation.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        button['label'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Mini FAB
                    FloatingActionButton(
                      mini: true,
                      heroTag: button['label'],
                      onPressed: () {
                        _toggleExpansion();
                        _handleAction(button['label'] as String);
                      },
                      backgroundColor: button['color'] as Color,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      child: Icon(button['icon'] as IconData, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  void _handleAction(String action) {
    switch (action) {
      case 'Export':
        AnimationService.navigateWithAnimation(
          context: context,
          page: const ExportScreen(),
          type: AnimationType.slideLeft,
        );
        break;
      case 'Import':
        _showImportDialog(context);
        break;
      case 'Income':
        DashboardIncomeOptions.show(context);
        break;
      case 'Expense':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
        );
        break;
    }
  }

  void _showImportDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const ImportDialog());
  }
}
