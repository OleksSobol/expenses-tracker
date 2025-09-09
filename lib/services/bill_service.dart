// lib/services/bill_service.dart
import '../models/bill.dart';
import '../models/transaction.dart';
import 'db_service.dart';

class BillService {
  static const String tableName = 'bills';
  final DBService _dbService = DBService();

  // Get all bills ordered by due date
  Future<List<Map<String, dynamic>>> getAllBills() async {
    final db = await _dbService.database;
    return await db.query(tableName, orderBy: 'nextDueDate ASC');
  }

  // Add a new bill
  Future<int> addBill(Bill bill) async {
    return await _dbService.insert(tableName, bill.toMap());
  }

  // Update existing bill
  Future<void> updateBill(int id, Bill bill) async {
    await _dbService.update(tableName, id, bill.toMap());
  }

  // Delete bill
  Future<int> deleteBill(int id) async {
    return await _dbService.delete(tableName, id);
  }

  // Get bill by ID
  Future<Bill?> getBillById(int id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Bill.fromMap(maps.first);
    }
    return null;
  }

  // Mark bill as paid and create transaction
  Future<void> markBillAsPaid(Bill bill) async {
    if (bill.id == null) return;

    // Create updated bill with next due date
    final updatedBill = bill.markAsPaid();
    
    // Update bill in database
    await updateBill(bill.id!, updatedBill);

    // Create transaction record for the payment
    final transaction = TransactionModel(
      amount: bill.amount,
      type: 'expense',
      categoryId: bill.categoryId ?? 5, // Default to Bills category
      date: DateTime.now(),
      note: 'Bill payment: ${bill.name}',
      billId: bill.id,
    );

    // Insert transaction
    await _dbService.insert('transactions', transaction.toMap());
  }

  // Get overdue bills
  Future<List<Bill>> getOverdueBills() async {
    final billsData = await getAllBills();
    final bills = billsData.map((map) => Bill.fromMap(map)).toList();
    final now = DateTime.now();
    
    return bills.where((bill) {
      final today = DateTime(now.year, now.month, now.day);
      final dueDate = DateTime(bill.nextDueDate.year, bill.nextDueDate.month, bill.nextDueDate.day);
      return dueDate.isBefore(today) && !bill.isPaid;
    }).toList();
  }

  // Get bills due soon (within 3 days)
  Future<List<Bill>> getBillsDueSoon() async {
    final billsData = await getAllBills();
    final bills = billsData.map((map) => Bill.fromMap(map)).toList();
    final now = DateTime.now();
    final threeDaysFromNow = now.add(Duration(days: 3));
    
    return bills.where((bill) {
      final dueDate = bill.nextDueDate;
      return dueDate.isAfter(now) && 
             dueDate.isBefore(threeDaysFromNow) && 
             !bill.isPaid;
    }).toList();
  }
}