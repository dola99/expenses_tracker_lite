import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import '../../features/expenses/domain/expense_model.dart';
import '../../features/income/domain/income_model.dart';

class TransactionData {
  final String id;
  final String category;
  final double amount;
  final String currency;
  final double amountInUSD;
  final DateTime date;
  final String? description;
  final String type; // 'expense' or 'income'

  TransactionData({
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
    required this.amountInUSD,
    required this.date,
    this.description,
    required this.type,
  });

  factory TransactionData.fromExpense(ExpenseModel expense) {
    return TransactionData(
      id: expense.id,
      category: expense.category,
      amount: expense.amount,
      currency: expense.currency,
      amountInUSD: expense.amountInUSD,
      date: expense.date,
      description: expense.description,
      type: 'expense',
    );
  }

  factory TransactionData.fromIncome(IncomeModel income) {
    return TransactionData(
      id: income.id,
      category: income.category,
      amount: income.amount,
      currency: income.currency,
      amountInUSD: income.amountInUSD,
      date: income.date,
      description: income.description,
      type: 'income',
    );
  }
}

class ExportService {
  static const String _appName = 'Expense Tracker';

  /// Export transactions to CSV format
  static Future<void> exportToCSV({
    List<ExpenseModel>? expenses,
    List<IncomeModel>? incomes,
  }) async {
    try {
      // Combine and sort transactions
      List<TransactionData> transactions = [];

      if (expenses != null) {
        transactions.addAll(
          expenses.map((e) => TransactionData.fromExpense(e)),
        );
      }

      if (incomes != null) {
        transactions.addAll(incomes.map((e) => TransactionData.fromIncome(e)));
      }

      transactions.sort((a, b) => b.date.compareTo(a.date));

      // Prepare CSV data
      List<List<dynamic>> csvData = [
        ['Date', 'Category', 'Amount', 'Currency', 'Description', 'Type'],
      ];

      for (var transaction in transactions) {
        csvData.add([
          DateFormat('yyyy-MM-dd').format(transaction.date),
          transaction.category,
          transaction.amount.toStringAsFixed(2),
          transaction.currency,
          transaction.description ?? '',
          transaction.type,
        ]);
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final file = File(
        path.join(
          directory.path,
          'transactions_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
        ),
      );

      // Write CSV data to file
      await file.writeAsString(csvString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Transaction Report - CSV Export',
        subject: 'Expense Tracker Export',
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  /// Export transactions to PDF format
  static Future<void> exportToPDF({
    List<ExpenseModel>? expenses,
    List<IncomeModel>? incomes,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final reportTitle = title ?? 'Transaction Report';

      // Combine and sort transactions
      List<TransactionData> transactions = [];

      if (expenses != null) {
        transactions.addAll(
          expenses.map((e) => TransactionData.fromExpense(e)),
        );
      }

      if (incomes != null) {
        transactions.addAll(incomes.map((e) => TransactionData.fromIncome(e)));
      }

      transactions.sort((a, b) => b.date.compareTo(a.date));

      // Calculate totals
      double totalExpenses = 0;
      double totalIncome = 0;
      Map<String, double> categoryTotals = {};

      for (var transaction in transactions) {
        if (transaction.type == 'expense') {
          totalExpenses += transaction.amountInUSD;
        } else {
          totalIncome += transaction.amountInUSD;
        }

        final key = '${transaction.category} (${transaction.type})';
        categoryTotals[key] =
            (categoryTotals[key] ?? 0) + transaction.amountInUSD;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _appName,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        reportTitle,
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Generated: ${DateFormat('MMM dd, yyyy').format(now)}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      if (startDate != null && endDate != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Period: ${DateFormat('MMM dd').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Summary Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Summary',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          'Total Income',
                          totalIncome,
                          PdfColors.green,
                        ),
                        _buildSummaryItem(
                          'Total Expenses',
                          totalExpenses,
                          PdfColors.red,
                        ),
                        _buildSummaryItem(
                          'Net Balance',
                          totalIncome - totalExpenses,
                          totalIncome - totalExpenses >= 0
                              ? PdfColors.green
                              : PdfColors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Category Breakdown
              if (categoryTotals.isNotEmpty) ...[
                pw.Text(
                  'Category Breakdown',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        _buildTableCell('Category', isHeader: true),
                        _buildTableCell('Amount (USD)', isHeader: true),
                        _buildTableCell('Percentage', isHeader: true),
                      ],
                    ),
                    ...categoryTotals.entries.map((entry) {
                      final percentage =
                          ((entry.value / (totalExpenses + totalIncome)) * 100);
                      return pw.TableRow(
                        children: [
                          _buildTableCell(entry.key),
                          _buildTableCell(
                            '\$${entry.value.toStringAsFixed(2)}',
                          ),
                          _buildTableCell('${percentage.toStringAsFixed(1)}%'),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 30),
              ],

              // Transactions Table
              pw.Text(
                'Transactions',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              if (transactions.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Center(
                    child: pw.Text(
                      'No transactions found for the selected period.',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(3),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        _buildTableCell('Date', isHeader: true),
                        _buildTableCell('Category', isHeader: true),
                        _buildTableCell('Description', isHeader: true),
                        _buildTableCell('Amount', isHeader: true),
                        _buildTableCell('Type', isHeader: true),
                      ],
                    ),
                    // Data rows
                    ...transactions.map(
                      (transaction) => pw.TableRow(
                        children: [
                          _buildTableCell(
                            DateFormat('MMM dd, yyyy').format(transaction.date),
                          ),
                          _buildTableCell(transaction.category),
                          _buildTableCell(transaction.description ?? '-'),
                          _buildTableCell(
                            '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                            textColor: transaction.type == 'expense'
                                ? PdfColors.red
                                : PdfColors.green,
                          ),
                          _buildTableCell(
                            transaction.type == 'expense' ? 'OUT' : 'IN',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ];
          },
        ),
      );

      // Save PDF to temporary directory
      final Uint8List pdfBytes = await pdf.save();
      final directory = await getTemporaryDirectory();
      final file = File(
        path.join(
          directory.path,
          'transaction_report_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
        ),
      );

      await file.writeAsBytes(pdfBytes);

      // Share the PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Transaction Report - PDF Export',
        subject: 'Expense Tracker Report',
      );
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  static pw.Widget _buildSummaryItem(
    String label,
    double amount,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '\$${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor? textColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? (isHeader ? PdfColors.black : PdfColors.grey800),
        ),
      ),
    );
  }
}
