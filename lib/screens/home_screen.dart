import 'package:expenses_tracker/models/category.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'add_transaction_screen.dart';
import '../utils/category_helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DBService();
  List<Map<String, dynamic>> transactions = [];
  
  String _filterType = 'all'; // 'all', 'income', 'expense'
  int? _filterCategoryId;   // null = all categories
  String _sortBy = 'date_desc'; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'

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
    // Step 1: Filter and sort
    final filtered = transactions.where((tx) {
      if (_filterType != 'all' && tx['type'] != _filterType) return false;
      if (_filterCategoryId != null && tx['categoryId'] != _filterCategoryId) return false;
      return true;
    }).toList();
    
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'date_asc':
          return DateTime.parse(a['date']).compareTo(DateTime.parse(b['date']));
        case 'date_desc':
          return DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']));
        case 'amount_asc':
          return a['amount'].compareTo(b['amount']);
        case 'amount_desc':
          return b['amount'].compareTo(a['amount']);
        default:
          return 0;
      }
    });


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

      Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: 
            
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _filterType,
                    items: ['all', 'income', 'expense']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(capitalize(e)),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _filterType = val!),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 4,
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _filterCategoryId,
                    hint: Text('All Categories'),
                    items: [
                      DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...categories.map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                    ],
                    onChanged: (val) => setState(() => _filterCategoryId = val),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  flex: 2,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _sortBy,
                    items: [
                      DropdownMenuItem(value: 'date_desc', child: Text('Date ↓')),
                      DropdownMenuItem(value: 'date_asc', child: Text('Date ↑')),
                      DropdownMenuItem(value: 'amount_desc', child: Text('Amount ↓')),
                      DropdownMenuItem(value: 'amount_asc', child: Text('Amount ↑')),
                    ],
                    onChanged: (val) => setState(() => _sortBy = val!),
                  ),
                ),
              ],
            ),
          ),


          // ElevatedButton(
          //   onPressed: () async {
          //     await db.insert('transactions', {
          //       'amount': 12.5,
          //       'type': 'expense',
          //       'categoryId': 1,
          //       'date': DateTime.now().toIso8601String(),
          //       'note': 'Coffee',
          //     });
          //     _loadTransactions(); // Refresh list
          //     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaction added')));
          //   },
          //   child: Text('Add Transaction'),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     await db.clearTable('transactions');
          //     _loadTransactions(); // refresh list
          //   },
          //   child: Text('Clear All Transactions'),
          // ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final tx = filtered[index];
                final category = getCategoryById(tx['categoryId']);
                return Dismissible(
                  key: Key(tx['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    await db.delete('transactions', tx['id']);
                    setState(() {
                      transactions.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transaction deleted')),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category!.color.withValues(alpha: 0.2),
                      child: Icon(category.icon, color: category.color),
                    ),
                    title: Text(
                      '${tx['note']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        text: "${tx['type'].toUpperCase()} | ",
                        style: TextStyle(color: Colors.grey[700]),
                        children: [
                          TextSpan(
                            text: formatDate(tx['date']),
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          )
                        ],
                      ),
                    ),
                    trailing: Text(
                      formatAmount(tx['amount']),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tx['type'] == 'expense' ? Colors.red : Colors.green,
                      ),
                    ),
                    onTap: () async {
                      // **Edit transaction**
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTransactionScreen(transaction: tx),
                        ),
                      );
                      if (result == true) _loadTransactions();
                    },
                  ),
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}

