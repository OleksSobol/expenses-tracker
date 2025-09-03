class Bill {
  final int? id;
  final String name;
  final double amount;
  final String frequency; // e.g. "monthly", "weekly"
  final DateTime nextDueDate;
  final bool autopay;

  Bill({
    this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.nextDueDate,
    this.autopay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'frequency': frequency,
      'nextDueDate': nextDueDate.toIso8601String(),
      'autopay': autopay ? 1 : 0,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      frequency: map['frequency'],
      nextDueDate: DateTime.parse(map['nextDueDate']),
      autopay: map['autopay'] == 1,
    );
  }
}
