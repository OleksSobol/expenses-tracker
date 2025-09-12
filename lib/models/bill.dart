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
  final DateTime? lastPaidDate;
  final bool isPaid; // whether current period is paid
  final String? link;

  Bill({
    this.id,
    required this.name,
    required this.amount,
    required this.nextDueDate,
    required this.frequency,
    this.autopay = false,
    this.categoryId,
    this.notes,
    this.lastPaidDate,
    this.isPaid = false,
    this.link,
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
      lastPaidDate: map['lastPaidDate'] != null 
          ? DateTime.parse(map['lastPaidDate'] as String)
          : null,
      isPaid: (map['isPaid'] as int?) == 1,
      link: map['link'] as String?, 
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'amount': amount,
      'nextDueDate': nextDueDate.toIso8601String(),
      'frequency': frequency,
      'autopay': autopay ? 1 : 0,
      if (categoryId != null) 'categoryId': categoryId,
      if (notes != null) 'notes': notes,
      if (lastPaidDate != null) 'lastPaidDate': lastPaidDate!.toIso8601String(),
      'isPaid': isPaid ? 1 : 0,
      if (link != null) 'link': link,
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
    DateTime? lastPaidDate,
    bool? isPaid,
    String? link,
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
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      isPaid: isPaid ?? this.isPaid,
      link: link ?? this.link, 
    );
  }

  // Calculate next due date based on frequency
  DateTime calculateNextDueDate() {
    final current = nextDueDate;
    switch (frequency) {
      case 'daily':
        return current.add(Duration(days: 1));
      case 'weekly':
        return current.add(Duration(days: 7));
      case 'monthly':
        return DateTime(current.year, current.month + 1, current.day);
      case 'yearly':
        return DateTime(current.year + 1, current.month, current.day);
      default:
        return current.add(Duration(days: 30)); // fallback
    }
  }

  // Mark bill as paid and update next due date
  Bill markAsPaid() {
    return copyWith(
      isPaid: false, // reset for next period
      lastPaidDate: DateTime.now(),
      nextDueDate: calculateNextDueDate(),
    );
  }
}