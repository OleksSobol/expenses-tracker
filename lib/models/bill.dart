// lib/models/bill.dart
class Bill {
  final int? id; // nullable for new bills
  final String name;
  final double amount;
  final DateTime nextDueDate;
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final bool autopay;
  final int? categoryId;
  final String? notes;

  Bill({
    this.id,
    required this.name,
    required this.amount,
    required this.nextDueDate,
    required this.frequency,
    this.autopay = false,
    this.categoryId,
    this.notes,
  });

  // Convert from database map
  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      nextDueDate: DateTime.parse(map['nextDueDate'] as String),
      frequency: map['frequency'] as String,
      autopay: (map['autopay'] as int?) == 1,
      categoryId: map['categoryId'] as int?,
      notes: map['notes'] as String?,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // only include id if it's not null
      'name': name,
      'amount': amount,
      'nextDueDate': nextDueDate.toIso8601String(),
      'frequency': frequency,
      'autopay': autopay ? 1 : 0, // SQLite stores booleans as integers
      if (categoryId != null) 'categoryId': categoryId,
      if (notes != null) 'notes': notes,
    };
  }

  // Create a copy with updated fields
  Bill copyWith({
    int? id,
    String? name,
    double? amount,
    DateTime? nextDueDate,
    String? frequency,
    bool? autopay,
    int? categoryId,
    String? notes,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      frequency: frequency ?? this.frequency,
      autopay: autopay ?? this.autopay,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
    );
  }
}