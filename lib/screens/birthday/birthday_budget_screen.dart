import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'core/birthday_theme.dart';
import '../../providers/birthday_provider.dart';
import '../../models/birthday/birthday_expense.dart';

/// Smart Budget Manager screen with interactive charts, expense tracking,
/// category breakdowns, and real-time budget utilization analytics.
class BirthdayBudgetScreen extends StatefulWidget {
  const BirthdayBudgetScreen({super.key});

  @override
  State<BirthdayBudgetScreen> createState() => _BirthdayBudgetScreenState();
}

class _BirthdayBudgetScreenState extends State<BirthdayBudgetScreen> {
  int _touchedPieIndex = -1;
  String _selectedCategoryFilter = 'All';

  // Category Color Palette as defined for the Birthday Studio
  static const Map<String, Color> categoryColors = {
    'Venue': Color(0xFFB28A63),
    'Cake': Color(0xFFD9B7A7),
    'Decoration': Color(0xFFE8D8CC),
    'Food & Catering': Color(0xFF8B7355),
    'Food': Color(0xFF8B7355),
    'Photography': Color(0xFF6BAF7A),
    'Gifts': Color(0xFFD46B6B),
    'Entertainment': Color(0xFF7B68AE),
    'Invitations': Color(0xFF5DADE2),
    'Transport': Color(0xFFF0B27A),
    'Miscellaneous': Color(0xFFAAB7B8),
    'Misc': Color(0xFFAAB7B8),
  };

  static Color _getCategoryColor(String category) {
    if (categoryColors.containsKey(category)) {
      return categoryColors[category]!;
    }
    for (final entry in categoryColors.entries) {
      if (category.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return BirthdayTheme.mutedGold;
  }

  static IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'venue':
        return Icons.location_on_outlined;
      case 'cake':
        return Icons.cake_outlined;
      case 'decoration':
        return Icons.celebration_outlined;
      case 'food & catering':
      case 'food':
        return Icons.restaurant_outlined;
      case 'photography':
        return Icons.camera_alt_outlined;
      case 'gifts':
        return Icons.card_giftcard_outlined;
      case 'entertainment':
        return Icons.music_note_outlined;
      case 'invitations':
        return Icons.mail_outline;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'miscellaneous':
      case 'misc':
      default:
        return Icons.category_outlined;
    }
  }

