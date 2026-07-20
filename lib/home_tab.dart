// lib/home_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'transaction.dart';

class HomeTab extends StatelessWidget {
  final List<Transaction> transactions;

  const HomeTab({super.key, required this.transactions});

  // --- PIE CHART LOGIC ---
  double get _totalExpenses {
    return transactions
        .where((tx) => tx.amount < 0)
        .fold(0.0, (sum, item) => sum + item.amount.abs());
  }

  Map<String, double> get _expenseBreakdown {
    Map<String, double> breakdown = {};
    for (var tx in transactions) {
      if (tx.amount < 0) {
        String category = tx.tag.isNotEmpty ? tx.tag : tx.vault;
        breakdown[category] = (breakdown[category] ?? 0) + tx.amount.abs();
      }
    }
    return breakdown;
  }

  // --- BURN RATE WIDGET LOGIC ---
  // In a full app, these would be adjustable in settings. For now, we mock the parameters.
  final double internshipAllowance = 8000.00; 
  final int totalDays = 45; // roughly 300 hours spread across weeks
  final int daysPassed = 12; // Example progress

  double get _allowanceSpent {
    // We calculate only the expenses tagged for the internship/daily use
    return transactions
        .where((tx) => tx.amount < 0 && tx.vault == 'Personal') 
        .fold(0.0, (sum, item) => sum + item.amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = _expenseBreakdown;
    final total = _totalExpenses;
    
    // Burn Rate Calculations
    final int daysRemaining = totalDays - daysPassed;
    final double remainingAllowance = internshipAllowance - _allowanceSpent;
    final double safeDailySpend = daysRemaining > 0 ? (remainingAllowance / daysRemaining) : 0.0;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NEW: DAILY BURN RATE WIDGET ---
            const Text(
              'ACTIVE ALLOWANCE',
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A24), Color(0xFF121212)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Safe to spend today', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$daysRemaining days left', 
                          style: const TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${safeDailySpend.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _allowanceSpent / internshipAllowance,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Spent: \$${_allowanceSpent.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text('Total: \$${internshipAllowance.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // --- EXISTING PIE CHART ---
            const Text(
              'EXPENSE OVERVIEW',
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: breakdown.isEmpty
                  ? const Center(child: Text('No expenses to analyze yet.', style: TextStyle(color: Colors.grey)))
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 70,
                            sections: _generateChartSections(breakdown, total),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Total Spent', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(
                              '\$${total.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'CATEGORIES',
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ...breakdown.entries.map((entry) {
              final percentage = (entry.value / total) * 100;
              return _buildLegendItem(
                title: entry.key,
                amount: entry.value,
                percentage: percentage,
                color: _getColorForCategory(entry.key),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateChartSections(Map<String, double> breakdown, double total) {
    return breakdown.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: _getColorForCategory(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 25,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildLegendItem({required String title, required double amount, required double percentage, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Color _getColorForCategory(String category) {
    final hash = category.hashCode;
    final colors = [
      const Color(0xFF00E676),
      Colors.cyanAccent,
      Colors.amberAccent,
      Colors.pinkAccent,
      Colors.purpleAccent,
    ];
    return colors[hash.abs() % colors.length];
  }
}
