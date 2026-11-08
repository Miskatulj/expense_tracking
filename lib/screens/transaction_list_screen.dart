import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_item.dart';
import 'transaction_details_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});
  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  late Future<List<ExpenseTransaction>> _transactions;
  bool _changed = false;
  @override
  void initState() {
    super.initState();
    _transactions = DatabaseHelper.instance.getTransactions();
  }

  Future<void> _refresh() {
    final latestTransactions = DatabaseHelper.instance.getTransactions();
    if (mounted) {
      setState(() => _transactions = latestTransactions);
    }
    return latestTransactions;
  }

  Future<void> _open(ExpenseTransaction t) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailsScreen(transaction: t),
      ),
    );
    if (!mounted) return;
    if (changed == true) {
      _changed = true;
    }
    if (mounted) {
      await _refresh();
    }
  }

  void _close() => Navigator.pop(context, _changed);

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _close();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _close,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text(
          'All Transactions',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ExpenseTransaction>>(
          future: _transactions,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Unable to load transactions.')),
                ],
              );
            }
            if (!snapshot.hasData) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            final items = snapshot.data!;
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 60,
                          color: Colors.black38,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No transactions to show',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Your saved transactions will appear here.'),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (_, index) => TransactionItem(
                transaction: items[index],
                onTap: () => _open(items[index]),
              ),
            );
          },
        ),
      ),
    ),
  );
}
