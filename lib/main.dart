import 'package:flutter/material.dart';
import 'auth_page.dart'; // <--- 1. Add this import

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
      home: const AuthPage(), // <--- 2. Change this from BudgetHomePage to AuthPage
    );
  }
}

// --- MODEL ---
class Transaction {
  String id;
  String title;
  double amount;
  DateTime date;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });
}

// --- MAIN UI ---
class BudgetHomePage extends StatefulWidget {
  const BudgetHomePage({super.key});

  @override
  State<BudgetHomePage> createState() => _BudgetHomePageState();
}

class _BudgetHomePageState extends State<BudgetHomePage> {
  // --- STATE (The 'Read' part of CRUD) ---
  final List<Transaction> _transactions = [
    Transaction(id: '1', title: 'Groceries', amount: -120.50, date: DateTime.now()),
    Transaction(id: '2', title: 'Freelance Work', amount: 500.00, date: DateTime.now().subtract(const Duration(days: 1))),
  ];

  double get _totalBalance {
    return _transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  // --- CREATE & UPDATE FUNCTION ---
  void _showTransactionForm([Transaction? existingTransaction]) {
    final titleController = TextEditingController(text: existingTransaction?.title ?? '');
    final amountController = TextEditingController(
        text: existingTransaction != null ? existingTransaction.amount.abs().toString() : '');
    
    // Default to expense (false) unless editing an income
    bool isIncome = existingTransaction != null && existingTransaction.amount > 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 24, left: 24, right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existingTransaction == null ? 'New Transaction' : 'Edit Transaction',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Income/Expense Toggle
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Expense'),
                          selected: !isIncome,
                          selectedColor: Colors.redAccent.withOpacity(0.2),
                          onSelected: (val) => setModalState(() => isIncome = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Income'),
                          selected: isIncome,
                          selectedColor: const Color(0xFF00E676).withOpacity(0.2),
                          onSelected: (val) => setModalState(() => isIncome = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'What was this for?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final title = titleController.text;
                        final amountText = amountController.text;

                        if (title.isEmpty || amountText.isEmpty) return;

                        final parsedAmount = double.tryParse(amountText) ?? 0.0;
                        final finalAmount = isIncome ? parsedAmount : -parsedAmount;

                        setState(() {
                          if (existingTransaction == null) {
                            // CREATE
                            _transactions.add(Transaction(
                              id: DateTime.now().toString(),
                              title: title,
                              amount: finalAmount,
                              date: DateTime.now(),
                            ));
                          } else {
                            // UPDATE
                            existingTransaction.title = title;
                            existingTransaction.amount = finalAmount;
                          }
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        existingTransaction == null ? 'Save Transaction' : 'Update Transaction',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // --- DELETE FUNCTION ---
  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction deleted'), behavior: SnackBarBehavior.floating),
    );
  }

  // Helper to format date simply without extra packages
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header / Total Balance Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('TOTAL BALANCE', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(
                  '\$${_totalBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: _totalBalance >= 0 ? const Color(0xFF00E676) : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: _transactions.isEmpty
                ? const Center(child: Text('No transactions yet. Add one!', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = _transactions[index];
                      final isIncome = tx.amount >= 0;

                      return Dismissible(
                        key: ValueKey(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) => _deleteTransaction(tx.id),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 0,
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: isIncome 
                                  ? const Color(0xFF00E676).withOpacity(0.1) 
                                  : Colors.redAccent.withOpacity(0.1),
                              child: Icon(
                                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isIncome ? const Color(0xFF00E676) : Colors.redAccent,
                              ),
                            ),
                            title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text(_formatDate(tx.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}\$${tx.amount.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isIncome ? const Color(0xFF00E676) : Colors.redAccent,
                              ),
                            ),
                            // Update triggered on tap
                            onTap: () => _showTransactionForm(tx),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Create triggered on FAB tap
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: Colors.black,
        onPressed: () => _showTransactionForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}