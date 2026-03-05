// widgets/transaction_list_item.dart
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
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
    final isExpense = transaction['type'] == 'expense';

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
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category!.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(category.icon, color: category.color, size: 22),
          ),
          title: Text(
            '${transaction['note']}',
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: RichText(
              text: TextSpan(
                text: "${transaction['type'].toUpperCase()} | ",
                style: AppTypography.caption,
                children: [
                  TextSpan(
                    text: formatDate(transaction['date']),
                    style: AppTypography.caption,
                  )
                ],
              ),
            ),
          ),
          trailing: Text(
            formatAmount(transaction['amount']),
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: isExpense ? AppColors.error : AppColors.success,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
