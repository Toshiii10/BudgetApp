// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_page.dart'; 
import 'transaction.dart';
import 'transactions_tab.dart'; 
import 'funds_tab.dart';
import 'budget_tab.dart';
import 'settings_tab.dart';
import 'home_tab.dart';
import 'database_helper.dart'; // <--- NEW IMPORT HERE

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
  int _currentIndex = 2; 
  List<Transaction> _transactions = []; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --- NEW SQL LOAD DATA ---
  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.fetchAllTransactions();
    setState(() {
      _transactions = data;
    });
  }

  // --- NEW SQL SAVE DATA ---
  Future<void> _saveData() async {
    await DatabaseHelper.instance.clearDatabase();
    for (var tx in _transactions) {
      await DatabaseHelper.instance.insertTransaction(tx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeTab(transactions: _transactions), 
      FundsTab(transactions: _transactions), 
      TransactionsTab(
        transactions: _transactions,
        onUpdate: () {
          setState(() {}); 
          _saveData();     
        },
      ),
      const BudgetTab(),
      SettingsTab(transactions: _transactions), 
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
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Funds'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
