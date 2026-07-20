// lib/main.dart
import 'budget_tab.dart';
import 'package:flutter/material.dart';
import 'auth_page.dart'; 
import 'transaction.dart';
import 'transactions_tab.dart'; 
import 'home_tab.dart';
import 'funds_tab.dart'; 

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00E676),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF1E1E1E),
        ),
        fontFamily: 'Roboto',
      ),
      home: const AuthPage(), 
    );
  }
}

class BudgetHomePage extends StatefulWidget {
  const BudgetHomePage({super.key});

  @override
  State<BudgetHomePage> createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  int _currentIndex = 2; // Keep default on Transactions for now

  final List<Transaction> _transactions = [
    Transaction(
      id: '1', 
      title: 'ESP32 & Moisture Sensors', 
      amount: -1250.00, 
      date: DateTime.now(),
      vault: 'Personal',
      tag: 'Project LUNTIAN',
    ),
    Transaction(
      id: '2', 
      title: 'Venue Downpayment', 
      amount: -5000.00, 
      date: DateTime.now().subtract(const Duration(days: 2)),
      vault: 'SETScapade Assembly',
      tag: 'Logistics',
    ),
  ];

  Widget _buildPlaceholderTab(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: const Color(0xFF00E676).withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeTab(transactions: _transactions), // <--- Replaced placeholder!
      const FundsTab(),
      TransactionsTab(
        transactions: _transactions,
        onUpdate: () => setState(() {}),
      ),
      const BudgetTab(),
      _buildPlaceholderTab('Settings\n(App Preferences & Export)', Icons.settings_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            },
          )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFF00E676),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Funds'), // <--- 3. Relabel to Funds
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
