import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/expense_model.dart';
import '../services/expense_service.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final expenseService = ref.watch(expenseServiceProvider);
  return expenseService.getExpensesStream();
});

final totalExpensesProvider = Provider<double>((ref) {
  final expensesAsyncValue = ref.watch(expensesProvider);
  return expensesAsyncValue.maybeWhen(
    data: (expenses) => expenses.fold(0.0, (sum, item) => sum + item.amount),
    orElse: () => 0.0,
  );
});

final expensesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final expensesAsyncValue = ref.watch(expensesProvider);
  return expensesAsyncValue.maybeWhen(
    data: (expenses) {
      final Map<String, double> categorySums = {};
      for (var exp in expenses) {
        categorySums[exp.category] = (categorySums[exp.category] ?? 0.0) + exp.amount;
      }
      return categorySums;
    },
    orElse: () => {},
  );
});

// Advanced Analytics Providers for Dashboard Redesign
final expensesByTagProvider = Provider<Map<String, double>>((ref) {
  final expensesAsyncValue = ref.watch(expensesProvider);
  return expensesAsyncValue.maybeWhen(
    data: (expenses) {
      final Map<String, double> tagSums = {
        'Self': 0.0,
        'Family': 0.0,
        'Child': 0.0,
        'Household': 0.0,
        'Work': 0.0,
      };
      for (var exp in expenses) {
        if (tagSums.containsKey(exp.tag)) {
          tagSums[exp.tag] = tagSums[exp.tag]! + exp.amount;
        } else {
          tagSums[exp.tag] = exp.amount;
        }
      }
      return tagSums;
    },
    orElse: () => {},
  );
});

final safeToSpendProvider = Provider<double>((ref) {
  final totalSpent = ref.watch(totalExpensesProvider);
  final budget = ref.watch(expenseServiceProvider).monthlyBudget;
  // A simplistic safe to spend formula avoiding negative values visually for demo
  final remaining = budget - totalSpent;
  return remaining > 0 ? remaining : 0.0;
});
