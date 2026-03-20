import 'dart:async';
import '../domain/models/expense_model.dart';

class ExpenseService {
  final List<Expense> _mockExpenses = [];
  final _expensesController = StreamController<List<Expense>>.broadcast();

  // New mockup data for the advanced dashboard features
  SavingsGoal get savingsGoal => SavingsGoal(
    title: 'Emergency Fund',
    targetAmount: 50000,
    savedAmount: 22500,
  );

  List<UpcomingDue> get upcomingDues => [
    UpcomingDue(title: 'School Fees', amount: 8500, dueDate: DateTime.now().add(const Duration(days: 4)), iconType: 'education'),
    UpcomingDue(title: 'Home EMI', amount: 15400, dueDate: DateTime.now().add(const Duration(days: 12)), iconType: 'home'),
  ];
  
  double get monthlyBudget => 40000;

  ExpenseService() {
    // Initial rich mock data
    _mockExpenses.add(Expense(
      id: 'mock_1',
      amount: 450,
      category: 'Groceries',
      date: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Weekly vegetables',
      paymentMode: 'UPI',
      tag: 'Household',
    ));
    _mockExpenses.add(Expense(
      id: 'mock_2',
      amount: 4500,
      category: 'Child Expenses',
      date: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Uniform & Books',
      paymentMode: 'UPI',
      tag: 'Child',
    ));
    _mockExpenses.add(Expense(
      id: 'mock_3',
      amount: 1200,
      category: 'Personal Care',
      date: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Salon',
      paymentMode: 'Card',
      tag: 'Self',
    ));
    _mockExpenses.add(Expense(
      id: 'mock_4',
      amount: 8000,
      category: 'Family Support',
      date: DateTime.now().subtract(const Duration(days: 5)),
      notes: 'Sent to parents',
      paymentMode: 'Bank',
      tag: 'Family',
    ));
    _mockExpenses.add(Expense(
      id: 'mock_5',
      amount: 320,
      category: 'Transport',
      date: DateTime.now().subtract(const Duration(days: 0)),
      notes: 'Cab to work',
      paymentMode: 'UPI',
      tag: 'Work',
    ));
  }

  Stream<List<Expense>> getExpensesStream() async* {
    yield List.unmodifiable([..._mockExpenses]);
    yield* _expensesController.stream;
  }

  Future<void> addExpense(Expense expense) async {
    try {
      final newExpense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: expense.amount,
        category: expense.category,
        date: expense.date,
        notes: expense.notes,
        paymentMode: expense.paymentMode,
        tag: expense.tag,
      );
      _mockExpenses.insert(0, newExpense);
      _expensesController.add(List.unmodifiable([..._mockExpenses]));
    } catch (e) {
      print("Warning: Add expense failed natively, mock continues. Details: $e");
    }
  }

  Future<void> deleteExpense(String id) async {
    _mockExpenses.removeWhere((e) => e.id == id);
    _expensesController.add(List.unmodifiable([..._mockExpenses]));
  }
}
