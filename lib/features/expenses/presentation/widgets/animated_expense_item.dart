import 'package:flutter/material.dart';
import '../../../../core/services/animation_service.dart';
import '../../domain/expense_model.dart';
import 'package:intl/intl.dart';

class AnimatedExpenseItem extends StatefulWidget {
  final ExpenseModel expense;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final AnimationController? listController;

  const AnimatedExpenseItem({
    super.key,
    required this.expense,
    required this.index,
    this.onTap,
    this.onDelete,
    this.listController,
  });

  @override
  State<AnimatedExpenseItem> createState() => _AnimatedExpenseItemState();
}

class _AnimatedExpenseItemState extends State<AnimatedExpenseItem>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Staggered animation delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍽️';
      case 'transport':
        return '🚗';
      case 'shopping':
        return '🛍️';
      case 'entertainment':
        return '🎬';
      case 'bills':
        return '💡';
      case 'health':
        return '⚕️';
      case 'education':
        return '📚';
      case 'travel':
        return '✈️';
      default:
        return '💰';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'bills':
        return Colors.yellow;
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.green;
      case 'travel':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.onTap,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isPressed ? Colors.grey[100] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Category Icon with Animation
                        AnimationService.heroAnimation(
                          tag: 'expense_icon_${widget.expense.id}',
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(
                                widget.expense.category,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                _getCategoryIcon(widget.expense.category),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Expense Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Name
                              Text(
                                widget.expense.category,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                              ),

                              const SizedBox(height: 4),

                              // Description
                              if (widget.expense.description != null) ...[
                                Text(
                                  widget.expense.description!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                              ],

                              // Date
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(widget.expense.date),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Amount with Currency
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${widget.expense.currency} ${widget.expense.amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[600],
                                  ),
                            ),

                            // USD equivalent if different currency
                            if (widget.expense.currency != 'USD') ...[
                              const SizedBox(height: 2),
                              Text(
                                'USD ${widget.expense.amountInUSD.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[500]),
                              ),
                            ],
                          ],
                        ),

                        // Delete Button (if provided)
                        if (widget.onDelete != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: widget.onDelete,
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            tooltip: 'Delete expense',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AnimatedExpenseList extends StatefulWidget {
  final List<ExpenseModel> expenses;
  final Function(ExpenseModel)? onExpenseSelected;
  final Function(ExpenseModel)? onExpenseDeleted;

  const AnimatedExpenseList({
    super.key,
    required this.expenses,
    this.onExpenseSelected,
    this.onExpenseDeleted,
  });

  @override
  State<AnimatedExpenseList> createState() => _AnimatedExpenseListState();
}

class _AnimatedExpenseListState extends State<AnimatedExpenseList>
    with TickerProviderStateMixin {
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expenses.isEmpty) {
      return Center(
        child: AnimationService.animatedContainer(
          controller: _listController,
          type: AnimationType.scaleAndFade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No expenses yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first expense to get started',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: widget.expenses.length,
      itemBuilder: (context, index) {
        final expense = widget.expenses[index];
        return AnimatedExpenseItem(
          expense: expense,
          index: index,
          listController: _listController,
          onTap: () => widget.onExpenseSelected?.call(expense),
          onDelete: () => widget.onExpenseDeleted?.call(expense),
        );
      },
    );
  }
}
