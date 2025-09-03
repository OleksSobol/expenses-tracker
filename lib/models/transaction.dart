class TransactionModel {
  final int? id;
  final double amount;
  final String type; // "income" or "expense"
  final int categoryId;
  final DateTime date;
  final String? note;
  final int? billId;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.billId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'billId': billId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']),
      note: map['note'],
      billId: map['billId'],
    );
  }
}
