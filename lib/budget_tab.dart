// lib/budget_tab.dart
import 'package:flutter/material.dart';

class BudgetTab extends StatefulWidget {
  const BudgetTab({super.key});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  // Mock data: Set a monthly budget limit
  final double monthlyBudget = 1500.00;
  
  // Mock data: Recurring monthly costs
  final List<Map<String, dynamic>> _recurringCosts = [
    {
      'title': 'Strength Training Gym', 
      'amount': 45.00, 
      'dueDate': '1st', 
      'icon': Icons.fitness_center, 
      'color': Colors.orangeAccent
    },
    {
      'title': 'Dedicated Game Server', 
      'amount': 22.50, 
      'dueDate': '15th', 
      'icon': Icons.dns, 
      'color': Colors.cyanAccent
    },
    {
      'title': 'Cloud Storage', 
      'amount': 9.99, 
      'dueDate': '20th', 
      'icon': Icons.cloud, 
      'color': Colors.purpleAccent
    },
  ];

  double get _totalRecurring {
    return _recurringCosts.fold(0.0, (sum, item) => sum + item['amount']);
  }

  @override
  Widget build(BuildContext context) {
    final double remainingBudget = monthlyBudget - _totalRecurring;
    final double spentPercentage = _totalRecurring / monthlyBudget;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MONTHLY OVERHEAD',
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // --- PROGRESS BAR CARD ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Budget', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text('\$${monthlyBudget.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Linear Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: spentPercentage,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        spentPercentage > 0.8 ? Colors.redAccent : const Color(0xFF00E676),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fixed Spend', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('\$${_totalRecurring.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Safe to Spend', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('\$${remainingBudget.toStringAsFixed(2)}', style: const TextStyle(color: const Color(0xFF00E676), fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'ACTIVE SUBSCRIPTIONS',
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- RECURRING LIST ---
            ..._recurringCosts.map((sub) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: sub['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(sub['icon'], color: sub['color']),
                ),
                title: Text(sub['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text('Due on the ${sub['dueDate']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: Text(
                  '-\$${sub['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}