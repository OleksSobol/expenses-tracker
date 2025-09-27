// widgets/transaction_filter_bar.dart
import 'package:expenses_tracker/models/category.dart';
import 'package:flutter/material.dart';
import '../models/transaction_filter.dart';
import 'package:intl/intl.dart';

class TransactionFilterBar extends StatefulWidget {
  final TransactionFilter filter;
  final Function(TransactionFilter) onFilterChanged;

  const TransactionFilterBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  State<TransactionFilterBar> createState() => _TransactionFilterBarState();
}

class _TransactionFilterBarState extends State<TransactionFilterBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Check if any filters are active (excluding default sort)
  bool get _hasActiveFilters {
    return widget.filter.type != 'all' ||
           widget.filter.categoryId != null ||
           widget.filter.startDate != null ||
           widget.filter.endDate != null;
  }

  String get _activeFilterSummary {
    List<String> active = [];
    
    if (widget.filter.type != 'all') {
      active.add(widget.filter.type[0].toUpperCase() + widget.filter.type.substring(1));
    }
    
    if (widget.filter.categoryId != null) {
      // Find category name
      final categories = categoriesNotifier.value;
      final category = categories.firstWhere(
        (cat) => cat.id == widget.filter.categoryId,
        orElse: () => Category(id: null, name: 'Category', icon: Icons.category, color: Colors.grey),
      );
      active.add(category.name);
    }
    
    if (widget.filter.startDate != null && widget.filter.endDate != null) {
      final format = DateFormat('MMM dd');
      active.add('${format.format(widget.filter.startDate!)} - ${format.format(widget.filter.endDate!)}');
    }
    
    return active.isEmpty ? 'All transactions' : active.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header - always visible
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpansion,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      size: 20,
                      color: _hasActiveFilters 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _hasActiveFilters 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _activeFilterSummary,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Active filter indicator
                    if (_hasActiveFilters)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Expand/collapse icon
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                   // Sort Filter Section
                  _buildFilterSection(
                    'Sort By',
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: widget.filter.sortBy,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'date_desc', child: Text('Date (Newest First)')),
                              DropdownMenuItem(value: 'date_asc', child: Text('Date (Oldest First)')),
                              DropdownMenuItem(value: 'amount_desc', child: Text('Amount (High to Low)')),
                              DropdownMenuItem(value: 'amount_asc', child: Text('Amount (Low to High)')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                widget.onFilterChanged(widget.filter.copyWith(sortBy: value));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  // Date Filter Section
                  _buildFilterSection(
                    'Date Range',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildDatePresetChip('Today', 'today'),
                              const SizedBox(width: 8),
                              _buildDatePresetChip('This Week', 'this_week'),
                              const SizedBox(width: 8),
                              _buildDatePresetChip('This Month', 'this_month'),
                              const SizedBox(width: 8),
                              _buildDatePresetChip('Last 30 Days', 'last_30'),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showCustomDatePicker,
                                icon: const Icon(Icons.date_range, size: 18),
                                label: const Text('Custom Range'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            if (widget.filter.startDate != null || widget.filter.endDate != null) ...[
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => widget.onFilterChanged(
                                  widget.filter.copyWith(startDate: null, endDate: null)
                                ),
                                icon: const Icon(Icons.clear, size: 18),
                                label: const Text('Clear'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.error,
                                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.filter.startDate != null && widget.filter.endDate != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Selected: ${DateFormat('MMM dd, yyyy').format(widget.filter.startDate!)} - ${DateFormat('MMM dd, yyyy').format(widget.filter.endDate!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  // Type Filter Section
                  _buildFilterSection(
                    'Transaction Type',
                    Row(
                      children: [
                        _buildCompactFilterChip('All', widget.filter.type == 'all', () {
                          widget.onFilterChanged(widget.filter.copyWith(type: 'all'));
                        }),
                        const SizedBox(width: 8),
                        _buildCompactFilterChip('Income', widget.filter.type == 'income', () {
                          widget.onFilterChanged(widget.filter.copyWith(type: 'income'));
                        }),
                        const SizedBox(width: 8),
                        _buildCompactFilterChip('Expense', widget.filter.type == 'expense', () {
                          widget.onFilterChanged(widget.filter.copyWith(type: 'expense'));
                        }),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Category Filter Section
                  ValueListenableBuilder<List<Category>>(
                    valueListenable: categoriesNotifier,
                    builder: (context, categoryList, _) {
                      if (categoryList.isEmpty) return const SizedBox();
                      
                      return _buildFilterSection(
                        'Category',
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCompactFilterChip(
                                'All Categories',
                                widget.filter.categoryId == null,
                                () => widget.onFilterChanged(widget.filter.copyWith(categoryId: null)),
                              ),
                              const SizedBox(width: 8),
                              ...categoryList.map((cat) => Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: _buildCompactCategoryChip(cat),
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildCompactFilterChip(String label, bool isSelected, VoidCallback onTap) {
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
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
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
    final isSelected = widget.filter.categoryId == category.id;
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
        widget.onFilterChanged(widget.filter.copyWith(categoryId: category.id));
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 16, color: category.color),
            const SizedBox(width: 6),
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

  Widget _buildDatePresetChip(String label, String preset) {
    final isSelected = _isDatePresetSelected(preset);
    
    return GestureDetector(
      onTap: () => _applyDatePreset(preset),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: .12),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimary 
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  bool _isDatePresetSelected(String preset) {
    if (widget.filter.startDate == null || widget.filter.endDate == null) {
      return false;
    }

    final now = DateTime.now();
    DateTime start, end;

    switch (preset) {
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
        return false;
    }

    // Check if the selected dates match the preset (with some tolerance)
    return widget.filter.startDate!.difference(start).inDays.abs() <= 1 &&
           widget.filter.endDate!.difference(end).inDays.abs() <= 1;
  }

  void _applyDatePreset(String preset) {
    final now = DateTime.now();
    DateTime start, end;

    switch (preset) {
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
        return;
    }

    widget.onFilterChanged(widget.filter.copyWith(startDate: start, endDate: end));
  }

  Future<void> _showCustomDatePicker() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: widget.filter.startDate != null && widget.filter.endDate != null
          ? DateTimeRange(start: widget.filter.startDate!, end: widget.filter.endDate!)
          : null,
    );

    if (picked != null) {
      widget.onFilterChanged(
        widget.filter.copyWith(startDate: picked.start, endDate: picked.end),
      );
    }
  }
}