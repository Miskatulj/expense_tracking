import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() => runApp(const ExpenseTrackerApp());

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Expense Tracker',
    theme: AppTheme.light,
    home: const DashboardScreen(),
  );
}
