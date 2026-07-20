// lib/transactions_tab.dart
import 'package:flutter/material.dart';
import 'transaction.dart'; // Imports the model we just created

class TransactionsTab extends StatefulWidget {
  final List<Transaction> transactions;
  final VoidCallback onUpdate;

  const TransactionsTab({
    super.key, 
    required this.transactions, 
    required this.onUpdate
  });

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  double get _totalBalance {
    return widget.transactions.fold(0.0, (sum, item) => sum + item.amount);
  }

  void _showTransactionForm([Transaction? existingTransaction]) {
    final titleController = TextEditingController(text: existingTransaction?.title ?? '');
    final amountController = TextEditingController(
        text: existingTransaction != null ? existingTransaction.amount.abs().toString() : '');
    final vaultController = TextEditingController(text: existingTransaction?.vault ?? 'Personal');
    final tagController = TextEditingController(text: existingTransaction?.tag ?? '');
    
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existingTransaction == null ? 'New Transaction' : 'Edit Transaction',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Expense'),
                            selected: !isIncome,
                            selectedColor: Colors.redAccent.withValues(alpha: 0.2),
                            onSelected: (val) => setModalState(() => isIncome = false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Income'),
                            selected: isIncome,
                            selectedColor: const Color(0xFF00E676).withValues(alpha: 0.2),
                            onSelected: (val) => setModalState(() => isIncome = true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'What was this for?', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount (\$)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: vaultController,
                      decoration: const InputDecoration(labelText: 'Vault (e.g., Personal, SETScapade)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.account_balance_wallet)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tagController,
                      decoration: const InputDecoration(labelText: 'Tag (e.g., Project LUNTIAN, Hardware)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.label)),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          final title = titleController.text;
                          final amountText = amountController.text;
                          final vault = vaultController.text.isEmpty ? 'Personal' : vaultController.text;
                          final tag = tagController.text;

                          if (title.isEmpty || amountText.isEmpty) return;

                          final parsedAmount = double.tryParse(amountText) ?? 0.0;
                          final finalAmount = isIncome ? parsedAmount : -parsedAmount;

                          if (existingTransaction == null) {
                            widget.transactions.add(Transaction(
                              id: DateTime.now().toString(),
                              title: title,
                              amount: finalAmount,
                              date: DateTime.now(),
                              vault: vault,
                              tag: tag,
                            ));
                          } else {
                            existingTransaction.title = title;
                            existingTransaction.amount = finalAmount;
                            existingTransaction.vault = vault;
                            existingTransaction.tag = tag;
                          }
                          widget.onUpdate();
                          Navigator.of(ctx).pop();
                        },
                        child: Text(existingTransaction == null ? 'Save Transaction' : 'Update Transaction', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                const Text('TOTAL BALANCE', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(
                  '\$${_totalBalance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _totalBalance >= 0 ? const Color(0xFF00E676) : Colors.redAccent),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.transactions.isEmpty
                ? const Center(child: Text('No transactions yet. Add one!', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: widget.transactions.length,
                    itemBuilder: (ctx, index) {
                      final tx = widget.transactions[index];
                      final isIncome = tx.amount >= 0;

                      return Dismissible(
                        key: ValueKey(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.delete, color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) {
                          widget.transactions.removeWhere((item) => item.id == tx.id);
                          widget.onUpdate();
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 0,
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            leading: CircleAvatar(
                              backgroundColor: isIncome ? const Color(0xFF00E676).withValues(alpha: 0.1) : Colors.redAccent.withValues(alpha: 0.1),
                              child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? const Color(0xFF00E676) : Colors.redAccent),
                            ),
                            title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.account_balance_wallet, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(tx.vault, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      if (tx.tag.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.label, size: 14, color: Color(0xFF00E676)),
                                        const SizedBox(width: 4),
                                        Text(tx.tag, style: const TextStyle(color: Color(0xFF00E676), fontSize: 12)),
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${tx.date.month}/${tx.date.day}/${tx.date.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}\$${tx.amount.abs().toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isIncome ? const Color(0xFF00E676) : Colors.redAccent),
                            ),
                            onTap: () => _showTransactionForm(tx),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E676),
        foregroundColor: Colors.black,
        onPressed: () => _showTransactionForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
