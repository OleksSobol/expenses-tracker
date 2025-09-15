import '../models/transaction.dart';
import 'notification_service.dart';
import '../models/bill.dart';
import 'db_service.dart';


class BillService {
  static const String tableName = 'bills';
  final DBService _dbService = DBService();
  final NotificationService _notificationService = NotificationService();



  // Get all bills ordered by due date
  Future<List<Map<String, dynamic>>> getAllBills() async {
    final db = await _dbService.database;
    return await db.query(tableName, orderBy: 'nextDueDate ASC');
  }

  // Add a new bill
  Future<int> addBill(Bill bill) async {
    final result = await _dbService.insert(tableName, bill.toMap());
    await _rescheduleNotifications();
    return result;
  }

  // Update existing bill
  Future<void> updateBill(int id, Bill bill) async {
    await _dbService.update(tableName, id, bill.toMap());
    await _rescheduleNotifications();
  }

  // Delete bill
  Future<int> deleteBill(int id) async {
    final result = await _dbService.delete(tableName, id);
    await _rescheduleNotifications();
    return result;
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

    final updatedBill = bill.markAsPaid();
    await updateBill(bill.id!, updatedBill);

    final transaction = TransactionModel(
      amount: bill.amount,
      type: 'expense',
      categoryId: bill.categoryId ?? 5,
      date: DateTime.now(),
      note: 'Bill payment: ${bill.name}',
      billId: bill.id,
    );

    // Insert transaction
    await _dbService.insert('transactions', transaction.toMap());
    await _rescheduleNotifications();
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

  Future<void> _rescheduleNotifications() async {
    final bills = await getAllBills();
    await _notificationService.rescheduleAllBillNotifications(bills);
  }
}