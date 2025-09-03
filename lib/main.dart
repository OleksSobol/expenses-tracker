import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(ExpensesTrackerApp());
}

class ExpensesTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
      ),
      home: HomeScreen(),
    );
  }
}
