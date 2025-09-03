# Expenses-Tracker

A Flutter-based mobile app to track your **income**, **expenses**, and **bills**.  
Store transactions locally using SQLite and visualize your financial data in a simple, user-friendly interface.

---

## Features

- Add **income** and **expense** transactions
- Categorize transactions (with icon/color)
- Add notes to transactions
- Track recurring **bills**
- View all transactions in a list
- Clear transactions for testing/development
- Local SQLite database for persistent storage
- Ready for extension: charts, notifications, recurring payments

---

## Screenshots (Placeholder)

*(Add screenshots after first UI version is ready)*

---

## Getting Started

### Prerequisites

- Flutter SDK installed ([Installation guide](https://docs.flutter.dev/get-started/install))
- Android Studio or VS Code
- Emulator or physical device connected

### Installation

1. Clone the repository:

```bash
git clone https://github.com/<your-username>/expenses-tracker.git
cd expenses-tracker
```

2. Get dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

---

## Project Structure

```
lib/
├── main.dart          # Entry point
├── screens/           # Home, add transaction screens
├── models/            # Transaction, Bill, Category models
├── services/          # SQLite DB service
└── widgets/           # Reusable UI components
```

---

## Development

- Use **hot reload** (`Ctrl+S`) to see changes instantly
- Use the "Clear Transactions" button during development
- Add new features in separate branches, e.g., `feature/add-charts`

---

## License
