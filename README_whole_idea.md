# 🚀 Project Pack: Expenses-Tracker App

You picked the high-odds safe bet: **Expenses-Tracker**. Here are clean mockups and a build plan to get it shipped without losing your mind.

---

## 1) Expenses-Tracker (Local-first, private)

### 🔎 One-liner

A fast, privacy-first Mint alternative with dead-simple manual entry and smart recurring bills. Yakima-friendly out of the gate, generalizable later.

### 🎯 MVP Scope (v1.0)

* Manual transactions (income/expense).
* Recurring bills with due dates + reminders.
* This-month dashboard: income vs expenses, net, bills due.
* Local-first storage (SQLite). Export CSV.
* No login required. (Sync optional in v1.2+.)

### 🧭 Primary User Flows

1. **Add Transaction** → amount keypad → category → save.
2. **Add Bill** → name, amount, frequency → next due → reminder.
3. **Home** → see totals & due soon → tap to mark bill paid.
4. **Reports** → month switcher → category breakdown.

### 🧱 Information Architecture

* **Home** (Dashboard)
* **Transactions** (List + Add)
* **Bills** (List + Detail)
* **Reports** (Charts)
* **Settings** (Currency, export, backup)

### 🖼️ Wireframes (ASCII)

**Home / Dashboard**

```
┌───────────────────────────────────────┐
│  Sep 2025                             │
│  Income      $3,200                   │
│  Expenses    $2,145                   │
│  Net         $1,055  ▲                │
│---------------------------------------│
│  Bills due (next 7 days)              │
│  ▸ Yakima Utilities      09/07  $62   │
│  ▸ Trash & Recycling     09/09  $24   │
│  ▸ Rent                   PAID         │
│---------------------------------------│
│  Quick Add: [+]                       │
└───────────────────────────────────────┘
```

**Add Transaction**

```
┌───────────────────────────────────────┐
│  Add Transaction                      │
│  $  [  0  ]   [Keypad]               │
│  Type: (● Expense)  ○ Income          │
│  Category:  Food  Transport  Bills →  │
│  Date:  [ Today ▾ ]                   │
│  Note:  [ optional ]                  │
│  [ Save ]                              │
└───────────────────────────────────────┘
```

**Bills List**

```
┌───────────────────────────────────────┐
│ Bills                                 │
│ ▸ Yakima Utilities  $62   Due 09/07   │
│ ▸ Trash/Recycling   $24   Due 09/09   │
│ ▸ Internet          $70   Due 09/15   │
│ [ + Add Bill ]                         │
└───────────────────────────────────────┘
```

### 🎨 Style Notes

* **Vibe**: Calm, trustworthy, no fintech BS.
* **Palette**: Neutral base, one accent (teal/emerald). Dark mode early.
* **Micro-copy**: Plain English. “Bill paid.” “Saved.” “Due in 2 days.”

### 🗃️ Data Model (v1)

* `Transaction { id, amount, type, categoryId, date, merchant?, note?, billId? }`
* `Bill { id, name, amount, frequency(enum), nextDueDate, autopay(bool), categoryId, notes? }`
* `Category { id, name, icon, color }`
* `Setting { currency, firstDayOfMonth, darkMode, backupEnabled }`

### 🔔 Notifications (local)

* Schedule at creation: `nextDueDate - reminderOffset`.
* Mark as paid → auto-roll `nextDueDate` by frequency.

### 🧪 MVP Acceptance Criteria

* Add/save/edit/delete transactions offline.
* Create recurring bill, get reminder, mark paid.
* Dashboard totals correct for selected month.
* Export CSV of transactions & bills.

### 🛠️ Suggested Stack

* **Mobile**: Flutter
* **Local DB**: SQLite via `drift` or `sqflite`
* **Charts**: `fl_chart`
* **Notifications**: `flutter_local_notifications`
* **(Later)** Sync/Auth: Supabase

### 🗓️ Build Plan (2.5–3 weeks of focused evenings)

**Week 0.5 – Foundation**

* [ ] Create Flutter project, theme, routing, dark mode.
* [ ] Define models & migrations (Transaction, Bill, Category, Setting).
* [ ] Seed default categories.

**Week 1 – Core CRUD**

* [ ] Add Transaction flow + keypad UX.
* [ ] Transactions list w/ month filter.
* [ ] Bills list + Add/Edit Bill (frequency, next due).

**Week 2 – Dashboard & Reminders**

* [ ] Dashboard aggregates (income, expenses, net, due soon).
* [ ] Local notifications scheduling.
* [ ] CSV export (Documents folder).

**Week 3 – Reports & Polish**

* [ ] Category pie + monthly bar chart.
* [ ] Empty states, toasts, haptics.
* [ ] Basic QA on Android; publish beta (internal testing).

### 💸 Monetization (v1.1+)

* Free core. Pro (\$1.99/mo): cloud sync, unlimited custom categories, multi-device.

### 🧱 Risks & Mitigations

* **Scope creep** → lock v1 to manual + recurring bills.
* **Data loss fear** → prominent export/backup, “Your data stays on device.”
* **Category mess** → opinionated defaults, merge tool later.

---

## 📦 Release Checklist

* [ ] App icon, name, short & long description.
* [ ] Privacy policy (plain: local-first, optional sync).
* [ ] Crash reporting (Sentry) + minimal analytics (privacy-respecting).
* [ ] Beta testers (5–10 actual humans). Collect feedback in Telegram group.

## 🧭 Next Steps

* Scaffold Flutter project: models, theme, routing.
* Build one complete screen (Home/Dashboard) for beta test.
* Start Week 1 Core CRUD tasks after scaffold is ready.

## 📁 Repo Structure Suggestion

```
expenses_tracker/
  lib/
  test/
  assets/
  pubspec.yaml
  README.md
```
