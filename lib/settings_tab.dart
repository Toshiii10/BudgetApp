// lib/settings_tab.dart
import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  // Mock function to simulate a file export
  void _simulateExport(BuildContext context, String format) {
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
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Success: BudgetReport.$format saved to device!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF00E676),
                ),
              );
            },
            child: const Text('Export File'),
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
            onTap: () => _simulateExport(context, 'CSV'),
          ),
          _buildSettingsCard(
            icon: Icons.picture_as_pdf,
            title: 'Export as PDF',
            subtitle: 'Best for printing and physical records',
            onTap: () => _simulateExport(context, 'PDF'),
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
              activeThumbColor: const Color(0xFF00E676), // <--- Updated here
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
              activeThumbColor: const Color(0xFF00E676), // <--- Updated here
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

  // Helper widget for clean list items
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
