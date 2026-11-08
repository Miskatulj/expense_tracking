import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../utils/app_theme.dart';

IconData categoryIcon(String category) => switch (category) {
  'Food' => Icons.restaurant_rounded,
  'Transport' => Icons.directions_bus_rounded,
  'Shopping' => Icons.shopping_bag_rounded,
  'Education' => Icons.school_rounded,
  'Medical' => Icons.medical_services_rounded,
  'Bills' => Icons.receipt_long_rounded,
  'Entertainment' => Icons.movie_rounded,
  'Salary' => Icons.account_balance_wallet_rounded,
  'Tuition' => Icons.menu_book_rounded,
  'Freelancing' => Icons.laptop_mac_rounded,
  'Business' => Icons.storefront_rounded,
  'Gift' => Icons.card_giftcard_rounded,
  _ => Icons.category_rounded,
};

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.transaction, this.onTap});
  final ExpenseTransaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final income = transaction.isIncome;
    final color = income ? AppTheme.income : AppTheme.expense;
    final money = NumberFormat.currency(
      locale: 'en_BD',
      symbol: '৳',
      decimalDigits: 2,
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(categoryIcon(transaction.category), color: color),
        ),
        title: Text(
          transaction.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${transaction.category} • ${DateFormat('dd MMM yyyy').format(transaction.date)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${income ? '+' : '-'}${money.format(transaction.amount)}',
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              transaction.type,
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
