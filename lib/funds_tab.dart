// lib/funds_tab.dart
import 'package:flutter/material.dart';

class FundsTab extends StatelessWidget {
  const FundsTab({super.key});

  // Mock data representing a comprehensive financial footprint
  final double liquidCash = 4500.00;
  final double projectAllocations = 2500.00;
  final double emergencySavings = 12000.00;

  double get totalAssets => liquidCash + projectAllocations + emergencySavings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net Worth Header
            Text(
              'TOTAL NET WORTH',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '\$${totalAssets.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Asset Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Asset Cards
            _buildAssetCard(
              context,
              title: 'Liquid Cash',
              subtitle: 'Checking & physical reserves',
              amount: liquidCash,
              icon: Icons.wallet,
              color: const Color(0xFF00E676),
            ),
            _buildAssetCard(
              context,
              title: 'Special Project Funding',
              subtitle: 'Allocated hardware & build resources',
              amount: projectAllocations,
              icon: Icons.memory,
              color: Colors.cyanAccent,
            ),
            _buildAssetCard(
              context,
              title: 'Emergency Vault',
              subtitle: 'Fixed long-term security reserves',
              amount: emergencySavings,
              icon: Icons.security,
              color: Colors.amberAccent,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to keep UI consistent and clean
  Widget _buildAssetCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}