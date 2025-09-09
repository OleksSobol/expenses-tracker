// lib/screens/bills_screen.dart
import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/bill_service.dart';
import 'add_bill_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({Key? key}) : super(key: key);

  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final BillService _billService = BillService();
  List<Bill> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    try {
      setState(() => _isLoading = true);
      
      final billsData = await _billService.getAllBills();
      final bills = billsData.map((map) => Bill.fromMap(map)).toList();
      
      setState(() {
        _bills = bills;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bills: $e')),
      );
    }
  }

  Color _getDueColor(Bill bill) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(bill.nextDueDate.year, bill.nextDueDate.month, bill.nextDueDate.day);
    final daysDiff = dueDate.difference(today).inDays;

    if (daysDiff < 0) return Colors.red; // overdue
    if (daysDiff <= 3) return Colors.orange; // due soon
    return Colors.green; // normal
  }

  String _getDueText(Bill bill) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(bill.nextDueDate.year, bill.nextDueDate.month, bill.nextDueDate.day);
    final daysDiff = dueDate.difference(today).inDays;

    if (daysDiff < 0) {
      return daysDiff == -1 ? 'Overdue by 1 day' : 'Overdue by ${-daysDiff} days';
    } else if (daysDiff == 0) {
      return 'Due today';
    } else if (daysDiff == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $daysDiff days';
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _navigateToAddBill([Bill? bill]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBillScreen(bill: bill),
      ),
    );

    // Reload bills if something changed
    if (result == true) {
      _loadBills();
    }
  }

  Future<void> _deleteBill(Bill bill) async {
    if (bill.id == null) return;

    try {
      await _billService.deleteBill(bill.id!);
      _loadBills(); // Reload the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${bill.name} deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting bill: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bills'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBill(),
        child: Icon(Icons.add),
        tooltip: 'Add Bill',
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? _buildEmptyState()
              : _buildBillsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No bills yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first bill',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList() {
    return RefreshIndicator(
      onRefresh: _loadBills,
      child: ListView.builder(
        itemCount: _bills.length,
        padding: EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final bill = _bills[index];
          final dueColor = _getDueColor(bill);
          
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: Dismissible(
              key: Key('bill_${bill.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.red,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Bill'),
                    content: Text('Delete "${bill.name}"?'),
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
              },
              onDismissed: (direction) => _deleteBill(bill),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        bill.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (bill.notes != null && bill.notes!.isNotEmpty)
                      Icon(
                        Icons.note,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      _getDueText(bill),
                      style: TextStyle(
                        color: dueColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Repeats ${_capitalize(bill.frequency)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '\$${bill.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onTap: () => _navigateToAddBill(bill),
              ),
            ),
          );
        },
      ),
    );
  }
}