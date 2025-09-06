import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DBService();
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final rows = await db.queryAll('transactions');
    setState(() {
      transactions = rows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expenses Tracker')),
      floatingActionButton:  FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
          if (result == true) {
            _loadTransactions();
          }
        },
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await db.insert('transactions', {
                'amount': 12.5,
                'type': 'expense',
                'categoryId': 1,
                'date': DateTime.now().toIso8601String(),
                'note': 'Coffee',
              });
              _loadTransactions(); // Refresh list
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaction added')));
            },
            child: Text('Add Transaction'),
          ),
          ElevatedButton(
            onPressed: () async {
              await db.clearTable('transactions');
              _loadTransactions(); // refresh list
            },
            child: Text('Clear All Transactions'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return ListTile(
                  title: Text('${tx['note']} - \$${tx['amount']}'),
                  subtitle: Text('${tx['type']} | ${tx['date']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