  static String _formatCurrency(num amount) {
    final formatter = NumberFormat('#,##,###', 'en_US');
    final isNegative = amount < 0;
    final formatted = formatter.format(amount.abs().round());
    return isNegative ? '-৳$formatted' : '৳$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BirthdayProvider>(context);
    final activeEvent = provider.activeEvent;

    return Scaffold(
      backgroundColor: BirthdayTheme.warmIvory,
      appBar: AppBar(
        backgroundColor: BirthdayTheme.warmIvory,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: BirthdayTheme.deepCocoa, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Studio',
              style: BirthdayTheme.heading3,
            ),
            if (activeEvent != null)
              Text(
                '${activeEvent.personName}\'s Celebration',
                style: BirthdayTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          if (activeEvent != null)
            IconButton(
              icon: const Icon(Icons.add_chart_rounded, color: BirthdayTheme.mutedGold),
              tooltip: 'Add Quick Expense',
              onPressed: () => _openExpenseBottomSheet(context),
            ),
        ],
      ),
      floatingActionButton: activeEvent == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openExpenseBottomSheet(context),
              backgroundColor: BirthdayTheme.mutedGold,
              foregroundColor: BirthdayTheme.softWhite,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Add Expense',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BirthdayTheme.mutedGold),
            )
          : activeEvent == null
              ? _buildNoEventEmptyState()
              : _buildMainContent(context, provider, activeEvent),
    );
  }

  /// Empty state when no active event exists
  Widget _buildNoEventEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: BirthdayTheme.champagneBeige.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: BirthdayTheme.mutedGold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create a birthday event first',
              style: BirthdayTheme.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'To track expenses, estimate party costs, and manage your budget, please create or select an active birthday event.',
              style: BirthdayTheme.subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.maybePop(context),
              style: BirthdayTheme.primaryButton,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Return to Birthday Studio'),
            ),
          ],
        ),
      ),
    );
  }

  /// Main content view
  Widget _buildMainContent(
    BuildContext context,
    BirthdayProvider provider,
    dynamic activeEvent,
  ) {
    final expenses = provider.expenses;
    final totalBudget = (activeEvent.totalBudget as num?)?.toDouble() ?? 0;
    final totalSpent = provider.totalActualSpending;
    final totalEstimated = provider.totalEstimatedBudget;
    final remaining = totalBudget - totalSpent;
    final utilization = provider.budgetUtilization;
    final isOverBudget = totalSpent > totalBudget && totalBudget > 0;

    // Filtered expenses list
    final filteredExpenses = _selectedCategoryFilter == 'All'
        ? expenses
        : expenses.where((e) => e.category == _selectedCategoryFilter).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Over-budget alert banner
          if (isOverBudget) _buildOverBudgetAlert(totalSpent - totalBudget),

          // Budget Overview Card
          _buildBudgetOverviewCard(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            totalEstimated: totalEstimated,
            remaining: remaining,
            utilization: utilization,
            isOverBudget: isOverBudget,
          ),

          const SizedBox(height: 24),

          // Interactive Donut Chart Section
          _buildSpendingChartSection(expenses, totalSpent),

          const SizedBox(height: 24),

          // Category Breakdown Section
          _buildCategoryBreakdownSection(expenses),

          const SizedBox(height: 24),

          // Expense List Header & Filter
          _buildExpenseListHeader(expenses),

          const SizedBox(height: 12),

          // Expenses List or Empty State
          if (expenses.isEmpty)
            _buildEmptyExpensesState()
          else if (filteredExpenses.isEmpty)
            _buildNoFilteredExpensesState()
          else
            _buildExpenseListView(filteredExpenses),
        ],
      ),
    );
  }

  /// Over-budget warning alert card
  Widget _buildOverBudgetAlert(double excessAmount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BirthdayTheme.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BirthdayTheme.errorRed.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: BirthdayTheme.errorRed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: BirthdayTheme.errorRed, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Over-Budget Alert',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: BirthdayTheme.errorRed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your actual spending has exceeded your planned event budget by ${_formatCurrency(excessAmount)}. Review your expenses below.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: BirthdayTheme.deepCocoa.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Budget Overview Section Card
  Widget _buildBudgetOverviewCard({
    required double totalBudget,
    required double totalSpent,
    required double totalEstimated,
    required double remaining,
    required double utilization,
    required bool isOverBudget,
  }) {
    final progressValue = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BirthdayTheme.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Budget Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL EVENT BUDGET',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? BirthdayTheme.errorRed.withValues(alpha: 0.12)
                      : BirthdayTheme.champagneBeige.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOverBudget ? 'Over Budget' : 'On Track',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOverBudget ? BirthdayTheme.errorRed : BirthdayTheme.mutedGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatCurrency(totalBudget),
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: BirthdayTheme.deepCocoa,
            ),
          ),
          const SizedBox(height: 16),

          // Utilization Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 10,
              backgroundColor: BirthdayTheme.champagneBeige.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? BirthdayTheme.errorRed : BirthdayTheme.mutedGold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${utilization.toStringAsFixed(1)}% utilized',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOverBudget ? BirthdayTheme.errorRed : BirthdayTheme.deepCocoa,
                ),
              ),
              Text(
                'Remaining: ${_formatCurrency(remaining)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: remaining >= 0 ? BirthdayTheme.successGreen : BirthdayTheme.errorRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: BirthdayTheme.subtleBorder.withValues(alpha: 0.7), height: 1),
          const SizedBox(height: 16),

          // 3 Metric Summary Tiles
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Estimated Total',
                  value: _formatCurrency(totalEstimated),
                  icon: Icons.receipt_long_outlined,
                  color: BirthdayTheme.deepCocoa,
                ),
              ),
              Container(width: 1, height: 44, color: BirthdayTheme.subtleBorder.withValues(alpha: 0.7)),
              Expanded(
                child: _buildMetricTile(
                  label: 'Actual Spent',
                  value: _formatCurrency(totalSpent),
                  icon: Icons.payments_outlined,
                  color: isOverBudget ? BirthdayTheme.errorRed : BirthdayTheme.mutedGold,
                ),
              ),
              Container(width: 1, height: 44, color: BirthdayTheme.subtleBorder.withValues(alpha: 0.7)),
              Expanded(
                child: _buildMetricTile(
                  label: 'Remaining',
                  value: _formatCurrency(remaining),
                  icon: Icons.account_balance_wallet_outlined,
                  color: remaining >= 0 ? BirthdayTheme.successGreen : BirthdayTheme.errorRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Interactive Donut PieChart Section
  Widget _buildSpendingChartSection(List<BirthdayExpense> expenses, double totalSpent) {
    // Group actual spending by category
    final Map<String, double> categorySpending = {};
    for (final exp in expenses) {
      if (exp.actualCost > 0) {
        categorySpending[exp.category] = (categorySpending[exp.category] ?? 0) + exp.actualCost;
      }
    }

    final categoriesWithSpending = categorySpending.keys.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BirthdayTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spending Breakdown', style: BirthdayTheme.heading3),
              if (totalSpent > 0)
                Text(
                  '${categorySpending.length} Active Categories',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (totalSpent <= 0 || categoriesWithSpending.isEmpty)
            Container(
              height: 180,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: BirthdayTheme.champagneBeige.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pie_chart_outline_rounded, color: BirthdayTheme.mutedGold, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No actual expenses logged yet',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BirthdayTheme.deepCocoa,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add expenses with actual costs to see the breakdown chart',
                    style: BirthdayTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            // Donut Chart with Center Text
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedPieIndex = -1;
                              return;
                            }
                            _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                      centerSpaceRadius: 55,
                      sections: List.generate(categoriesWithSpending.length, (i) {
                        final isTouched = i == _touchedPieIndex;
                        final category = categoriesWithSpending[i];
                        final amount = categorySpending[category]!;
                        final percentage = (amount / totalSpent * 100);
                        final radius = isTouched ? 48.0 : 40.0;
                        final color = _getCategoryColor(category);

                        return PieChartSectionData(
                          color: color,
                          value: amount,
                          title: percentage >= 8 ? '${percentage.toStringAsFixed(0)}%' : '',
                          radius: radius,
                          titleStyle: GoogleFonts.plusJakartaSans(
                            fontSize: isTouched ? 13 : 11,
                            fontWeight: FontWeight.bold,
                            color: BirthdayTheme.softWhite,
                          ),
                        );
                      }),
                    ),
                  ),

                  // Center Text Info
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _touchedPieIndex >= 0 && _touchedPieIndex < categoriesWithSpending.length
                            ? categoriesWithSpending[_touchedPieIndex]
                            : 'Total Spent',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _touchedPieIndex >= 0 && _touchedPieIndex < categoriesWithSpending.length
                            ? _formatCurrency(categorySpending[categoriesWithSpending[_touchedPieIndex]]!)
                            : _formatCurrency(totalSpent),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: BirthdayTheme.deepCocoa,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Color-coded category legend chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoriesWithSpending.map((cat) {
                final color = _getCategoryColor(cat);
                final amount = categorySpending[cat]!;
                final percent = (amount / totalSpent * 100).toStringAsFixed(0);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BirthdayTheme.warmIvory,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BirthdayTheme.subtleBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$cat: $percent%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BirthdayTheme.deepCocoa,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Category Breakdown List
  Widget _buildCategoryBreakdownSection(List<BirthdayExpense> expenses) {
    if (expenses.isEmpty) return const SizedBox.shrink();

    // Group expenses by category
    final Map<String, List<BirthdayExpense>> grouped = {};
    for (final exp in expenses) {
      grouped.putIfAbsent(exp.category, () => []).add(exp);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Category Breakdown', style: BirthdayTheme.heading3),
            Text(
              'Est. vs Actual',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BirthdayTheme.mutedGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...grouped.entries.map((entry) {
          final category = entry.key;
          final catExpenses = entry.value;
          final estimatedSum = catExpenses.fold<double>(0, (s, e) => s + e.estimatedCost);
          final actualSum = catExpenses.fold<double>(0, (s, e) => s + e.actualCost);
          final color = _getCategoryColor(category);
          final icon = _getCategoryIcon(category);
          final ratio = estimatedSum > 0 ? (actualSum / estimatedSum).clamp(0.0, 1.0) : (actualSum > 0 ? 1.0 : 0.0);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BirthdayTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: BirthdayTheme.deepCocoa,
                            ),
                          ),
                          Text(
                            '${catExpenses.length} ${catExpenses.length == 1 ? 'item' : 'items'}',
                            style: BirthdayTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(actualSum),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: actualSum > estimatedSum && estimatedSum > 0
                                ? BirthdayTheme.errorRed
                                : BirthdayTheme.deepCocoa,
                          ),
                        ),
                        Text(
                          'Est: ${_formatCurrency(estimatedSum)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: BirthdayTheme.champagneBeige.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      actualSum > estimatedSum && estimatedSum > 0 ? BirthdayTheme.errorRed : color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Header & category chips filter for expenses list
  Widget _buildExpenseListHeader(List<BirthdayExpense> expenses) {
    final availableCategories = ['All', ...BirthdayExpense.categories.where((cat) {
      return expenses.any((e) => e.category == cat);
    })];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Expense Items', style: BirthdayTheme.heading3),
            Text(
              '${expenses.length} Total',
              style: BirthdayTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Horizontal filter chips if there are expenses
        if (expenses.isNotEmpty)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: availableCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = availableCategories[index];
                final isSelected = _selectedCategoryFilter == cat;

                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategoryFilter = cat);
                    }
                  },
                  selectedColor: BirthdayTheme.mutedGold,
                  backgroundColor: BirthdayTheme.softWhite,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? BirthdayTheme.softWhite : BirthdayTheme.deepCocoa,
                  ),
                  side: BorderSide(
                    color: isSelected ? BirthdayTheme.mutedGold : BirthdayTheme.subtleBorder,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
      ],
    );
  }

  /// Empty state when no expenses exist
  Widget _buildEmptyExpensesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BirthdayTheme.cardDecoration,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: BirthdayTheme.champagneBeige.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 38,
              color: BirthdayTheme.mutedGold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Expenses Recorded',
            style: BirthdayTheme.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your celebration on budget. Tap "+ Add Expense" to record venue deposits, cake orders, catering costs, and more.',
            style: BirthdayTheme.subtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openExpenseBottomSheet(context),
            style: BirthdayTheme.primaryButton,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add First Expense'),
          ),
        ],
      ),
    );
  }

  /// Empty state for selected filter
  Widget _buildNoFilteredExpensesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BirthdayTheme.cardDecoration,
      child: Column(
        children: [
          const Icon(Icons.filter_list_off_rounded, size: 36, color: BirthdayTheme.mutedGold),
          const SizedBox(height: 12),
          Text(
            'No $_selectedCategoryFilter expenses found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: BirthdayTheme.deepCocoa,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _selectedCategoryFilter = 'All'),
            child: Text(
              'Reset Filter',
              style: GoogleFonts.plusJakartaSans(
                color: BirthdayTheme.mutedGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Expense ListView with Swipe to Delete and Tap to Edit
  Widget _buildExpenseListView(List<BirthdayExpense> expenses) {
    final provider = Provider.of<BirthdayProvider>(context, listen: false);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final color = _getCategoryColor(expense.category);
        final icon = _getCategoryIcon(expense.category);

        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: BirthdayTheme.errorRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_outline_rounded, color: BirthdayTheme.softWhite, size: 24),
                SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(color: BirthdayTheme.softWhite, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: BirthdayTheme.warmIvory,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Delete Expense?', style: BirthdayTheme.heading3),
                content: Text(
                  'Are you sure you want to remove "${expense.description.isNotEmpty ? expense.description : expense.category}"?',
                  style: BirthdayTheme.body,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(color: BirthdayTheme.deepCocoa),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BirthdayTheme.errorRed,
                      foregroundColor: BirthdayTheme.softWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            provider.deleteExpense(expense.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Expense "${expense.description.isNotEmpty ? expense.description : expense.category}" deleted'),
                backgroundColor: BirthdayTheme.deepCocoa,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BirthdayTheme.cardDecoration,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _openExpenseBottomSheet(context, expense: expense),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category icon circle
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 12),

                      // Info Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.description.isNotEmpty ? expense.description : expense.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                color: BirthdayTheme.deepCocoa,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (expense.vendorName.isNotEmpty) ...[
                                  Text(
                                    expense.vendorName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: BirthdayTheme.mutedGold,
                                    ),
                                  ),
                                  Text(' • ', style: BirthdayTheme.bodySmall),
                                ],
                                Text(
                                  expense.category,
                                  style: BirthdayTheme.bodySmall,
                                ),
                              ],
                            ),
                            if (expense.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                expense.notes,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontStyle: FontStyle.italic,
                                  color: BirthdayTheme.deepCocoa.withValues(alpha: 0.55),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Amounts & Payment Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(expense.actualCost > 0 ? expense.actualCost : expense.estimatedCost),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: BirthdayTheme.deepCocoa,
                            ),
                          ),
                          if (expense.actualCost > 0 && expense.estimatedCost > 0)
                            Text(
                              'Est: ${_formatCurrency(expense.estimatedCost)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                              ),
                            ),
                          const SizedBox(height: 6),
                          _buildPaymentStatusChip(expense.paymentStatus),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Payment status badge chip
  Widget _buildPaymentStatusChip(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'paid':
        bg = BirthdayTheme.successGreen.withValues(alpha: 0.14);
        fg = BirthdayTheme.successGreen;
        label = 'Paid';
        break;
      case 'partial':
        bg = BirthdayTheme.mutedGold.withValues(alpha: 0.14);
        fg = BirthdayTheme.mutedGold;
        label = 'Partial';
        break;
      case 'pending':
      default:
        bg = BirthdayTheme.alertOrange.withValues(alpha: 0.14);
        fg = BirthdayTheme.alertOrange;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }

  /// Open Add/Edit bottom sheet
  void _openExpenseBottomSheet(BuildContext context, {BirthdayExpense? expense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ExpenseFormSheet(expense: expense),
    );
  }
}

/// Dedicated Stateful Bottom Sheet for adding or editing an expense.
/// Manages and disposes its own TextEditingControllers properly.
class _ExpenseFormSheet extends StatefulWidget {
  final BirthdayExpense? expense;

  const _ExpenseFormSheet({this.expense});

  @override
  State<_ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends State<_ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late TextEditingController _vendorController;
  late TextEditingController _estimatedController;
  late TextEditingController _actualController;
  late TextEditingController _notesController;

  late String _selectedCategory;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    final exp = widget.expense;
    _descriptionController = TextEditingController(text: exp?.description ?? '');
    _vendorController = TextEditingController(text: exp?.vendorName ?? '');
    _estimatedController = TextEditingController(
      text: (exp != null && exp.estimatedCost > 0) ? exp.estimatedCost.toStringAsFixed(0) : '',
    );
    _actualController = TextEditingController(
      text: (exp != null && exp.actualCost > 0) ? exp.actualCost.toStringAsFixed(0) : '',
    );
    _notesController = TextEditingController(text: exp?.notes ?? '');

    _selectedCategory = exp?.category ?? BirthdayExpense.categories.first;
    _selectedStatus = exp?.paymentStatus ?? 'pending';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _vendorController.dispose();
    _estimatedController.dispose();
    _actualController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<BirthdayProvider>(context, listen: false);
    final activeEvent = provider.activeEvent;
    if (activeEvent == null) return;

    final estimated = double.tryParse(_estimatedController.text.trim()) ?? 0;
    final actual = double.tryParse(_actualController.text.trim()) ?? 0;

    if (widget.expense != null) {
      // Edit existing expense
      final updated = BirthdayExpense(
        id: widget.expense!.id,
        eventId: activeEvent.id,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        vendorName: _vendorController.text.trim(),
        estimatedCost: estimated,
        actualCost: actual,
        paymentStatus: _selectedStatus,
        notes: _notesController.text.trim(),
        transactionDate: widget.expense!.transactionDate ?? DateTime.now(),
        createdAt: widget.expense!.createdAt,
      );
      provider.updateExpense(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense "${updated.description.isNotEmpty ? updated.description : updated.category}" updated!'),
          backgroundColor: BirthdayTheme.mutedGold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Add new expense
      final newExpense = BirthdayExpense(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        eventId: activeEvent.id,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        vendorName: _vendorController.text.trim(),
        estimatedCost: estimated,
        actualCost: actual,
        paymentStatus: _selectedStatus,
        notes: _notesController.text.trim(),
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
      );
      provider.addExpense(newExpense);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense "${newExpense.description.isNotEmpty ? newExpense.description : newExpense.category}" added!'),
          backgroundColor: BirthdayTheme.mutedGold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: BirthdayTheme.softWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: BirthdayTheme.champagneBeige,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Expense' : 'Add New Expense',
                    style: BirthdayTheme.heading3,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: BirthdayTheme.deepCocoa),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: BirthdayTheme.inputDecoration(
                  'Expense Category',
                  icon: Icons.category_outlined,
                ),
                dropdownColor: BirthdayTheme.warmIvory,
                items: BirthdayExpense.categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(
                      cat,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: BirthdayTheme.deepCocoa,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: BirthdayTheme.inputDecoration(
                  'Description',
                  hint: 'e.g. 2-Tier Vanilla Cake or Photo Booth',
                  icon: Icons.description_outlined,
                ),
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: BirthdayTheme.deepCocoa),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Vendor Name
              TextFormField(
                controller: _vendorController,
                decoration: BirthdayTheme.inputDecoration(
                  'Vendor / Store Name',
                  hint: 'e.g. Sweet Delights Bakery',
                  icon: Icons.storefront_outlined,
                ),
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: BirthdayTheme.deepCocoa),
              ),
              const SizedBox(height: 14),

              // Estimated & Actual Cost Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _estimatedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Estimated Cost',
                        prefixText: '৳ ',
                        prefixStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: BirthdayTheme.mutedGold,
                        ),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: BirthdayTheme.warmIvory,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: BirthdayTheme.subtleBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: BirthdayTheme.subtleBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: BirthdayTheme.mutedGold, width: 1.5),
                        ),
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: BirthdayTheme.deepCocoa,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _actualController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Actual Cost',
                        prefixText: '৳ ',
                        prefixStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: BirthdayTheme.mutedGold,
                        ),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          color: BirthdayTheme.deepCocoa.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: BirthdayTheme.warmIvory,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: BirthdayTheme.subtleBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: BirthdayTheme.subtleBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: BirthdayTheme.mutedGold, width: 1.5),
                        ),
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: BirthdayTheme.deepCocoa,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Payment Status Selector
              Text(
                'Payment Status',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: BirthdayTheme.deepCocoa.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusOption('pending', 'Pending', BirthdayTheme.alertOrange),
                  const SizedBox(width: 8),
                  _buildStatusOption('partial', 'Partial', BirthdayTheme.mutedGold),
                  const SizedBox(width: 8),
                  _buildStatusOption('paid', 'Paid', BirthdayTheme.successGreen),
                ],
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: BirthdayTheme.inputDecoration(
                  'Notes / Remarks',
                  hint: 'Payment deadlines, delivery notes, or balance due',
                  icon: Icons.notes_outlined,
                ),
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: BirthdayTheme.deepCocoa),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: BirthdayTheme.primaryButton,
                  child: Text(isEditing ? 'Save Changes' : 'Record Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusOption(String value, String label, Color accentColor) {
    final isSelected = _selectedStatus.toLowerCase() == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.15) : BirthdayTheme.warmIvory,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? accentColor : BirthdayTheme.subtleBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? accentColor : BirthdayTheme.deepCocoa.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
