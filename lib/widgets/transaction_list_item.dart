// widgets/transaction_list_item.dart
import 'package:flutter/material.dart';
import '../utils/category_helpers.dart';

class TransactionListItem extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = getCategoryById(transaction['categoryId']);
    
    return Dismissible(
      key: Key(transaction['id'].toString()),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      onDismissed: (direction) {
        onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category!.color.withValues(alpha: 0.2),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(
          '${transaction['note']}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: RichText(
          text: TextSpan(
            text: "${transaction['type'].toUpperCase()} | ",
            style: TextStyle(color: Colors.grey[700]),
            children: [
              TextSpan(
                text: formatDate(transaction['date']),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              )
            ],
          ),
        ),
        trailing: Text(
          formatAmount(transaction['amount']),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: transaction['type'] == 'expense' ? Colors.red : Colors.green,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}