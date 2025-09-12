import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/category.dart';
import 'package:intl/intl.dart';
import '../utils/custom_buttons.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final db = DBService();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _type = 'expense';
  int? _categoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!['amount'].toString();
      _noteController.text = widget.transaction!['note'];
      _type = widget.transaction!['type'];
      _categoryId = widget.transaction!['categoryId'];
      DateTime dt = DateTime.parse(widget.transaction!['date']);
      _selectedDate = dt;
      _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    }
      if (_categoryId == null && categoriesNotifier.value.isNotEmpty) {
          _categoryId = categoriesNotifier.value.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Transaction'),
                    content: Text('Are you sure you want to delete this transaction?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  await db.delete('transactions', widget.transaction!['id']);
                  Navigator.pop(context, true);
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount field - styled like bill screen
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Transaction Type - improved styling
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 12, top: 8),
                        child: Text(
                          'Transaction Type',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            buildTransactionTypeButton(
                              context: context,
                              label: "Expense",
                              color: Colors.red,
                              isSelected: _type == 'expense',
                              onTap: () => setState(() => _type = 'expense'),
                            ),
                            SizedBox(width: 12),
                            buildTransactionTypeButton(
                              context: context,
                              label: "Income",
                              color: Colors.green,
                              isSelected: _type == 'income',
                              onTap: () => setState(() => _type = 'income'),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Category selector
                ValueListenableBuilder<List<Category>>(
                  valueListenable: categoriesNotifier,
                  builder: (context, categories, _) {
                    if (_categoryId == null && categories.isNotEmpty) {
                      _categoryId = categories.first.id;
                    }
                    return InkWell(
                      onTap: () async {
                        final selected = await showModalBottomSheet<int>(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) => Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Category',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Flexible(
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: categories.map((cat) {
                                      return ListTile(
                                        leading: Icon(cat.icon, color: cat.color),
                                        title: Text(cat.name),
                                        onTap: () => Navigator.pop(context, cat.id),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        if (selected != null) setState(() => _categoryId = selected);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child: Row(
                          children: [
                            if (_categoryId != null) ...[
                              Icon(
                                categories.firstWhere((c) => c.id == _categoryId).icon,
                                color: categories.firstWhere((c) => c.id == _categoryId).color,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                            ],
                            Text(
                              _categoryId != null
                                  ? categories.firstWhere((c) => c.id == _categoryId).name
                                  : "Select Category",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16),

                // Note field - styled like bill screen
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note',
                    hintText: 'Add a description for this transaction...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a note';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 32),

                // Save button - styled like bill screen
                ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(
                    isEditing ? 'Update Transaction' : 'Save Transaction',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    double amount = double.parse(_amountController.text);

    final data = {
      'amount': amount,
      'type': _type,
      'categoryId': _categoryId,
      'date': DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ).toIso8601String(),
      'note': _noteController.text.trim(),
    };

    try {
      if (isEditing) {
        // Update existing transaction
        await db.update('transactions', widget.transaction!['id'], data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction updated successfully')),
        );
      } else {
        // Insert new transaction
        await db.insert('transactions', data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction added successfully')),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving transaction: $e')),
      );
    }
  }
}