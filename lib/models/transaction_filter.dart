// models/transaction_filter.dart
class TransactionFilter {
  final String type; // 'all', 'income', 'expense'
  final int? categoryId; // null = all categories
  final String sortBy; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'
  final DateTime? startDate; // optional start date filter
  final DateTime? endDate; // optional end date filter

  const TransactionFilter({
    this.type = 'all',
    this.categoryId,
    this.sortBy = 'date_desc',
    this.startDate,
    this.endDate,
  });

  TransactionFilter copyWith({
    String? type,
    int? categoryId,
    String? sortBy,
    Object? startDate =  _sentinel,
    Object? endDate =  _sentinel,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      categoryId: categoryId,
      sortBy: sortBy ?? this.sortBy,
      startDate: startDate == _sentinel ? this.startDate : startDate as DateTime?,
      endDate: endDate == _sentinel ? this.endDate : endDate as DateTime?,
    );
  }

  TransactionFilter clearCategory() {
    return copyWith(categoryId: null);
  }

  TransactionFilter clearDateRange() {
    return copyWith(startDate: null, endDate: null);
  }
}

// Private sentinel so we can differentiate "not provided" vs "explicit null"
const _sentinel = Object();