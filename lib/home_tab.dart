// lib/home_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'transaction.dart';

class HomeTab extends StatelessWidget {
  final List<Transaction> transactions;

  const HomeTab({super.key, required this.transactions});

  // Calculate total expenses to generate percentages
  double get _totalExpenses {
    return transactions
        .where((tx) => tx.amount < 0)
        .fold(0.0, (sum, item) => sum + item.amount.abs());
  }

  // Group expenses dynamically by their Vault or Tag
  Map<String, double> get _expenseBreakdown {
    Map<String, double> breakdown = {};
    for (var tx in transactions) {
      if (tx.amount < 0) {
        // Use the tag if it exists (e.g., 'Project LUNTIAN'), otherwise use the Vault
        String category = tx.tag.isNotEmpty ? tx.tag : tx.vault;
        breakdown[category] = (breakdown[category] ?? 0) + tx.amount.abs();
      }
    }
    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = _expenseBreakdown;
    final total = _totalExpenses;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXPENSE OVERVIEW',
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // --- PIE CHART CANVAS ---
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
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
                        // Center Text
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
            
            // --- DYNAMIC LEGEND ---
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

  // Generates the colored slices of the pie chart
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

  // Helper widget for the list below the chart
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

  // Assigns distinct neon colors to different categories
  Color _getColorForCategory(String category) {
    final hash = category.hashCode;
    final colors = [
      const Color(0xFF00E676), // Neon Green
      Colors.cyanAccent,
      Colors.amberAccent,
      Colors.pinkAccent,
      Colors.purpleAccent,
    ];
    return colors[hash.abs() % colors.length];
  }
}
