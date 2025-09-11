// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';
import '../models/category.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_summary.dart';
import '../services/transaction_service.dart';
import 'add_transaction_screen.dart';
import 'categories_screen.dart';

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

  Future<void> _openCategoriesScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoriesScreen()),
    );
    if (result == true) {
      setState(() {}); // Refresh to update category filters
    }
  }

  String _getSortLabel() {
    switch (_filter.sortBy) {
      case 'date_desc': return 'Date ↓';
      case 'date_asc': return 'Date ↑';
      case 'amount_desc': return 'Amount ↓';
      case 'amount_asc': return 'Amount ↑';
      default: return 'Sort';
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
          
          // Compact Filter bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Column(
              children: [
                // First row: Type and Sort
                Row(
                  children: [
                    // Type filter - compact chips
                    Expanded(
                      child: Row(
                        children: [
                          _buildCompactFilterChip('All', _filter.type == 'all', () {
                            _onFilterChanged(_filter.copyWith(type: 'all'));
                          }),
                          SizedBox(width: 6),
                          _buildCompactFilterChip('Income', _filter.type == 'income', () {
                            _onFilterChanged(_filter.copyWith(type: 'income'));
                          }),
                          SizedBox(width: 6),
                          _buildCompactFilterChip('Expense', _filter.type == 'expense', () {
                            _onFilterChanged(_filter.copyWith(type: 'expense'));
                          }),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Sort dropdown - compact
                    Container(
                      height: 32,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filter.sortBy,
                          isDense: true,
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                          items: [
                            DropdownMenuItem(value: 'date_desc', child: Text('Date ↓')),
                            DropdownMenuItem(value: 'date_asc', child: Text('Date ↑')),
                            DropdownMenuItem(value: 'amount_desc', child: Text('Amount ↓')),
                            DropdownMenuItem(value: 'amount_asc', child: Text('Amount ↑')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _onFilterChanged(_filter.copyWith(sortBy: value));
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Second row: Category filter (only if there are categories)
                if (categories.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCompactFilterChip('All Categories', _filter.categoryId == null, () {
                                _onFilterChanged(_filter.clearCategory());
                              }),
                              SizedBox(width: 6),
                              ...categories.map((cat) => Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: _buildCompactCategoryChip(cat),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
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

  Widget _buildCompactFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCategoryChip(Category category) {
    final isSelected = _filter.categoryId == category.id;
    return GestureDetector(
      onTap: () {
        _onFilterChanged(_filter.copyWith(categoryId: category.id));
      },
      child: Container(
        height: 28,
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? category.color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? category.color : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 14, color: category.color),
            SizedBox(width: 4),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? category.color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}