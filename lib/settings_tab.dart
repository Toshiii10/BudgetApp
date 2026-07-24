// lib/settings_tab.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction.dart';

class SettingsTab extends StatefulWidget {
  final List<Transaction> transactions;

  const SettingsTab({super.key, required this.transactions});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isPinEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
  }

  // 1. Check if a PIN already exists when the Settings tab loads
  Future<void> _checkPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedPin = prefs.getString('user_pin');
    setState(() {
      _isPinEnabled = savedPin != null && savedPin.isNotEmpty;
    });
  }

  // 2. The Dialogue box where you type your new PIN
  Future<void> _showPinSetupDialog() async {
    TextEditingController pinController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Set Security PIN', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: '0000',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E676))),
          ),
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
            onPressed: () async {
              if (pinController.text.length == 4) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('user_pin', pinController.text);
                setState(() => _isPinEnabled = true);
                if (ctx.mounted) Navigator.of(ctx).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App locked. PIN saved!'), backgroundColor: Color(0xFF00E676)),
                );
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  // 3. Removes the PIN from the hard drive
  Future<void> _disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_pin');
    setState(() => _isPinEnabled = false);
  }

  // --- THE EXPORT ENGINE (Unchanged) ---
  Future<void> _exportToCSV(BuildContext context) async {
    try {
      List<List<dynamic>> rows = [
        ['Date', 'Title', 'Amount', 'Vault', 'Tag', 'Transaction ID']
      ];
      for (var tx in widget.transactions) {
        rows.add([
          '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}',
          tx.title, tx.amount, tx.vault, tx.tag, tx.id,
        ]);
      }
      String csvData = rows.map((row) {
        return row.map((cell) {
          String cellString = cell.toString();
          if (cellString.contains(',')) return '"$cellString"';
          return cellString;
        }).join(','); 
      }).join('\n'); 

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/Vault_Ledger_Export.csv';
      final File file = File(path);
      await file.writeAsString(csvData);
      await SharePlus.instance.share(ShareParams(files: [XFile(path)], text: 'Attached is the exported financial ledger.'));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  void _showExportDialog(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Export to $format', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('This will compile all transactions into a single $format file. Proceed?', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (format == 'CSV') _exportToCSV(context);
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
          const Text('SECURITY', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildSettingsCard(
            icon: Icons.lock,
            title: 'App Lock PIN',
            subtitle: _isPinEnabled ? 'PIN is currently active' : 'Secure your ledgers with a 4-digit PIN',
            trailing: Switch(
              value: _isPinEnabled,
              activeThumbColor: const Color(0xFF00E676),
              onChanged: (val) {
                if (val) {
                  _showPinSetupDialog();
                } else {
                  _disablePin();
                }
              }, 
            ),
            onTap: () {},
          ),
          
          const SizedBox(height: 32),
          const Text('DATA MANAGEMENT', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSettingsCard(icon: Icons.table_chart, title: 'Export as CSV', subtitle: 'Best for spreadsheets', onTap: () => _showExportDialog(context, 'CSV')),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Widget? trailing}) {
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
