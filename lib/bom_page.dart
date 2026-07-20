// lib/bom_page.dart
import 'package:flutter/material.dart';
import 'transaction.dart';

class BomPage extends StatelessWidget {
  final String projectName;
  final double allocatedBudget;
  final List<Transaction> allTransactions;

  const BomPage({
    super.key,
    required this.projectName,
    required this.allocatedBudget,
    required this.allTransactions,
  });

  // Filter transactions to only show expenses with this project's tag
  List<Transaction> get _projectComponents {
    return allTransactions.where((tx) => tx.tag == projectName && tx.amount < 0).toList();
  }

  double get _totalSpent {
    return _projectComponents.fold(0.0, (sum, item) => sum + item.amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final double remaining = allocatedBudget - _totalSpent;
    final double spentPercentage = (_totalSpent / allocatedBudget).clamp(0.0, 1.0);
    final components = _projectComponents;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(projectName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- PROJECT BUDGET HEADER ---
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Allocated Funding', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text('\$${allocatedBudget.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: spentPercentage,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      spentPercentage > 0.9 ? Colors.redAccent : Colors.cyanAccent,
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
                        const Text('Spent on Parts', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('\$${_totalSpent.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Remaining', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('\$${remaining.toStringAsFixed(2)}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'BILL OF MATERIALS',
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
          ),

          // --- COMPONENTS LIST ---
          Expanded(
            child: components.isEmpty
                ? const Center(child: Text('No components logged for this project yet.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: components.length,
                    itemBuilder: (ctx, index) {
                      final tx = components[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        color: const Color(0xFF1A1A1A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.memory, color: Colors.cyanAccent),
                          title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text('${tx.date.month}/${tx.date.day}/${tx.date.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          trailing: Text(
                            '\$${tx.amount.abs().toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}