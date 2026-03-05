# 💰 Expenses Tracker

A comprehensive Flutter-based mobile app for tracking **income**, **expenses**, and **bills**. Built with privacy-first principles using local SQLite storage with beautiful charts and smart categorization.

---

## ✨ Features

### 💸 Transaction Management
- **Add income and expense transactions** with custom amounts
- **Smart categorization** with customizable icons and colors
- **Add detailed notes** to track spending context
- **Filter and search** transactions by date, category, or amount
- **Edit and delete** transactions as needed

### 📋 Bill Tracking  
- **Track recurring bills** with customizable frequencies
- **Due date reminders** with local notifications
- **Mark bills as paid** with automatic next due calculation
- **Bill categories** for organized tracking

### 📊 Financial Reports
- **Visual charts** showing income vs expenses
- **Category breakdown** with pie charts
- **Monthly/yearly reports** with date filtering
- **Net income tracking** and trends

### 🛠️ Additional Features
- **Local SQLite database** - your data stays private
- **CSV export** functionality for external analysis
- **Dark/Light theme** with system preference support
- **Custom categories** - create your own spending categories
- **Backup and restore** your financial data
- **No login required** - completely offline functionality

---

## 📱 Screenshots

*Screenshots will be added as the app development progresses*

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** 3.9.0 or higher ([Installation guide](https://docs.flutter.dev/get-started/install))
- **Android Studio** or **VS Code** with Flutter extensions
- **Android Emulator** or **physical device** for testing

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/your-username/expenses-tracker.git
cd expenses-tracker
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Generate app icons:**
```bash
dart run flutter_launcher_icons
```

4. **Run the app:**
```bash
flutter run
```

### Development Setup

For development with database testing:
```bash
# Run tests
flutter test

# Run with debugging
flutter run --debug

# Build for production
flutter build apk --release
```

---

## 🏗️ Project Architecture

```
lib/
├── main.dart                    # App entry point & navigation
├── models/                      # Data models
│   ├── transaction.dart         # Transaction model
│   ├── bill.dart               # Bill/recurring payment model
│   ├── category.dart           # Category model & service
│   └── transaction_filter.dart  # Filter model for transactions
├── screens/                     # UI screens
│   ├── home_screen.dart        # Main dashboard
│   ├── add_transaction_screen.dart
│   ├── add_bill_screen.dart
│   ├── bills_screen.dart       # Bill management
│   ├── reports_screen.dart     # Charts and analytics
│   ├── categories_screen.dart  # Category management
│   ├── settings_screen.dart    # App settings
│   └── help_support_screen.dart
├── services/                    # Business logic & data services
│   ├── db_service.dart         # SQLite database operations
│   ├── transaction_service.dart # Transaction CRUD operations
│   ├── bill_service.dart       # Bill management service
│   ├── export_service.dart     # CSV export functionality
│   ├── notification_service.dart # Local notifications
│   └── permission_service.dart  # Android/iOS permissions
├── widgets/                     # Reusable UI components
│   ├── transaction_list_item.dart
│   ├── transaction_summary.dart
│   ├── transaction_filter_bar.dart
│   ├── settings_card.dart
│   └── dialogs/                # Modal dialogs
└── utils/                      # Utility functions
```

---

## 🧪 Testing

The app includes comprehensive widget tests:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

---

## 📦 Dependencies

### Core Dependencies
- **sqflite**: Local SQLite database
- **fl_chart**: Beautiful charts and graphs  
- **shared_preferences**: App settings storage
- **intl**: Date formatting and localization
- **path**: File path utilities

### UI & UX
- **flutter_iconpicker**: Custom category icons
- **flutter_local_notifications**: Bill reminders
- **permission_handler**: Android/iOS permissions

### Development
- **flutter_lints**: Code quality and style
- **flutter_launcher_icons**: App icon generation
- **sqflite_common_ffi**: Database testing support

---

## 🎯 Roadmap

### Completed ✅
- [x] Basic transaction management
- [x] Bill tracking with reminders
- [x] Category system with icons
- [x] Reports with charts
- [x] CSV export functionality
- [x] Dark/light theme support
- [x] Local notifications
- [x] Permission handling

### Planned Features 🚧
- [ ] Cloud backup (optional)
- [ ] Budget setting and tracking  
- [ ] Receipt photo attachment
- [ ] Multiple currency support
- [ ] Advanced filtering options
- [ ] Spending insights and suggestions

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🐛 Bug Reports & Feature Requests

Please use the [GitHub Issues](https://github.com/your-username/expenses-tracker/issues) page to report bugs or request new features.

---

## 💡 Privacy

This app is **privacy-first**:
- ✅ All data stored locally on your device
- ✅ No personal information collected
- ✅ No internet connection required
- ✅ You own your financial data completely
