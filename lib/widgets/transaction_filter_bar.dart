// widgets/transaction_filter_bar.dart
import 'package:expenses_tracker/models/category.dart';
import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';
import 'package:intl/intl.dart';

class TransactionFilterBar extends StatelessWidget {
  final TransactionFilter filter;
  final Function(TransactionFilter) onFilterChanged;

  const TransactionFilterBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12), 
            width: 1),
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
                    _buildCompactFilterChip(context, 'All', filter.type == 'all', () {
                      onFilterChanged(filter.copyWith(type: 'all'));
                    }),
                    SizedBox(width: 6),
                    _buildCompactFilterChip(context, 'Income', filter.type == 'income', () {
                      onFilterChanged(filter.copyWith(type: 'income'));
                    }),
                    SizedBox(width: 6),
                    _buildCompactFilterChip(context, 'Expense', filter.type == 'expense', () {
                      onFilterChanged(filter.copyWith(type: 'expense'));
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .12)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: filter.sortBy,
                    isDense: true,
                    style: TextStyle(
                      fontSize: 13, 
                      color: Theme.of(context).colorScheme.onSurface),
                    items: [
                      DropdownMenuItem(value: 'date_desc', child: Text('Date ↓')),
                      DropdownMenuItem(value: 'date_asc', child: Text('Date ↑')),
                      DropdownMenuItem(value: 'amount_desc', child: Text('Amount ↓')),
                      DropdownMenuItem(value: 'amount_asc', child: Text('Amount ↑')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onFilterChanged(filter.copyWith(sortBy: value));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          
          // Second row: Category filter
          ValueListenableBuilder<List<Category>>(
            valueListenable: categoriesNotifier,
            builder: (context, categoryList, _) {
              if (categoryList.isEmpty) return SizedBox();

              return Column(
                children: [
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCompactFilterChip(
                                context,
                                'All Categories',
                                filter.categoryId == null,
                                () => onFilterChanged(filter.clearCategory()),
                              ),
                              SizedBox(width: 6),
                              ...categoryList.map((cat) => Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: _buildCompactCategoryChip(context, cat),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          
          // Third row: Date filter
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Quick date filter dropdown
                      Container(
                        height: 28,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text('Date', style: TextStyle(fontSize: 12)),
                            value: null,
                            isDense: true,
                            style: TextStyle(
                              fontSize: 12, 
                              color: Theme.of(context).colorScheme.onSurface
                            ),
                            items: [
                              DropdownMenuItem(value: 'today', child: Text('Today')),
                              DropdownMenuItem(value: 'this_week', child: Text('This Week')),
                              DropdownMenuItem(value: 'this_month', child: Text('This Month')),
                              DropdownMenuItem(value: 'last_30', child: Text('Last 30 Days')),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              final now = DateTime.now();
                              DateTime? start, end;

                              switch (value) {
                                case 'today':
                                  start = DateTime(now.year, now.month, now.day);
                                  end = start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
                                  break;
                                case 'this_week':
                                  start = now.subtract(Duration(days: now.weekday - 1));
                                  end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
                                  break;
                                case 'this_month':
                                  start = DateTime(now.year, now.month, 1);
                                  end = DateTime(now.year, now.month + 1, 0, 23, 59);
                                  break;
                                case 'last_30':
                                  start = now.subtract(const Duration(days: 30));
                                  end = now;
                                  break;
                                default:
                                  start = null;
                                  end = null;
                              }

                              if (start != null && end != null) {
                                onFilterChanged(filter.copyWith(startDate: start, endDate: end));
                              }
                            },
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 6),
                      
                      // Custom range button
                      GestureDetector(
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(now.year - 5),
                            lastDate: DateTime(now.year + 1),
                            initialDateRange: filter.startDate != null && filter.endDate != null
                                ? DateTimeRange(start: filter.startDate!, end: filter.endDate!)
                                : null,
                          );

                          if (picked != null) {
                            onFilterChanged(
                              filter.copyWith(startDate: picked.start, endDate: picked.end),
                            );
                          }
                        },
                        child: Container(
                          height: 28,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.date_range, size: 14),
                              SizedBox(width: 4),
                              Text('Custom', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      
                      // Clear date filter button (if dates are selected)
                      if (filter.startDate != null || filter.endDate != null) ...[
                        SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => onFilterChanged(filter.copyWith(startDate: null, endDate: null)),
                          child: Container(
                            height: 28,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.clear, size: 14, color: Theme.of(context).colorScheme.onErrorContainer),
                                SizedBox(width: 2),
                                Text('Clear', style: TextStyle(
                                  fontSize: 12, 
                                  color: Theme.of(context).colorScheme.onErrorContainer
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      // Show selected date range
                      if (filter.startDate != null && filter.endDate != null) ...[
                        SizedBox(width: 6),
                        Container(
                          height: 28,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '${DateFormat('MMM dd').format(filter.startDate!)} – ${DateFormat('MMM dd').format(filter.endDate!)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final backgroundColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: .12);

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

  Widget _buildCompactCategoryChip(BuildContext context, Category category) {
    final isSelected = filter.categoryId == category.id;
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
        onFilterChanged(filter.copyWith(categoryId: category.id));
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