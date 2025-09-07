// models/transaction_filter.dart
class TransactionFilter {
  final String type; // 'all', 'income', 'expense'
  final int? categoryId; // null = all categories
  final String sortBy; // 'date_desc', 'date_asc', 'amount_desc', 'amount_asc'

  const TransactionFilter({
    this.type = 'all',
    this.categoryId,
    this.sortBy = 'date_desc',
  });

  TransactionFilter copyWith({
    String? type,
    int? categoryId,
    String? sortBy,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      categoryId: categoryId,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  TransactionFilter clearCategory() {
    return copyWith(categoryId: null);
  }
}