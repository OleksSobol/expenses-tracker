import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final IconData icon; // just store an emoji/icon name
  final Color color;

  Category({this.id, required this.name, required this.icon, required this.color});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
    );
  }
}

final categories = [
  Category(id: 1, name: 'Food', icon: Icons.fastfood, color: Colors.orange),
  Category(id: 2, name: 'Transport', icon: Icons.directions_bus, color: Colors.blue),
  Category(id: 3, name: 'Shopping', icon: Icons.shopping_bag, color: Colors.purple),
  Category(id: 4, name: 'Salary', icon: Icons.attach_money, color: Colors.green),
  Category(id: 5, name: 'Bills', icon: Icons.money_off, color: Colors.red)
];