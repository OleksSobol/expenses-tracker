// widgets/transaction_filter_bar.dart
import 'package:expenses_tracker/models/category.dart';
import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';

class TransactionFilterBar extends StatelessWidget {
  final TransactionFilter filter;
  final Function(TransactionFilter) onFilterChanged;

  const TransactionFilterBar({
    Key? key,
    required this.filter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        children: [
          _buildTypeFilter(),
          const SizedBox(width: 8),
          _buildCategoryFilter(),
          const SizedBox(width: 8),
          _buildSortFilter(),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Flexible(
      flex: 2,
      child: Wrap(
        spacing: 8,
        children: ['All', 'Income', 'Expense'].map((type) {
          return ChoiceChip(
            label: Text(type),
            selected: filter.type.toLowerCase() == type.toLowerCase(),
            onSelected: (_) => onFilterChanged(
              filter.copyWith(type: type.toLowerCase())
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Flexible(
      flex: 4,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('All Categories'),
              selected: filter.categoryId == null,
              onSelected: (_) => onFilterChanged(filter.clearCategory()),
            ),
            const SizedBox(width: 8),
            ...categories.map((cat) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(cat.name),
                selected: filter.categoryId == cat.id,
                avatar: Icon(cat.icon, size: 18, color: cat.color),
                selectedColor: cat.color.withOpacity(0.3),
                onSelected: (_) => onFilterChanged(
                  filter.copyWith(categoryId: cat.id)
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSortFilter() {
    return Flexible(
      flex: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSortChip('Date ↓', 'date_desc'),
            const SizedBox(width: 8),
            _buildSortChip('Date ↑', 'date_asc'),
            const SizedBox(width: 8),
            _buildSortChip('Amount ↓', 'amount_desc'),
            const SizedBox(width: 8),
            _buildSortChip('Amount ↑', 'amount_asc'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String sortBy) {
    return ChoiceChip(
      label: Text(label),
      selected: filter.sortBy == sortBy,
      onSelected: (_) => onFilterChanged(filter.copyWith(sortBy: sortBy)),
    );
  }
}