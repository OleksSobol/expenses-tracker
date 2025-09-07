// services/transaction_service.dart
import '../models/transaction_filter.dart';
import '../services/db_service.dart';

class TransactionService {
  final DBService _db = DBService();

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    return await _db.queryAll('transactions');
  }

  Future<void> deleteTransaction(int id) async {
    await _db.delete('transactions', id);
  }

  List<Map<String, dynamic>> filterAndSortTransactions(
    List<Map<String, dynamic>> transactions, 
    TransactionFilter filter
  ) {
    // Apply filters
    final filtered = transactions.where((tx) {
      if (filter.type != 'all' && tx['type'] != filter.type) return false;
      if (filter.categoryId != null && tx['categoryId'] != filter.categoryId) return false;
      return true;
    }).toList();
    
    // Apply sorting
    filtered.sort((a, b) {
      switch (filter.sortBy) {
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

    return filtered;
  }
}