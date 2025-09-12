import 'package:expenses_tracker/models/category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


Category? getCategoryById(int id){
  return categoriesNotifier.value.firstWhere(
    (cat) => cat.id == id,
    orElse: () =>  Category(id: 0, name: 'Other', icon: Icons.help, color: Colors.grey),
  );
}

String formatAmount(double amount) {
  final formatCurrency = NumberFormat.simpleCurrency(decimalDigits: 2);
  return formatCurrency.format(amount);
}


String formatDate(String isoDate) {
  final date = DateTime.parse(isoDate);
  final formatter = DateFormat('MM/dd/yyyy hh:mm a');
  return formatter.format(date);
}

String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
