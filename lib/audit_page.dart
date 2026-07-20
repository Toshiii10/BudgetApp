// lib/audit_page.dart
import 'package:flutter/material.dart';
import 'transaction.dart';

class AuditPage extends StatelessWidget {
  final String vaultName;
  final List<Transaction> allTransactions;

  const AuditPage({
    super.key,
    required this.vaultName,
    required this.allTransactions,
  });

  // Filter out everything except this specific organizational vault
  List<Transaction> get _vaultTransactions {
    final filtered = allTransactions.where((tx) => tx.vault == vaultName).toList();
    // Sort chronologically for a proper ledger view
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  double get _totalInflow {
    return _vaultTransactions
        .where((tx) => tx.amount > 0)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalOutflow {
    return _vaultTransactions
        .where((tx) => tx.amount < 0)
        .fold(0.0, (sum, item) => sum + item.amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _vaultTransactions;
    final netBalance = _totalInflow - _totalOutflow;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Slightly darker for a formal look
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OFFICIAL LEDGER', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2)),
            Text(vaultName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Color(0xFF00E676)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audit report generated for export.'),
                  backgroundColor: Color(0xFF00E676),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- FORMAL AUDIT SUMMARY ---
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Inflow (Funds Collected)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('+\$${_totalInflow.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 24, color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Outflow (Expenses)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('-\$${_totalOutflow.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 24, color: Colors.grey),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('NET VAULT BALANCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    Text(
                      '\$${netBalance.toStringAsFixed(2)}', 
                      style: TextStyle(
                        color: netBalance >= 0 ? Colors.white : Colors.redAccent, 
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ITEMIZED RECORD',
                style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // --- READ-ONLY LEDGER LIST ---
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text('No records found for this vault.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = transactions[index];
                      final isIncome = tx.amount >= 0;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          leading: Icon(
                            isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
                            color: isIncome ? const Color(0xFF00E676) : Colors.grey.shade600,
                          ),
                          title: Text(
                            tx.title, 
                            style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontWeight: FontWeight.bold) // Monospace font for receipt vibe
                          ),
                          subtitle: Text(
                            'ID: ${tx.id.substring(0, 8)} • ${tx.date.month}/${tx.date.day}/${tx.date.year}', 
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 11)
                          ),
                          trailing: Text(
                            '${isIncome ? '+' : '-'}\$${tx.amount.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isIncome ? const Color(0xFF00E676) : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier'
                            ),
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