// lib/transaction.dart

class Transaction {
  String id;
  String title;
  double amount;
  DateTime date;
  String vault; 
  String tag;   

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.vault = 'Personal',
    this.tag = '',
  });
}