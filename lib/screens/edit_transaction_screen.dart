import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final ExpenseTransaction transaction;

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late Future<ExpenseTransaction?> _transaction;

  @override
  void initState() {
    super.initState();
    final id = widget.transaction.id;
    _transaction = id == null
        ? Future<ExpenseTransaction?>.value(null)
        : DatabaseHelper.instance.getTransaction(id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExpenseTransaction?>(
      future: _transaction,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Unable to load this transaction.')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final transaction = snapshot.data;
        if (transaction == null) {
          return const Scaffold(
            body: Center(child: Text('This transaction no longer exists.')),
          );
        }
        return AddTransactionScreen(transaction: transaction);
      },
    );
  }
}
