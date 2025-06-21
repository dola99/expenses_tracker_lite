import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class ExpenseStateManager extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    String? selectedCategory,
    String selectedDateFilter,
    ScrollController scrollController,
    Function(String?) onCategoryChanged,
    Function(String) onDateFilterChanged,
    VoidCallback onRefresh,
  )
  builder;

  final String? initialCategoryFilter;
  final String? initialDateFilter;

  const ExpenseStateManager({
    super.key,
    required this.builder,
    this.initialCategoryFilter,
    this.initialDateFilter,
  });

  @override
  State<ExpenseStateManager> createState() => _ExpenseStateManagerState();
}

class _ExpenseStateManagerState extends State<ExpenseStateManager> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  String _selectedDateFilter = 'This Month';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryFilter;
    _selectedDateFilter = widget.initialDateFilter ?? 'This Month';

    // Load initial expenses
    context.read<ExpenseBloc>().add(
      LoadExpenses(
        page: 1,
        categoryFilter: _selectedCategory,
        dateFilter: _selectedDateFilter,
      ),
    );

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<ExpenseBloc>().state;
      if (currentState is ExpenseLoaded && !currentState.hasReachedMax) {
        context.read<ExpenseBloc>().add(
          LoadMoreExpenses(
            categoryFilter: _selectedCategory,
            dateFilter: _selectedDateFilter,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _reloadExpenses();
  }

  void _onDateFilterChanged(String dateFilter) {
    setState(() {
      _selectedDateFilter = dateFilter;
    });
    _reloadExpenses();
  }

  void _reloadExpenses() {
    context.read<ExpenseBloc>().add(
      LoadExpenses(
        page: 1,
        categoryFilter: _selectedCategory,
        dateFilter: _selectedDateFilter,
      ),
    );
  }

  void _onRefresh() {
    _reloadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _selectedCategory,
      _selectedDateFilter,
      _scrollController,
      _onCategoryChanged,
      _onDateFilterChanged,
      _onRefresh,
    );
  }
}
