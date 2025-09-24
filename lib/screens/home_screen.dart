// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';
import '../models/category.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_summary.dart';
import '../services/transaction_service.dart';
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
    final transactions = await _transactionService.getAllTransactions();
    setState(() {
      _allTransactions = transactions;
    });
  }

  Future<void> _loadCategories() async {
    await CategoryService.loadCategories();
    setState(() {});
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

          // Compact Filter bar
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).colorScheme.surface,
          //     border: Border(
          //       bottom: BorderSide(
          //         color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12), 
          //         width: 1),
          //     ),
          //   ),
          //   child: Column(
          //     children: [
          //       // First row: Type and Sort
          //       Row(
          //         children: [
          //           // Type filter - compact chips
          //           Expanded(
          //             child: Row(
          //               children: [
          //                 _buildCompactFilterChip('All', _filter.type == 'all', () {
          //                   _onFilterChanged(_filter.copyWith(type: 'all'));
          //                 }),
          //                 SizedBox(width: 6),
          //                 _buildCompactFilterChip('Income', _filter.type == 'income', () {
          //                   _onFilterChanged(_filter.copyWith(type: 'income'));
          //                 }),
          //                 SizedBox(width: 6),
          //                 _buildCompactFilterChip('Expense', _filter.type == 'expense', () {
          //                   _onFilterChanged(_filter.copyWith(type: 'expense'));
          //                 }),
          //               ],
          //             ),
          //           ),
                    
          //           SizedBox(width: 12),
                    
          //           // Sort dropdown - compact
          //           Container(
          //             height: 32,
          //             padding: EdgeInsets.symmetric(horizontal: 12),
          //             decoration: BoxDecoration(
          //               color: Theme.of(context).colorScheme.surface,
          //               borderRadius: BorderRadius.circular(16),
          //               border: Border.all(
          //                 color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .12)),
          //             ),
          //             child: DropdownButtonHideUnderline(
          //               child: DropdownButton<String>(
          //                 value: _filter.sortBy,
          //                 isDense: true,
          //                 style: TextStyle(
          //                   fontSize: 13, 
          //                   color: Theme.of(context).colorScheme.onSurface),
          //                 items: [
          //                   DropdownMenuItem(value: 'date_desc', child: Text('Date ↓')),
          //                   DropdownMenuItem(value: 'date_asc', child: Text('Date ↑')),
          //                   DropdownMenuItem(value: 'amount_desc', child: Text('Amount ↓')),
          //                   DropdownMenuItem(value: 'amount_asc', child: Text('Amount ↑')),
          //                 ],
          //                 onChanged: (value) {
          //                   if (value != null) {
          //                     _onFilterChanged(_filter.copyWith(sortBy: value));
          //                   }
          //                 },
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
                
          //       // Second row: Category filter (only if there are categories)
          //       // Second row: Category filter
          //       ValueListenableBuilder<List<Category>>(
          //         valueListenable: categoriesNotifier,
          //         builder: (context, categoryList, _) {
          //           if (categoryList.isEmpty) return SizedBox();

          //           return Column(
          //             children: [
          //               SizedBox(height: 8),
          //               Row(
          //                 children: [
          //                   Expanded(
          //                     child: SingleChildScrollView(
          //                       scrollDirection: Axis.horizontal,
          //                       child: Row(
          //                         children: [
          //                           _buildCompactFilterChip(
          //                             'All Categories',
          //                             _filter.categoryId == null,
          //                             () => _onFilterChanged(_filter.clearCategory()),
          //                           ),
          //                           SizedBox(width: 6),
          //                           ...categoryList.map((cat) => Padding(
          //                                 padding: const EdgeInsets.only(right: 6.0),
          //                                 child: _buildCompactCategoryChip(cat),
          //                               )),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ],
          //           );
          //         },
          //       ),
          //     ],
          //   ),
          // ),
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

  Widget _buildCompactFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final backgroundColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.surface; // <-- adapt to dark/light mode
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: .12); // subtle border

    final textColor = isSelected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCategoryChip(Category category) {
  final isSelected = _filter.categoryId == category.id;
    final theme = Theme.of(context);
    final backgroundColor = isSelected
        ? category.color.withValues(alpha: .2)
        : theme.colorScheme.surface;
    final borderColor = isSelected
        ? category.color
        : theme.colorScheme.onSurface.withValues(alpha: .12);
    final textColor = isSelected ? category.color : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        _onFilterChanged(_filter.copyWith(categoryId: category.id));
      },
      child: Container(
        height: 28,
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
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
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}