import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AppDateUtils {
  static final DateFormat _displayFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  /// Format date for display (e.g., "Jan 15, 2024")
  static String formatForDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Format date for API calls (ISO format)
  static String formatForApi(DateTime date) {
    return _apiFormat.format(date);
  }

  /// Format time (e.g., "2:30 PM")
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format month and year (e.g., "January 2024")
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Get relative time (e.g., "Today", "Yesterday", "2 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(targetDate).inDays;

    if (difference == 0) {
      return 'Today ${_timeFormat.format(date)}';
    } else if (difference == 1) {
      return 'Yesterday ${_timeFormat.format(date)}';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return formatForDisplay(date);
    }
  }

  /// Get date range for filter options
  static DateTimeRange getDateRangeForFilter(String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case 'This Month':
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: firstDayOfMonth, end: lastDayOfMonth);

      case 'Last 7 Days':
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        return DateTimeRange(start: sevenDaysAgo, end: today);

      case 'Last 30 Days':
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));
        return DateTimeRange(start: thirtyDaysAgo, end: today);

      case 'Last 3 Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return DateTimeRange(start: threeMonthsAgo, end: today);

      case 'This Year':
        final firstDayOfYear = DateTime(now.year, 1, 1);
        final lastDayOfYear = DateTime(now.year, 12, 31);
        return DateTimeRange(start: firstDayOfYear, end: lastDayOfYear);

      default: // 'All Time'
        final farPast = DateTime(2020, 1, 1);
        final farFuture = DateTime(2030, 12, 31);
        return DateTimeRange(start: farPast, end: farFuture);
    }
  }

  /// Check if date is within range
  static bool isDateInRange(DateTime date, DateTimeRange range) {
    return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
        date.isBefore(range.end.add(const Duration(days: 1)));
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}
