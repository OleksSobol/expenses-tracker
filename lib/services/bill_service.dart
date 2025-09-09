// lib/services/bill_service.dart
import '../models/bill.dart';
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
}