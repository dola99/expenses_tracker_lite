import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class FilterDropdown extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  // Function to get abbreviated text for display
  String _getAbbreviatedText(String text) {
    final abbreviations = {
      'This Month': 'This Month',
      'Last 7 Days': '7 Days',
      'Last 30 Days': '30 Days',
      'Last 3 Months': '3 Months',
      'This Year': 'This Year',
      'All Time': 'All Time',
    };
    return abbreviations[text] ?? text;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we need to use very compact mode
        final isVeryCompact = constraints.maxWidth < 100;
        final isCompact = constraints.maxWidth < 120;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isVeryCompact ? 6 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedFilter,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: 0.8),
                size: isVeryCompact ? 12 : (isCompact ? 14 : 18),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: isVeryCompact ? 10 : (isCompact ? 11 : 14),
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: AppTheme.primaryBlue,
              isDense: true,
              items: AppConstants.dateFilterOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: SizedBox(
                    width: 120, // Fixed width for dropdown items
                    child: Text(
                      option,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                // Custom builder for the selected item to handle text overflow
                return AppConstants.dateFilterOptions.map((String option) {
                  final displayText = isVeryCompact
                      ? _getAbbreviatedText(option)
                      : (isCompact ? _getAbbreviatedText(option) : option);
                  return Container(
                    alignment: Alignment.centerLeft,
                    constraints: BoxConstraints(
                      maxWidth:
                          constraints.maxWidth - (isVeryCompact ? 20 : 40),
                    ),
                    child: Text(
                      displayText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isVeryCompact ? 11 : (isCompact ? 12 : 14),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              onChanged: (String? newValue) {
                if (newValue != null && newValue != selectedFilter) {
                  onFilterChanged(newValue);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
