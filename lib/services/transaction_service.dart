// services/transaction_service.dart
import '../models/transaction_filter.dart';
import 'db_service.dart';

class TransactionService {
  final DBService _db = DBService();

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      return await _db.queryAll('transactions');
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _db.delete('transactions', id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<int> addTransaction(Map<String, dynamic> transactionData) async {
    try {
      return await _db.insert('transactions', transactionData);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Future<void> updateTransaction(int id, Map<String, dynamic> transactionData) async {
    try {
      await _db.update('transactions', id, transactionData);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  List<Map<String, dynamic>> filterAndSortTransactions(
    List<Map<String, dynamic>> transactions, 
    TransactionFilter filter
  ) {
    // Apply filters
    final filtered = transactions.where((tx) {
      if (filter.type != 'all' && tx['type'] != filter.type) return false;
      if (filter.categoryId != null && tx['categoryId'] != filter.categoryId) return false;

      final txDate = DateTime.parse(tx['date']);
      if (filter.startDate != null && txDate.isBefore(filter.startDate!)) return false;
      if (filter.endDate != null && txDate.isAfter(filter.endDate!)) return false;

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

  Map<String, double> calculateTotals(List<Map<String, dynamic>> transactions) {
  double income = 0;
  double expense = 0;

  for (var tx in transactions) {
    final amount = (tx['amount'] as num).toDouble();
    if (tx['type'] == 'income') {
      income += amount;
    } else if (tx['type'] == 'expense') {
      expense += amount;
    }
  }

  return {
    "income": income,
    "expense": expense,
    "balance": income - expense,
  };
}

}