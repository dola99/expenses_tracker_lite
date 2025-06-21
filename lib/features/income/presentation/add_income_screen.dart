import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/income_model.dart';
import 'bloc/income_bloc.dart';
import 'bloc/income_event.dart';
import 'bloc/income_state.dart';
import 'widgets/income_amount_section.dart';
import 'widgets/income_category_section.dart';
import 'widgets/income_currency_section.dart';
import 'widgets/income_description_section.dart';
import 'widgets/income_date_section.dart';

class AddIncomeScreen extends StatelessWidget {
  final IncomeModel? income;

  const AddIncomeScreen({super.key, this.income});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IncomeBloc(),
      child: AddIncomeView(income: income),
    );
  }
}

class AddIncomeView extends StatefulWidget {
  final IncomeModel? income;

  const AddIncomeView({super.key, this.income});

  @override
  State<AddIncomeView> createState() => _AddIncomeViewState();
}

class _AddIncomeViewState extends State<AddIncomeView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = IncomeCategories.salary;
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.income != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFieldsForEditing();
    }
  }

  void _populateFieldsForEditing() {
    final income = widget.income!;
    _selectedCategory = income.category;
    _amountController.text = income.amount.toString();
    _selectedCurrency = income.currency;
    _descriptionController.text = income.description ?? '';
    _selectedDate = income.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: _buildAppBar(),
      body: BlocListener<IncomeBloc, IncomeState>(
        listener: (context, state) {
          if (state is IncomeLoaded) {
            // Show success message and close screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing
                      ? 'Income updated successfully'
                      : 'Income added successfully',
                ),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is IncomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundGray,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        isEditing ? 'Edit Income' : 'Add Income',
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IncomeAmountSection(
              amountController: _amountController,
              selectedCurrency: _selectedCurrency,
            ),
            const SizedBox(height: 24),
            IncomeCategorySection(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            const SizedBox(height: 24),
            IncomeCurrencySection(
              selectedCurrency: _selectedCurrency,
              onCurrencyChanged: (currency) {
                setState(() {
                  _selectedCurrency = currency;
                });
              },
            ),
            const SizedBox(height: 24),
            IncomeDescriptionSection(
              descriptionController: _descriptionController,
            ),
            const SizedBox(height: 24),
            IncomeDateSection(
              selectedDate: _selectedDate,
              onDateTap: _selectDate,
            ),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<IncomeBloc, IncomeState>(
      builder: (context, state) {
        final isLoading = state is IncomeLoading;

        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveIncome,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isEditing ? 'Update Income' : 'Add Income',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveIncome() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      if (isEditing) {
        context.read<IncomeBloc>().add(
          UpdateIncome(
            id: widget.income!.id,
            category: _selectedCategory,
            amount: amount,
            currency: _selectedCurrency,
            description: description.isEmpty ? null : description,
            date: _selectedDate,
          ),
        );
      } else {
        context.read<IncomeBloc>().add(
          AddIncome(
            category: _selectedCategory,
            amount: amount,
            currency: _selectedCurrency,
            description: description.isEmpty ? null : description,
            date: _selectedDate,
          ),
        );
      }
    }
  }
}
