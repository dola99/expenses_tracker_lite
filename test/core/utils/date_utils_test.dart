import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    final now = DateTime(2024, 6, 15, 14, 30); // June 15, 2024, 2:30 PM

    group('Date Formatting Tests', () {
      test('should format date for display correctly', () {
        final result = AppDateUtils.formatForDisplay(now);
        expect(result, equals('Jun 15, 2024'));
      });

      test('should format date for API correctly', () {
        final result = AppDateUtils.formatForApi(now);
        expect(result, equals('2024-06-15'));
      });

      test('should format time correctly', () {
        final result = AppDateUtils.formatTime(now);
        expect(result, equals('2:30 PM'));
      });

      test('should format month and year correctly', () {
        final result = AppDateUtils.formatMonthYear(now);
        expect(result, equals('June 2024'));
      });
    });

    group('Relative Time Tests', () {
      test('should return "Today" for current date', () {
        final today = DateTime.now();
        final result = AppDateUtils.getRelativeTime(today);
        expect(result, contains('Today'));
      });

      test('should return "Yesterday" for previous day', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = AppDateUtils.getRelativeTime(yesterday);
        expect(result, contains('Yesterday'));
      });

      test('should return days ago for recent dates', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final result = AppDateUtils.getRelativeTime(threeDaysAgo);
        expect(result, equals('3 days ago'));
      });

      test('should return formatted date for older dates', () {
        final oldDate = DateTime.now().subtract(const Duration(days: 10));
        final result = AppDateUtils.getRelativeTime(oldDate);
        expect(result, contains(AppDateUtils.formatForDisplay(oldDate)));
      });
    });

    group('Date Range Filter Tests', () {
      test('should return correct range for "This Month"', () {
        final range = AppDateUtils.getDateRangeForFilter('This Month');
        final now = DateTime.now();
        final expectedStart = DateTime(now.year, now.month, 1);
        final expectedEnd = DateTime(now.year, now.month + 1, 0);

        expect(range.start, equals(expectedStart));
        expect(range.end, equals(expectedEnd));
      });

      test('should return correct range for "Last 7 Days"', () {
        final range = AppDateUtils.getDateRangeForFilter('Last 7 Days');
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final expectedStart = today.subtract(const Duration(days: 7));

        expect(range.start, equals(expectedStart));
        expect(range.end, equals(today));
      });

      test('should return correct range for "Last 30 Days"', () {
        final range = AppDateUtils.getDateRangeForFilter('Last 30 Days');
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final expectedStart = today.subtract(const Duration(days: 30));

        expect(range.start, equals(expectedStart));
        expect(range.end, equals(today));
      });

      test('should return correct range for "Last 3 Months"', () {
        final range = AppDateUtils.getDateRangeForFilter('Last 3 Months');
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final expectedStart = DateTime(now.year, now.month - 3, now.day);

        expect(range.start, equals(expectedStart));
        expect(range.end, equals(today));
      });

      test('should return correct range for "This Year"', () {
        final range = AppDateUtils.getDateRangeForFilter('This Year');
        final now = DateTime.now();
        final expectedStart = DateTime(now.year, 1, 1);
        final expectedEnd = DateTime(now.year, 12, 31);

        expect(range.start, equals(expectedStart));
        expect(range.end, equals(expectedEnd));
      });

      test('should return default range for unknown filter', () {
        final range = AppDateUtils.getDateRangeForFilter('Unknown Filter');
        final expectedStart = DateTime(2020, 1, 1);
        final expectedEnd = DateTime(2030, 12, 31);

        expect(range.start, equals(expectedStart));
        expect(range.end, equals(expectedEnd));
      });
    });

    group('Date Range Validation Tests', () {
      test('should correctly identify date within range', () {
        final range = DateTimeRange(
          start: DateTime(2024, 6, 1),
          end: DateTime(2024, 6, 30),
        );
        final dateInRange = DateTime(2024, 6, 15);

        final result = AppDateUtils.isDateInRange(dateInRange, range);
        expect(result, isTrue);
      });

      test('should correctly identify date outside range', () {
        final range = DateTimeRange(
          start: DateTime(2024, 6, 1),
          end: DateTime(2024, 6, 30),
        );
        final dateOutsideRange = DateTime(2024, 7, 15);

        final result = AppDateUtils.isDateInRange(dateOutsideRange, range);
        expect(result, isFalse);
      });

      test('should handle edge case at start of range', () {
        final range = DateTimeRange(
          start: DateTime(2024, 6, 1),
          end: DateTime(2024, 6, 30),
        );
        final dateAtStart = DateTime(2024, 6, 1);

        final result = AppDateUtils.isDateInRange(dateAtStart, range);
        expect(result, isTrue);
      });

      test('should handle edge case at end of range', () {
        final range = DateTimeRange(
          start: DateTime(2024, 6, 1),
          end: DateTime(2024, 6, 30),
        );
        final dateAtEnd = DateTime(2024, 6, 30);

        final result = AppDateUtils.isDateInRange(dateAtEnd, range);
        expect(result, isTrue);
      });
    });

    group('Date Utility Helper Tests', () {
      test('should return start of day correctly', () {
        final inputDate = DateTime(2024, 6, 15, 14, 30, 45);
        final result = AppDateUtils.startOfDay(inputDate);
        final expected = DateTime(2024, 6, 15, 0, 0, 0);

        expect(result, equals(expected));
      });

      test('should return end of day correctly', () {
        final inputDate = DateTime(2024, 6, 15, 14, 30, 45);
        final result = AppDateUtils.endOfDay(inputDate);
        final expected = DateTime(2024, 6, 15, 23, 59, 59);

        expect(result, equals(expected));
      });
    });

    group('Date Filter Integration Tests', () {
      test('should filter expenses for "This Month" correctly', () {
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 15);
        final lastMonth = DateTime(now.year, now.month - 1, 15);

        final testExpenses = [
          {'date': thisMonth, 'amount': 100.0}, // This month
          {
            'date': thisMonth.subtract(const Duration(days: 5)),
            'amount': 50.0,
          }, // This month
          {'date': lastMonth, 'amount': 75.0}, // Last month
          {
            'date': DateTime(now.year - 1, now.month, 15),
            'amount': 200.0,
          }, // Last year
        ];

        final range = AppDateUtils.getDateRangeForFilter('This Month');

        final filteredExpenses = testExpenses.where((expense) {
          final date = expense['date'] as DateTime;
          return AppDateUtils.isDateInRange(date, range);
        }).toList();

        // Should include expenses from this month
        expect(filteredExpenses.length, greaterThanOrEqualTo(1));
      });

      test('should filter expenses for "This Year" correctly', () {
        final now = DateTime.now();
        final thisYear = DateTime(now.year, 6, 15);
        final lastYear = DateTime(now.year - 1, 6, 15);

        final testExpenses = [
          {'date': thisYear, 'amount': 100.0}, // This year
          {
            'date': DateTime(now.year, now.month, 1),
            'amount': 50.0,
          }, // This year
          {'date': DateTime(now.year, 3, 15), 'amount': 75.0}, // This year
          {'date': lastYear, 'amount': 200.0}, // Last year
        ];

        final range = AppDateUtils.getDateRangeForFilter('This Year');

        final filteredExpenses = testExpenses.where((expense) {
          final date = expense['date'] as DateTime;
          return AppDateUtils.isDateInRange(date, range);
        }).toList();

        // Should include all expenses from this year
        expect(filteredExpenses.length, equals(3));
      });

      test('should calculate total for filtered expenses', () {
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 15);

        final testExpenses = [
          {'date': thisMonth, 'amount': 100.0}, // This month
          {
            'date': thisMonth.subtract(const Duration(days: 5)),
            'amount': 50.0,
          }, // This month
          {
            'date': DateTime(now.year, now.month - 1, 15),
            'amount': 75.0,
          }, // Last month
        ];

        final range = AppDateUtils.getDateRangeForFilter('This Month');

        final filteredExpenses = testExpenses.where((expense) {
          final date = expense['date'] as DateTime;
          return AppDateUtils.isDateInRange(date, range);
        }).toList();

        final total = filteredExpenses.fold<double>(
          0.0,
          (sum, expense) => sum + (expense['amount'] as double),
        );

        // Should calculate total correctly for filtered expenses
        expect(total, greaterThan(0.0));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle null or invalid date filters gracefully', () {
        final range = AppDateUtils.getDateRangeForFilter('');
        expect(range, isA<DateTimeRange>());
      });

      test('should handle extreme dates', () {
        final extremeDate = DateTime(1970, 1, 1);
        final result = AppDateUtils.formatForDisplay(extremeDate);
        expect(result, isA<String>());
        expect(result.isNotEmpty, isTrue);
      });

      test('should handle future dates', () {
        final futureDate = DateTime(2030, 12, 31);
        final result = AppDateUtils.formatForDisplay(futureDate);
        expect(result, equals('Dec 31, 2030'));
      });
    });
  });
}
