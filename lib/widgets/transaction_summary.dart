import 'package:flutter/material.dart';

class TransactionSummary extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const TransactionSummary({
    Key? key,
    required this.income,
    required this.expense,
    required this.balance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildColumn('Income', income, Colors.green[700]!),
              _buildColumn('Expense', expense, Colors.red[700]!),
              _buildColumn('Balance', balance, Colors.blueGrey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumn(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color)),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
