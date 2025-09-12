// screens/categories_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/transaction_service.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addCategory,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: Icon(Icons.add),
        tooltip: 'Add Category',
      ),
      body: categories.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No Categories Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first category to start organizing transactions',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addCategory,
            icon: Icon(Icons.add),
            label: Text('Add Category'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
  return Dismissible(
    key: Key(category.id.toString()),

    // Allow only swipe from right to left
    direction: DismissDirection.endToStart,

    // Background when swiping (same as Bills)
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    ),

    confirmDismiss: (direction) async {
      // Ask for confirmation (reuse your _deleteCategory dialog logic)
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Category'),
          content: Text(
            'Deleting "${category.name}" will also delete all transactions in this category.\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        ),
      );
      return confirmed ?? false;
    },

    onDismissed: (direction) {
      _deleteCategory(category);
    },

    child: Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            category.icon,
            color: category.color,
            size: 24,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade400,
          size: 16,
        ),
        onTap: () => _editCategory(category),
      ),
    ),
  );
}


  Future<void> _addCategory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryScreen(),
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh the list
    }
  }

  Future<void> _editCategory(Category category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryScreen(category: category),
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh the list
    }
  }

Future<void> _deleteCategory(Category category) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Category'),
      content: Text(
        'Deleting "${category.name}" will also delete all transactions in this category.\n\n'
        'This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      // delete all transactions first
      final txService = TransactionService();
      final allTx = await txService.getAllTransactions();
      for (var tx in allTx) {
        if (tx['categoryId'] == category.id) {
          await txService.deleteTransaction(tx['id']);
        }
      }

      // then delete the category
      await CategoryService.deleteCategory(category.id!);

      setState(() {}); // refresh UI

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Category "${category.name}" and related transactions deleted',
          ),
          backgroundColor: Colors.green,
        ),
      );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete category'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}