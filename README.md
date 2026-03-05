# Expenses Tracker

A Flutter app for tracking personal income, expenses, and recurring bills. All data stays on your device — no accounts, no cloud, no tracking.

**Version 1.0.0** · Android

---

## Features

**Transactions**
- Add income and expense transactions with amount, category, date, and note
- Filter by date range, type, or category
- Edit and delete transactions
- Scan receipts with OCR to auto-fill amount and note

**Bills**
- Track recurring bills (daily / weekly / monthly / yearly)
- Due date reminders via local notifications
- Mark bills as paid — automatically advances to next period
- Swipe to pay or delete
- Attach a payment link to each bill

**Reports**
- Income vs expense bar chart by month
- Category breakdown pie chart
- Date range filtering

**General**
- Custom categories with icons and colors
- Dark / light theme following system preference
- CSV export
- Local SQLite storage — fully offline
- No login required

---

## Build

```bash
flutter pub get
flutter run                  # debug
./build.sh                   # release APK (auto-increments build number)
./build.sh --split-per-abi   # smaller per-architecture APKs
```

Requires Flutter SDK 3.9+.

---

## Project Structure

```
lib/
├── main.dart
├── models/           # transaction, bill, category, filter
├── screens/          # home, add_transaction, add_bill, bills, reports, settings, categories
├── services/         # db, transaction, bill, export, notification, permission
├── widgets/          # transaction_list_item, transaction_summary, filter_bar, dialogs
├── theme/            # app_tokens (colors, spacing, radius, typography, durations)
└── utils/
```

---

## Dependencies

| Package | Purpose |
|---|---|
| sqflite | Local SQLite database |
| fl_chart | Charts |
| shared_preferences | Settings |
| intl | Date/number formatting |
| flutter_iconpicker | Category icon picker |
| awesome_notifications | Bill due reminders |
| permission_handler | Runtime permissions |
| google_mlkit_text_recognition | OCR receipt scanning |
| image_picker | Camera / gallery access |
| url_launcher | Open bill payment links |
| device_info_plus / package_info_plus | Device & app info |

---

## Privacy

- All data stored locally on-device (SQLite)
- No internet connection required
- No analytics, no telemetry, no accounts
