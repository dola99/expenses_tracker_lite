import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String currency;

  @HiveField(4)
  final double amountInUSD;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final String? receiptPath;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
    required this.amountInUSD,
    required this.date,
    this.description,
    this.receiptPath,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new expense with generated ID and timestamps
  factory ExpenseModel.create({
    required String category,
    required double amount,
    required String currency,
    required double amountInUSD,
    required DateTime date,
    String? description,
    String? receiptPath,
  }) {
    final now = DateTime.now();
    return ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      amount: amount,
      currency: currency,
      amountInUSD: amountInUSD,
      date: date,
      description: description,
      receiptPath: receiptPath,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy with updated fields
  ExpenseModel copyWith({
    String? id,
    String? category,
    double? amount,
    String? currency,
    double? amountInUSD,
    DateTime? date,
    String? description,
    String? receiptPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      amountInUSD: amountInUSD ?? this.amountInUSD,
      date: date ?? this.date,
      description: description ?? this.description,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'currency': currency,
      'amountInUSD': amountInUSD,
      'date': date.toIso8601String(),
      'description': description,
      'receiptPath': receiptPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      amountInUSD: (json['amountInUSD'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      receiptPath: json['receiptPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    amount,
    currency,
    amountInUSD,
    date,
    description,
    receiptPath,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'ExpenseModel(id: $id, category: $category, amount: $amount, currency: $currency, date: $date)';
  }
}
