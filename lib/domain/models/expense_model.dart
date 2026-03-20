import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final String paymentMode; // Cash, UPI, Card, Bank
  final String tag;         // Self, Family, Child, Household, Work

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.paymentMode = 'UPI',
    this.tag = 'Self',
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'Others',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
      paymentMode: data['paymentMode'] ?? 'UPI',
      tag: data['tag'] ?? 'Self',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'paymentMode': paymentMode,
      'tag': tag,
    };
  }
}

class SavingsGoal {
  final String title;
  final double targetAmount;
  final double savedAmount;

  SavingsGoal({
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
  });

  double get progress => (savedAmount / targetAmount).clamp(0.0, 1.0);
  double get remaining => targetAmount - savedAmount;
}

class UpcomingDue {
  final String title;
  final double amount;
  final DateTime dueDate;
  final String iconType; 

  UpcomingDue({
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.iconType,
  });
}
