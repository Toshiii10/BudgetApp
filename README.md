# Budget App

A Personal project.

## Getting Started

This project is a Budget application.

For collaboration with the application development, view the
( ____), which offers OOP, samples, development, and a reference.

# Budget Vault: Advanced Budget & Resource Tracker 📊

A modular, offline-first Flutter application designed for project leads, engineering students, and organization managers. Vault goes beyond simple expense tracking by introducing dedicated modules for hardware Bill of Materials (BOM), daily burn-rate calculations, and formal organizational audits—all wrapped in a sleek, high-contrast dark mode UI.

## ✨ Key Features

* **Dynamic Home Dashboard:** Features an interactive `fl_chart` pie chart for expense breakdown and a smart "Daily Burn-Rate" widget that calculates safe daily spending based on active allowances (e.g., 300-hour OJT tracking).
* **BOM (Bill of Materials) Sub-Tracker:** Tap into specific project funds to view a dedicated sub-page. Automatically calculates component costs (like ESP32s and sensors) against a fixed hardware budget.
* **Organizational Audit Mode:** Generates a read-only, itemized ledger for group funds. Separates personal cash from organizational vaults to maintain perfect financial transparency.
* **Fixed Overhead Manager:** Tracks monthly recurring subscriptions (server hosting, gym memberships) with a progress bar indicating how much of the monthly budget is safely spendable.
* **Local Data Persistence:** Engineered with `shared_preferences` to encode transactions into JSON, providing instantaneous, secure, offline-first data loading.
* **Export Ready:** UI foundation laid for generating `.csv` and `.pdf` reports for quick project reimbursements.

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Data Visualization:** [`fl_chart`](https://pub.dev/packages/fl_chart)
* **Local Storage:** [`shared_preferences`](https://pub.dev/packages/shared_preferences)
* **Architecture:** Modular multi-tab layout with standard state management (`setState`).

## 📱 App Architecture

The application is heavily modularized for easy maintenance and scaling:
* `main.dart` - Core routing, theme configuration, and database initialization.
* `home_tab.dart` - Analytics, dynamic charts, and daily allowance calculators.
* `funds_tab.dart` - Net worth aggregation and routing to specialized sub-ledgers.
* `transactions_tab.dart` - CRUD operations and historical expense list.
* `budget_tab.dart` - Recurring cost tracking and safe-to-spend metrics.
* `bom_page.dart` & `audit_page.dart` - Specialized sub-views for hardware projects and formal audits.

## 🚀 Getting Started

To run this project locally on your machine:

**1. Clone the repository:**
```bash
git clone [https://github.com/yourusername/vault-budget-tracker.git](https://github.com/yourusername/vault-budget-tracker.git)

**2. Navigate to the directory:**

Bash
cd vault-budget-tracker

**3. Install dependencies:**

Bash
flutter pub get

**4. Run the app (ensure an emulator or physical device is connected):**

Bash
flutter run


🎨 UI / UX
Designed with a "Cyber-Minimalist" aesthetic. Built natively in dark mode utilizing a #121212 background, accented with Neon Green (#00E676) for positive financial health indicators, and Cyan/Purple accents for distinct data categorization.


***

### How to use this:
1. Go to your repository on GitHub.
2. Click **Add file** > **Create new file**.
3. Name the file exactly **`README.md`**.
4. Paste the text above (everything inside the gray code block) into the editor.
5. Click **Commit changes**. GitHub will automatically render it as the beautiful front page of your project!
