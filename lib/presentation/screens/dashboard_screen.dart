import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsGoal = ref.watch(expenseServiceProvider).savingsGoal;
    final upcomingDues = ref.watch(expenseServiceProvider).upcomingDues;
    final safeToSpend = ref.watch(safeToSpendProvider);
    final tagsSplit = ref.watch(expensesByTagProvider);
    final totalSpent = ref.watch(totalExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSmartInsight(context, totalSpent),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildSafeToSpendCard(context, safeToSpend)),
                const SizedBox(width: 16),
                Expanded(child: _buildSavingsGoalCard(context, savingsGoal)),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Spending Breakdown'),
            const SizedBox(height: 16),
            _buildSpendingSplitCard(context, tagsSplit),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Upcoming Commitments'),
            const SizedBox(height: 16),
            _buildUpcomingDues(context, upcomingDues),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.indigo,
            letterSpacing: -0.5,
          ),
    );
  }

  Widget _buildSmartInsight(BuildContext context, double totalSpent) {
    final bool warning = totalSpent > 25000;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: warning ? Colors.orange.shade50 : AppColors.palePurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warning ? Colors.orange.shade200 : AppColors.palePurple),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.warning_amber_rounded : Icons.tips_and_updates_rounded,
            color: warning ? Colors.orange : AppColors.grapePurple,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              warning
                  ? "You are spending more on household needs this week. Use the AI Chat to find savings tips!"
                  : "Great start! You're within budget. Your Emergency Fund goal is 45% complete.",
              style: TextStyle(
                color: warning ? Colors.orange.shade900 : AppColors.indigo,
                fontSize: 14.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeToSpendCard(BuildContext context, double safeToSpend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.grapePurple, AppColors.grapePurple.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.grapePurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Safe to Spend',
            style: TextStyle(color: AppColors.palePurple, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            '₹${NumberFormat.compact().format(safeToSpend)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.shield_rounded, color: AppColors.gold, size: 14)),
              const SizedBox(width: 8),
              const Text('On track', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSavingsGoalCard(BuildContext context, dynamic goal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Savings Goal',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            '₹${NumberFormat.compact().format(goal.savedAmount)}',
            style: const TextStyle(color: AppColors.indigo, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: AppColors.palePurple.withOpacity(0.4),
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Target: ₹${NumberFormat.compact().format(goal.targetAmount)}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingSplitCard(BuildContext context, Map<String, double> tagsSplit) {
    final self = tagsSplit['Self'] ?? 0;
    final family = tagsSplit['Family'] ?? 0;
    final child = tagsSplit['Child'] ?? 0;
    final house = tagsSplit['Household'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildSplitRow(Icons.face_3_rounded, 'Self & Personal', self, AppColors.grapePurple),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, thickness: 1)),
          _buildSplitRow(Icons.family_restroom_rounded, 'Family & Kids', family + child, AppColors.gold),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, thickness: 1)),
          _buildSplitRow(Icons.roofing_rounded, 'Household', house, AppColors.darkGold),
        ],
      ),
    );
  }

  Widget _buildSplitRow(IconData icon, String title, double amount, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.indigo)),
        ),
        Text(
          '₹${NumberFormat.compact().format(amount)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.indigo),
        ),
      ],
    );
  }

  Widget _buildUpcomingDues(BuildContext context, List<dynamic> upcomingDues) {
    if (upcomingDues.isEmpty) {
      return const Text("No upcoming dues this month.", style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: upcomingDues.map((due) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.palePurple.withOpacity(0.8), width: 1.5),
            boxShadow: [BoxShadow(color: AppColors.palePurple.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.palePurple.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
                child: Icon(due.iconType == 'education' ? Icons.school_rounded : Icons.home_rounded, color: AppColors.grapePurple, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(due.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.indigo)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(
                          'Due ${DateFormat('MMM d').format(due.dueDate)}',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '₹${NumberFormat.compact().format(due.amount)}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.indigo),
              ),
            ],
          ));
        }).toList(),
      );
    }
}
