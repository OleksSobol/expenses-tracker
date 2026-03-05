// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';
import '../models/category.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_summary.dart';
import '../services/transaction_service.dart';
import '../theme/app_tokens.dart';
import 'add_transaction_screen.dart';
import '../widgets/transaction_filter_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    _loadCategories();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _transactionService.getAllTransactions();
      setState(() {
        _allTransactions = transactions;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load transactions: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadTransactions,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      await CategoryService.loadCategories();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    try {
      await _transactionService.deleteTransaction(transaction['id']);
      setState(() {
        _allTransactions.removeWhere((tx) => tx['id'] == transaction['id']);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete transaction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        actions: [],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTransaction,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Summary
          TransactionSummary(
            income: filteredTransactions
              .where((tx) => tx['type'] == 'income')
              .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble()),
            expense: filteredTransactions
              .where((tx) => tx['type'] == 'expense')
              .fold(0.0, (sum, tx) => sum + (tx['amount'] as num).toDouble()),
            balance: filteredTransactions.fold(
              0.0,
              (sum, tx) => tx['type'] == 'income'
                  ? sum + (tx['amount'] as num).toDouble()
                  : sum - (tx['amount'] as num).toDouble(),
            ),
          ),
          
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
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No transactions yet',
                          style: AppTypography.sectionTitle.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tap + to add your first transaction',
                          style: AppTypography.caption,
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