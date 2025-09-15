// lib/main.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/settings_screen.dart';
import 'screens/bills_screen.dart';
import 'screens/home_screen.dart';
import 'models/category.dart';


void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

   // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  // Load categories from storage before starting the app
  await CategoryService.loadCategories();
  
  runApp(ExpensesTrackerApp());
}

class ExpensesTrackerApp extends StatefulWidget {
  const ExpensesTrackerApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ExpensesTrackerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'system';
    
    setState(() {
      switch (themeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses Tracker',
      
      // Light theme
      theme: ThemeData(
        colorSchemeSeed: Colors.blue, // Your brand color
        useMaterial3: true,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      
      // Dark theme
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue, // Same brand color
        useMaterial3: true,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      
      // Theme mode (system, light, or dark)
      themeMode: _themeMode,
      
      home: MainNavigation(onThemeChanged: _changeTheme),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  const MainNavigation({super.key, required this.onThemeChanged});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),
      BillsScreen(),
      SettingsScreen(onThemeChanged: widget.onThemeChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}