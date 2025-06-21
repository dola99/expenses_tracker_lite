import 'package:equatable/equatable.dart';

class IncomeModel extends Equatable {
  final String id;
  final String category;
  final double amount;
  final double amountInUSD;
  final String currency;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  const IncomeModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.amountInUSD,
    required this.currency,
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      amountInUSD: (json['amountInUSD'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'amountInUSD': amountInUSD,
      'currency': currency,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  IncomeModel copyWith({
    String? id,
    String? category,
    double? amount,
    double? amountInUSD,
    String? currency,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      amountInUSD: amountInUSD ?? this.amountInUSD,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    amount,
    amountInUSD,
    currency,
    description,
    date,
    createdAt,
  ];
}

// Income categories
class IncomeCategories {
  static const String salary = 'Salary';
  static const String freelance = 'Freelance';
  static const String business = 'Business';
  static const String investment = 'Investment';
  static const String rental = 'Rental';
  static const String bonus = 'Bonus';
  static const String gift = 'Gift';
  static const String other = 'Other';

  static const List<String> all = [
    salary,
    freelance,
    business,
    investment,
    rental,
    bonus,
    gift,
    other,
  ];
}
