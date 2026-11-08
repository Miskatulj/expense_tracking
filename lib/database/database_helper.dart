import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  /// Increments only after a database mutation has completed successfully.
  /// Screens can listen to this instead of retaining calculated values that
  /// predate an insert, update, or delete.
  final ValueNotifier<int> transactionRevision = ValueNotifier<int>(0);

  void _notifyTransactionChange() {
    transactionRevision.value++;
  }

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;
    final path = join(await getDatabasesPath(), 'expense_tracker.db');
    return _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(ExpenseTransaction transaction) async {
    final id = await (await database).insert(
      'transactions',
      transaction.toMap(),
    );
    if (id <= 0) {
      throw StateError('The transaction could not be saved.');
    }
    _notifyTransactionChange();
    return id;
  }

  Future<List<ExpenseTransaction>> getTransactions() async {
    final rows = await (await database).query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  /// Loads only the items shown in the dashboard's Recent Transactions area.
  /// Totals are deliberately calculated by separate, full-table queries.
  Future<List<ExpenseTransaction>> getRecentTransactions({
    int limit = 3,
  }) async {
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'Must be greater than zero.');
    }
    final rows = await (await database).query(
      'transactions',
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  /// Loads dashboard-specific data from SQLite in a single consistent read.
  /// The recent-record limit never applies to either aggregate query.
  Future<DashboardSnapshot> getDashboardSnapshot() async {
    final db = await database;
    return db.transaction((transaction) async {
      final recentRows = await transaction.query(
        'transactions',
        orderBy: 'date DESC, id DESC',
        limit: 3,
      );
      final income = await _totalForExecutor(transaction, 'Income');
      final expenses = await _totalForExecutor(transaction, 'Expense');
      return DashboardSnapshot(
        transactions: recentRows.map(ExpenseTransaction.fromMap).toList(),
        income: income,
        expenses: expenses,
        balance: income - expenses,
      );
    });
  }

  Future<ExpenseTransaction?> getTransaction(int id) async {
    final rows = await (await database).query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return rows.isEmpty ? null : ExpenseTransaction.fromMap(rows.first);
  }

  Future<int> updateTransaction(ExpenseTransaction transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('A transaction ID is required for updates.');
    }
    final affectedRows = await (await database).update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    if (affectedRows != 1) {
      throw StateError('The transaction no longer exists and was not updated.');
    }
    _notifyTransactionChange();
    return affectedRows;
  }

  Future<int> deleteTransaction(int id) async {
    final affectedRows = await (await database).delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (affectedRows != 1) {
      throw StateError('The transaction no longer exists and was not deleted.');
    }
    _notifyTransactionChange();
    return affectedRows;
  }

  Future<double> _totalFor(String type) async =>
      _totalForExecutor(await database, type);

  Future<double> _totalForExecutor(
    DatabaseExecutor executor,
    String type,
  ) async {
    final result = await executor.rawQuery(
      '''
        SELECT COALESCE(SUM(CAST(amount AS REAL)), 0.0) AS total
        FROM transactions
        WHERE LOWER(TRIM(type)) = ?
      ''',
      [type.toLowerCase()],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> totalIncome() => _totalFor('Income');
  Future<double> totalExpenses() => _totalFor('Expense');
  Future<double> currentBalance() async =>
      (await totalIncome()) - (await totalExpenses());
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.transactions,
    required this.income,
    required this.expenses,
    required this.balance,
  });

  final List<ExpenseTransaction> transactions;
  final double income;
  final double expenses;
  final double balance;
}
