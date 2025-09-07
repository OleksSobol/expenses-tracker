// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_filter_bar.dart';
import '../models/transaction_list_item.dart';
import '../models/transaction_service.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Map<String, dynamic>> _allTransactions = [];
  TransactionFilter _filter = const TransactionFilter();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await _transactionService.getAllTransactions();
    setState(() {
      _allTransactions = transactions;
    });
  }

  void _onFilterChanged(TransactionFilter newFilter) {
    setState(() {
      _filter = newFilter;
    });
  }

  Future<void> _onTransactionTap(Map<String, dynamic> transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
    if (result == true) _loadTransactions();
  }

  Future<void> _onTransactionDelete(Map<String, dynamic> transaction) async {
    await _transactionService.deleteTransaction(transaction['id']);
    setState(() {
      _allTransactions.removeWhere((tx) => tx['id'] == transaction['id']);
    });
  }

  Future<void> _onAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionScreen()),
    );
    if (result == true) {
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _transactionService.filterAndSortTransactions(
      _allTransactions, 
      _filter
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses Tracker')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _onAddTransaction,
      ),
      body: Column(
        children: [
          TransactionFilterBar(
            filter: _filter,
            onFilterChanged: _onFilterChanged,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return TransactionListItem(
                  transaction: transaction,
                  onTap: () => _onTransactionTap(transaction),
                  onDelete: () => _onTransactionDelete(transaction),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}