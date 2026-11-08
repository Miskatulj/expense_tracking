import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/app_theme.dart';
import '../widgets/transaction_item.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({super.key, required this.transaction});
  final ExpenseTransaction transaction;
  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late ExpenseTransaction _transaction;
  bool _changed = false;
  bool _deleting = false;
  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: _transaction),
      ),
    );
    if (changed == true) {
      final refreshed = await DatabaseHelper.instance.getTransaction(
        _transaction.id!,
      );
      if (!mounted || refreshed == null) return;
      setState(() {
        _transaction = refreshed;
        _changed = true;
      });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || _deleting) return;
    setState(() => _deleting = true);
    try {
      await DatabaseHelper.instance.deleteTransaction(_transaction.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Transaction deleted.')));
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not delete the transaction. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  void _close() => Navigator.pop(context, _changed);

  @override
  Widget build(BuildContext context) {
    final income = _transaction.isIncome;
    final color = income ? AppTheme.income : AppTheme.expense;
    final money = NumberFormat.currency(
      locale: 'en_BD',
      symbol: '৳',
      decimalDigits: 2,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Transaction Details',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
          actions: [
            IconButton(onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
            IconButton(
              onPressed: _deleting ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        categoryIcon(_transaction.category),
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _transaction.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 23,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${income ? '+' : '-'}${money.format(_transaction.amount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _row('Transaction ID', '#${_transaction.id}'),
              _row('Category', _transaction.category),
              _row('Transaction Type', _transaction.type),
              _row(
                'Date',
                DateFormat('dd MMMM yyyy').format(_transaction.date),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Transaction'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _deleting ? null : _delete,
                icon: const Icon(Icons.delete_outline),
                label: Text(_deleting ? 'Deleting...' : 'Delete Transaction'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppTheme.expense,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}
