import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../widgets/add_expense_sheet.dart';
import '../../core/theme/app_colors.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  void _showAddExpense(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: const AddExpenseSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final totalSpent = ref.watch(totalExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Transactions'),
        elevation: 0,
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) return _buildEmptyState(context);

          // Get top category
          final Map<String, double> catSums = {};
          for (var e in expenses) {
            catSums[e.category] = (catSums[e.category] ?? 0) + e.amount;
          }
          String topCat = 'None';
          double topCatAmt = 0;
          catSums.forEach((k, v) {
            if (v > topCatAmt) {
              topCatAmt = v;
              topCat = k;
            }
          });

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSummaryCards(context, totalSpent, topCat, expenses.length),
                      const SizedBox(height: 32),
                      const Text('Category Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.indigo)),
                      const SizedBox(height: 16),
                      _buildBarChart(context, catSums),
                      const SizedBox(height: 32),
                      const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.indigo)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTransactionCard(context, expenses[index]),
                    childCount: expenses.length,
                  ),
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.grapePurple)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpense(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.grapePurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, double total, String topCat, int txCount) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.palePurple.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: AppColors.grapePurple),
                const SizedBox(height: 12),
                const Text('Total Spends', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('₹${NumberFormat.compact().format(total)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.indigo)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.orange),
                const SizedBox(height: 12),
                const Text('Highest Cost', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange)),
                const SizedBox(height: 4),
                Text(topCat, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade900), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, Map<String, double> catSums) {
    // Sort and get top 5
    var sortedKeys = catSums.keys.toList(growable: false)
      ..sort((k1, k2) => catSums[k2]!.compareTo(catSums[k1]!));
    
    final topKeys = sortedKeys.take(5).toList();
    if (topKeys.isEmpty) return const SizedBox.shrink();

    double maxVal = 0;
    for (var k in topKeys) {
      if (catSums[k]! > maxVal) maxVal = catSums[k]!;
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 2),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  if (val.toInt() >= topKeys.length) return const SizedBox.shrink();
                  final title = topKeys[val.toInt()];
                  // Truncate
                  final shortTitle = title.length > 5 ? title.substring(0, 5) : title;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(shortTitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.indigo)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: topKeys.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: catSums[e.value]!,
                  color: e.key == 0 ? AppColors.gold : AppColors.palePurple,
                  width: 16,
                  borderRadius: BorderRadius.circular(8),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Expense expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.palePurple.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(_getCategoryIcon(expense.category), color: AppColors.grapePurple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.indigo)),
                const SizedBox(height: 4),
                if (expense.notes != null)
                  Text(expense.notes!, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text(expense.paymentMode, style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Text(expense.tag, style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    Text(DateFormat('MMM d').format(expense.date), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '-₹${expense.amount.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.palePurple),
          const SizedBox(height: 16),
          const Text('No transactions found.', style: TextStyle(fontSize: 18, color: AppColors.indigo, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Record your first expense securely.', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Groceries')) return Icons.local_grocery_store_rounded;
    if (category.contains('Health')) return Icons.favorite_rounded;
    if (category.contains('Child')) return Icons.child_care_rounded;
    if (category.contains('Education')) return Icons.menu_book_rounded;
    if (category.contains('Transport')) return Icons.directions_bus_rounded;
    if (category.contains('Family')) return Icons.diversity_1_rounded;
    if (category.contains('Shopping')) return Icons.shopping_bag_rounded;
    if (category.contains('Work')) return Icons.business_center_rounded;
    if (category.contains('Emergency')) return Icons.medical_services_rounded;
    return Icons.category_rounded;
  }
}
