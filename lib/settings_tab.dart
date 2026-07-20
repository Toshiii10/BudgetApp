// lib/settings_tab.dart
import 'package:flutter/material.dart';
import 'dart:io';

// --- ALL REQUIRED IMPORTS ---
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // Fixes the SharePlus error

import 'transaction.dart';

class SettingsTab extends StatelessWidget {
  final List<Transaction> transactions;

  const SettingsTab({super.key, required this.transactions});

  // --- THE EXPORT ENGINE ---
  Future<void> _exportToCSV(BuildContext context) async {
    try {
      // 1. Define the Spreadsheet Headers
      List<List<dynamic>> rows = [
        ['Date', 'Title', 'Amount', 'Vault', 'Tag', 'Transaction ID']
      ];

      // 2. Loop through your data and build the rows
      for (var tx in transactions) {
        rows.add([
          '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}',
          tx.title,
          tx.amount,
          tx.vault,
          tx.tag,
          tx.id,
        ]);
      }

      // 3. Convert the rows into a CSV string NATIVELY (No package needed!)
      String csvData = rows.map((row) {
        return row.map((cell) {
          String cellString = cell.toString();
          // If a title has a comma in it, wrap it in quotes so it doesn't break the spreadsheet
          if (cellString.contains(',')) {
            return '"$cellString"';
          }
          return cellString;
        }).join(','); // Join columns with commas
      }).join('\n'); // Join rows with newlines

      // 4. Find a temporary folder on the phone to build the file
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/Vault_Ledger_Export.csv';
      final File file = File(path);

      // 5. Write the data to the file
      await file.writeAsString(csvData);

      // 6. Trigger the native Android Share UI 
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)], 
          text: 'Attached is the exported financial ledger.',
        ),
      );
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // UI Dialogue to confirm before exporting
  void _showExportDialog(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Export to $format', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'This will compile all personal and organizational vault transactions into a single $format file. Proceed?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialogue
              if (format == 'CSV') {
                _exportToCSV(context); // Fire the engine!
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF Export coming soon!'), backgroundColor: Colors.cyanAccent),
                );
              }
            },
            child: const Text('Generate File'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'DATA MANAGEMENT',
            style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildSettingsCard(
            icon: Icons.table_chart,
            title: 'Export as CSV',
            subtitle: 'Best for spreadsheets and expense reports',
            onTap: () => _showExportDialog(context, 'CSV'),
          ),
          _buildSettingsCard(
            icon: Icons.picture_as_pdf,
            title: 'Export as PDF',
            subtitle: 'Best for printing and physical records',
            onTap: () => _showExportDialog(context, 'PDF'),
          ),
          
          const SizedBox(height: 32),
          const Text(
            'PREFERENCES',
            style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildSettingsCard(
            icon: Icons.dark_mode,
            title: 'Theme',
            subtitle: 'Dark Mode (Default)',
            trailing: Switch(
              value: true,
              activeThumbColor: const Color(0xFF00E676),
              onChanged: (val) {}, 
            ),
            onTap: () {},
          ),
          _buildSettingsCard(
            icon: Icons.notifications,
            title: 'Reminders',
            subtitle: 'Alert me before fixed bills are due',
            trailing: Switch(
              value: false,
              activeThumbColor: const Color(0xFF00E676),
              onChanged: (val) {}, 
            ),
            onTap: () {},
          ),
          
          const SizedBox(height: 32),
          Center(
            child: Text(
              'App Version 1.0.0\nBuilt with Flutter',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: const Color(0xFF00E676)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
