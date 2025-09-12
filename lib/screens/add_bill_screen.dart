// lib/screens/add_bill_screen.dart
import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/bill_service.dart';

class AddBillScreen extends StatefulWidget {
  final Bill? bill; // null for new bill, Bill object for editing

  const AddBillScreen({super.key, this.bill});

  @override
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final BillService _billService = BillService();

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _nextDueDate;
  late String _frequency;
  late TextEditingController _linkController;

  bool get isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();
    // Initialize with existing bill data or defaults
    _nameController = TextEditingController(text: widget.bill?.name ?? '');
    _amountController = TextEditingController(
      text: widget.bill?.amount.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.bill?.notes ?? '');
    _nextDueDate = widget.bill?.nextDueDate ?? DateTime.now().add(Duration(days: 30));
    _frequency = widget.bill?.frequency ?? 'monthly';
    _linkController = TextEditingController(text: widget.bill?.link ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _nextDueDate = picked;
      });
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;

    // Create bill object
    final bill = Bill(
      id: isEditing ? widget.bill!.id : null, // keep existing ID or null for new
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      nextDueDate: _nextDueDate,
      frequency: _frequency,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      link: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
    );

    try {
      if (isEditing) {
        // Update existing bill
        await _billService.updateBill(widget.bill!.id!, bill);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bill updated successfully')),
        );
      } else {
        // Add new bill
        await _billService.addBill(bill);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bill added successfully')),
        );
      }
      
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving bill: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Bill' : 'Add Bill'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Bill'),
                    content: Text('Are you sure you want to delete this bill?'),
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
                  await _billService.deleteBill(widget.bill!.id!);
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
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Bill Name',
                    hintText: 'e.g., Electric Bill',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a bill name';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16),
                
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
                
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Next Due Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_nextDueDate.month.toString().padLeft(2, '0')}-${_nextDueDate.day.toString().padLeft(2, '0')}-${_nextDueDate.year}',
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  initialValue: _frequency,
                  decoration: InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                  items: ['daily', 'weekly', 'monthly', 'yearly']
                      .map((freq) => DropdownMenuItem(
                            value: freq,
                            child: Text(_capitalize(freq)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _frequency = value;
                      });
                    }
                  },
                ),
                
                SizedBox(height: 16),
                
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Website, account number, or other info...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
               
                SizedBox(height: 16),

                TextFormField(
                  controller: _linkController,
                  decoration: InputDecoration(
                    labelText: 'Bill Link (Optional)',
                    hintText: 'https://example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final urlPattern = r'^https?:\/\/[^\s]+$';
                      final regExp = RegExp(urlPattern);
                      if (!regExp.hasMatch(value.trim())) {
                        return 'Enter a valid URL starting with http:// or https://';
                      }
                    }
                    return null;
                  },
                ),

                SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _saveBill,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    // padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  
                  child: Text(
                    isEditing ? 'Update Bill' : 'Add Bill',
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
}