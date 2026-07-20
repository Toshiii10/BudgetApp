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

  // 1. Converts your data into a JSON map to save to the phone
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'vault': vault,
    'tag': tag,
  };

  // 2. Converts the saved JSON text back into a Dart object when the app opens
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    vault: json['vault'] ?? 'Personal',
    tag: json['tag'] ?? '',
  );
}
