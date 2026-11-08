import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.transaction});
  final ExpenseTransaction? transaction;
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'Expense';
  String? _category;
  DateTime? _date;
  bool _saving = false;
  bool get _editing => widget.transaction != null;
  List<String> get _categories => _type == 'Income'
      ? const ['Salary', 'Tuition', 'Freelancing', 'Business', 'Gift', 'Others']
      : const [
          'Food',
          'Transport',
          'Shopping',
          'Education',
          'Medical',
          'Bills',
          'Entertainment',
          'Others',
        ];

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    if (t != null) {
      _titleController.text = t.title;
      _amountController.text = t.amount.toStringAsFixed(2);
      _type = t.type;
      _category = t.category;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a transaction date.')),
      );
      return;
    }
    setState(() => _saving = true);
    final transaction = ExpenseTransaction(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _category!,
      type: _type,
      date: _date!,
    );
    try {
      if (_editing) {
        await DatabaseHelper.instance.updateTransaction(transaction);
      } else {
        await DatabaseHelper.instance.insertTransaction(transaction);
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editing
                ? 'Transaction updated successfully.'
                : 'Transaction saved successfully.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the transaction. Please try again.'),
          ),
        );
      }
    }
    if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_editing ? 'Edit Transaction' : 'Add Transaction'),
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _editing ? 'Update your transaction' : 'Record a transaction',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text('Keep your spending picture clear and up to date.'),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a title.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '৳ ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                final value = double.tryParse(v?.trim() ?? '');
                return value == null || value <= 0
                    ? 'Enter an amount greater than zero.'
                    : null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Transaction type',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Expense',
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: 'Income',
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() {
                _type = v.first;
                _category = null;
              }),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Select a category.' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _chooseDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _date == null
                      ? 'Select a date'
                      : DateFormat('dd MMMM yyyy').format(_date!),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _saving
                    ? 'Saving...'
                    : _editing
                    ? 'Update Transaction'
                    : 'Save Transaction',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
