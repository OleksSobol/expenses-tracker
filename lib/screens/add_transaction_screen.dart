import 'package:flutter/material.dart';
import '../services/db_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final db = DBService();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  int _categoryId = 1;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Amount'),
            ),
            DropdownButton<String>(
              value: _type,
              items: ['income', 'expense'].map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.toUpperCase()),
              )).toList(),
              onChanged: (val) => setState(() => _type = val!),
            ),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Note'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                double? amount = double.tryParse(_amountController.text);
                if (amount == null) return;

                await db.insert('transactions', {
                  'amount': amount,
                  'type': _type,
                  'categoryId': _categoryId,
                  'date': _selectedDate.toIso8601String(),
                  'note': _noteController.text,
                });

                Navigator.pop(context); // go back to HomeScreen
              },
              child: Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
