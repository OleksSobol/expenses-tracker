import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Category {
  final int? id;
  final String name;
  final IconData icon; 
  final Color color;

  Category({this.id, required this.name, required this.icon, required this.color});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint, // Store icon as code point
      'colorValue': color.value,   // Store color as int value
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['iconCode'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
    );
  }
}

// Global list - will be loaded from storage
List<Category> categories = [];

// Default categories to use on first app launch
List<Category> getDefaultCategories() {
  return [
    Category(id: 1, name: 'Food', icon: Icons.fastfood, color: Colors.orange),
    Category(id: 2, name: 'Transport', icon: Icons.directions_bus, color: Colors.blue),
    Category(id: 3, name: 'Shopping', icon: Icons.shopping_bag, color: Colors.purple),
    Category(id: 4, name: 'Salary', icon: Icons.attach_money, color: Colors.green),
    Category(id: 5, name: 'Bills', icon: Icons.money_off, color: Colors.red),
  ];
}

// Category management functions
class CategoryService {
  static const String _categoriesKey = 'categories';

  // Load categories from storage
  static Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesString = prefs.getString(_categoriesKey);
    
    if (categoriesString != null && categoriesString.isNotEmpty) {
      try {
        final List<dynamic> categoriesJson = jsonDecode(categoriesString);
        categories = categoriesJson.map((json) => Category.fromMap(json)).toList();
      } catch (e) {
        print('Error loading categories: $e');
        categories = getDefaultCategories();
        await saveCategories(); // Save defaults
      }
    } else {
      // First time - use defaults
      categories = getDefaultCategories();
      await saveCategories();
    }
  }

  // Save categories to storage
  static Future<void> saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = categories.map((c) => c.toMap()).toList();
      await prefs.setString(_categoriesKey, jsonEncode(categoriesJson));
    } catch (e) {
      print('Error saving categories: $e');
    }
  }

  // Add a new category
  static Future<void> addCategory(Category category) async {
    // Generate new ID
    int newId = 1;
    if (categories.isNotEmpty) {
      newId = categories.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }
    
    final newCategory = Category(
      id: newId,
      name: category.name,
      icon: category.icon,
      color: category.color,
    );
    
    categories.add(newCategory);
    await saveCategories();
  }

  // Update existing category
  static Future<void> updateCategory(Category updatedCategory) async {
    final index = categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      categories[index] = updatedCategory;
      await saveCategories();
    }
  }

  // Delete category
  static Future<void> deleteCategory(int categoryId) async {
    categories.removeWhere((c) => c.id == categoryId);
    await saveCategories();
  }

  // Get category by ID
  static Category? getCategoryById(int id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}