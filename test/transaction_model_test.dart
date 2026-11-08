import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/transaction_model.dart';

void main() {
  test('transaction converts to and from a database map', () {
    final transaction = ExpenseTransaction(
      id: 7,
      title: 'Salary',
      amount: 12500.5,
      category: 'Salary',
      type: 'Income',
      date: DateTime(2026, 11, 6),
    );
    final restored = ExpenseTransaction.fromMap(transaction.toMap());
    expect(restored.id, 7);
    expect(restored.amount, 12500.5);
    expect(restored.isIncome, isTrue);
    expect(restored.date, DateTime(2026, 11, 6));
  });
}
