// This is a basic Flutter widget test for the Expenses Tracker app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:expenses_tracker/main.dart';

void main() {
  // Setup database for testing
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory to use FFI
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Expenses Tracker app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExpensesTrackerApp());
    
    // Wait for the app to fully load
    await tester.pumpAndSettle();

    // Verify that the bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verify navigation items are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Bottom navigation contains expected tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpensesTrackerApp());
    
    // Wait a reasonable time for the app to load
    await tester.pump(const Duration(seconds: 1));

    // Check that navigation items exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    
    // Check that bottom navigation icons exist
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
