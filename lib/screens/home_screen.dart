// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_summary.dart';
import '../services/transaction_service.dart';
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
      appBar: AppBar(
        title: const Text('Expenses Tracker'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _onAddTransaction,
      ),
      body: Column(
        children: [
          // Summary
          TransactionSummary(
            income: _allTransactions
              .where((tx) => tx['type'] == 'income')
              .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble()),
            expense: _allTransactions
              .where((tx) => tx['type'] == 'expense')
              .fold(0.0,(sum, tx) => sum + (tx['amount'] as num).toDouble()),
            balance: _allTransactions.fold(
              0.0,
              (sum, tx) => tx['type'] == 'income'
                  ? sum + (tx['amount'] as num).toDouble()
                  : sum - (tx['amount'] as num).toDouble(),
              ),
          ),
          // Filter bar
          TransactionFilterBar(
            filter: _filter,
            onFilterChanged: _onFilterChanged,
          ),

          // Transaction list
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap + to add your first transaction',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
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
          ),
        ],
      ),
    );
  }
}