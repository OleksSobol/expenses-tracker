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
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                DropdownButton<String>(
                  value: _type,
                  items: ['income', 'expense']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _type = val!),
                ),
                DropdownButton<int>(
                  value: _categoryId,
                  items: categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Row(
                        children: [
                          Icon(cat.icon, color: cat.color),
                          SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _categoryId = val!),
                ),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(labelText: 'Note'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a note';
                    }
                    return null;
                  },
                ),
                // Row(
                //   children: [
                //     Text("Date: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
                //     TextButton(
                //       child: Text("Pick Date"),
                //       onPressed: () async {
                //         final picked = await showDatePicker(
                //           context: context,
                //           initialDate: _selectedDate,
                //           firstDate: DateTime(2000),
                //           lastDate: DateTime(2100),
                //         );
                //         if (picked != null) {
                //           setState(() => _selectedDate = picked);
                //         }
                //       },
                //     ),
                //   ],
                // ),
                
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: Text(
                    'Pick Date & Time: ${DateFormat('MMM d, yyyy hh:mm a').format(
                      DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      ),
                    )}',
                  ),
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
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
                        SnackBar(content: Text('Transation saved!'))
                      );
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text('Save Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
  // Date picker
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDate != null) {
    // Time picker
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

}


