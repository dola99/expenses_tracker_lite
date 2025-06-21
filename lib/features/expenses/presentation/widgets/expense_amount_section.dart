import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../currency/presentation/bloc/currency_bloc.dart';
import '../../../currency/presentation/bloc/currency_state.dart';

class ExpenseAmountSection extends StatelessWidget {
  final TextEditingController amountController;
  final String selectedCurrency;
  final Function(String) onCurrencyChanged;

  const ExpenseAmountSection({
    super.key,
    required this.amountController,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Currency Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.backgroundGray),
              ),
              child: BlocBuilder<CurrencyBloc, CurrencyState>(
                builder: (context, state) {
                  List<String> currencies = AppConstants.supportedCurrencies;
                  if (state is CurrencyLoaded) {
                    currencies = state.availableCurrencies;
                  }

                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCurrency,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: currencies.map((String currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(
                            currency,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          onCurrencyChanged(newValue);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Amount Input
            Expanded(
              child: TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 16),
                  filled: true,
                  fillColor: AppTheme.cardWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.backgroundGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.backgroundGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > AppConstants.maxExpenseAmount) {
                    return 'Amount too large';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
