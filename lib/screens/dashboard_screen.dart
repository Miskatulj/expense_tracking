import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../utils/app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';
import 'transaction_details_screen.dart';
import 'transaction_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSnapshot> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
    DatabaseHelper.instance.transactionRevision.addListener(_onDatabaseChanged);
  }

  Future<DashboardSnapshot> _load() =>
      DatabaseHelper.instance.getDashboardSnapshot();

  void _onDatabaseChanged() {
    if (mounted) {
      _refresh();
    }
  }

  Future<void> _refresh() {
    final latestData = _load();
    if (mounted) {
      setState(() => _data = latestData);
    }
    return latestData;
  }

  @override
  void dispose() {
    DatabaseHelper.instance.transactionRevision.removeListener(
      _onDatabaseChanged,
    );
    super.dispose();
  }

  Future<void> _open(Widget page) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Expense Tracker',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _open(const AddTransactionScreen()),
      icon: const Icon(Icons.add),
      label: const Text('Add'),
    ),
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<DashboardSnapshot>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Unable to load your transactions.')),
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
            final data = snapshot.data!;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  child: Text(
                    'Your financial overview',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final w = (c.maxWidth - 10) / 2;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: w,
                            child: SummaryCard(
                              label: 'Total Income',
                              amount: data.income,
                              color: AppTheme.income,
                              icon: Icons.south_west_rounded,
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: SummaryCard(
                              label: 'Total Expense',
                              amount: data.expenses,
                              color: AppTheme.expense,
                              icon: Icons.north_east_rounded,
                            ),
                          ),
                          SizedBox(
                            width: c.maxWidth,
                            child: SummaryCard(
                              label: 'Current Balance',
                              amount: data.balance,
                              color: AppTheme.balance,
                              icon: Icons.account_balance_wallet_rounded,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 12, 8),
                  child: Row(
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _open(const TransactionListScreen()),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                if (data.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(36),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: Colors.black38,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap Add to record your first income or expense.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...data.transactions.map(
                    (t) => TransactionItem(
                      transaction: t,
                      onTap: () =>
                          _open(TransactionDetailsScreen(transaction: t)),
                    ),
                  ),
                const SizedBox(height: 90),
              ],
            );
          },
        ),
      ),
    ),
  );
}
