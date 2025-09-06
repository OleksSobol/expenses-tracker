import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/category.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final db = DBService();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _type = 'expense';
  int? _categoryId = categories.first.id;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount field
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an amount';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Income / Expense toggle
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14), // taller
                        child: Text(
                          "Expense",
                          style: TextStyle(
                            color: _type == 'expense' ? Colors.red : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // bigger text
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      selected: _type == 'expense',
                      selectedColor: Colors.red.shade100,
                      onSelected: (_) => setState(() => _type = 'expense'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14), // taller
                        child: Text(
                          "Income",
                          style: TextStyle(
                            color: _type == 'income' ? Colors.green : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // bigger text
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      selected: _type == 'income',
                      selectedColor: Colors.green.shade100,
                      onSelected: (_) => setState(() => _type = 'income'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

                SizedBox(height: 16),

                // Category selector
                GestureDetector(
                  onTap: () async {
                    final selected = await showModalBottomSheet<int>(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => ListView(
                        padding: EdgeInsets.all(16),
                        children: categories.map((cat) {
                          return ListTile(
                            leading: Icon(cat.icon, color: cat.color),
                            title: Text(cat.name),
                            onTap: () => Navigator.pop(context, cat.id),
                          );
                        }).toList(),
                      ),
                    );
                    if (selected != null) setState(() => _categoryId = selected);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400),
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _categoryId != null
                              ? categories.firstWhere((c) => c.id == _categoryId).name
                              : "Select Category",
                          style: TextStyle(fontSize: 16),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Note field
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(labelText: 'Note'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a note';
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Date & Time picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.access_time, color: Colors.blue),
                  title: Text("Date & Time", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    DateFormat('MMM d, yyyy hh:mm a').format(
                      DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      ),
                    ),
                  ),
                  trailing: Icon(Icons.edit, color: Colors.grey),
                  onTap: _pickDateTime,
                ),

                SizedBox(height: 32),

                // Save Transaction button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _saveTransaction,
                    child: Text('Save Transaction'),
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
    if (_formKey.currentState!.validate()) {
      double amount = double.parse(_amountController.text);

      await db.insert('transactions', {
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
        'note': _noteController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction saved!')),
      );

      Navigator.pop(context, true);
    }
  }
}
