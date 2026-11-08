class ExpenseTransaction {
  const ExpenseTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  final int? id;
  final String title;
  final double amount;
  final String category;
  final String type;
  final DateTime date;

  bool get isIncome => type.trim().toLowerCase() == 'income';

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'type': type,
    'date': date.toIso8601String(),
  };

  factory ExpenseTransaction.fromMap(Map<String, Object?> map) {
    return ExpenseTransaction(
      id: map['id'] as int?,
      title: map['title']! as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category']! as String,
      type: map['type']! as String,
      date: DateTime.parse(map['date']! as String),
    );
  }

  ExpenseTransaction copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? type,
    DateTime? date,
  }) => ExpenseTransaction(
    id: id ?? this.id,
    title: title ?? this.title,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    type: type ?? this.type,
    date: date ?? this.date,
  );
}
