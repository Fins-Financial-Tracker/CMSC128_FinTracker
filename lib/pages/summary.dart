import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import 'expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SummaryMode { weekly, monthly }
enum ChartMode { pie, bar }

const Color summaryPageBg = Color.fromARGB(255, 255, 255, 255);
const Color summaryCardBg = Color.fromARGB(255, 238, 245, 255);
const Color summaryInnerCardBg = Color(0xFFC9D3E0);
const Color summaryInputBg = Color(0xFFF7F9FC);
const Color summaryNavy = Color(0xFF1C2445);
const Color summaryMutedText = Color(0xFF6B7280);
const Color summaryBorder = Color(0xFFE3E8F0);

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<Expense> _expenses = [];
  bool _isLoading = true;

  late DateTime _selectedWeek;
  late DateTime _selectedMonth;

  List<DateTime> _availableWeeks = [];
  List<DateTime> _availableMonths = [];

  SummaryMode _summaryMode = SummaryMode.weekly;
  ChartMode _chartMode = ChartMode.pie;

  double _periodBudget = 0.0;
  String _budgetCycle = 'Weekly';

  Future<void> _loadBudgetFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBudget = prefs.getDouble('budgetAmount') ?? 0.0;
    final savedCycle = prefs.getString('budgetCycle') ?? 'Weekly';

    final start = _getCurrentPeriodStart();
    final end = _getCurrentPeriodEnd();
    final daysInPeriod = end.difference(start).inDays + 1;

    double convertedBudget = savedBudget;

    if (savedCycle == 'Weekly' && _summaryMode == SummaryMode.monthly) {
      convertedBudget = (savedBudget / 7) * daysInPeriod;
    } else if (savedCycle == 'Monthly' && _summaryMode == SummaryMode.weekly) {
      final daysInMonth = DateTime(start.year, start.month + 1, 0).day;
      convertedBudget = (savedBudget / daysInMonth) * daysInPeriod;
    }

    if (!mounted) return;

    setState(() {
      _periodBudget = convertedBudget;
      _budgetCycle = savedCycle;
    });
  }

  @override
  void initState() {
    super.initState();

    final now = _cleanDate(DateTime.now());
    _selectedWeek = _getStartOfWeek(now);
    _selectedMonth = DateTime(now.year, now.month, 1);

    loadExpensesFromDB();
  }

  Future<void> loadExpensesFromDB() async {
    final db = DBHelper();
    final data = await db.getAllExpenses();

    setState(() {
      _expenses = data;
      _generateAvailablePeriods();
      _isLoading = false;
    });

    await _loadBudgetFromPrefs();
  }

  static DateTime _cleanDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _getStartOfWeek(DateTime date) {
    final cleanDate = _cleanDate(date);
    return cleanDate.subtract(Duration(days: cleanDate.weekday - 1));
  }

  DateTime _getEndOfWeek(DateTime startOfWeek) {
    return startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
  }

  DateTime _getEndOfMonth(DateTime monthStart) {
    return DateTime(
      monthStart.year,
      monthStart.month + 1,
      0,
      23,
      59,
      59,
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _generateAvailablePeriods() {
    final now = _cleanDate(DateTime.now());

    DateTime earliestDate = now;

    if (_expenses.isNotEmpty) {
      earliestDate = _expenses
          .map((e) => _cleanDate(e.date))
          .reduce((a, b) => a.isBefore(b) ? a : b);
    }

    final currentWeekStart = _getStartOfWeek(now);
    final earliestWeekStart = _getStartOfWeek(earliestDate);
    final defaultEarliestWeek =
        currentWeekStart.subtract(const Duration(days: 7 * 11));

    final weekStop = earliestWeekStart.isBefore(defaultEarliestWeek)
        ? earliestWeekStart
        : defaultEarliestWeek;

    final weeks = <DateTime>[];
    DateTime weekCursor = currentWeekStart;

    while (!weekCursor.isBefore(weekStop)) {
      weeks.add(weekCursor);
      weekCursor = weekCursor.subtract(const Duration(days: 7));
    }

    _availableWeeks = weeks.reversed.toList();

    final currentMonthStart = DateTime(now.year, now.month, 1);
    final earliestMonthStart = DateTime(earliestDate.year, earliestDate.month, 1);
    final defaultEarliestMonth =
        DateTime(currentMonthStart.year, currentMonthStart.month - 11, 1);

    final monthStop = earliestMonthStart.isBefore(defaultEarliestMonth)
        ? earliestMonthStart
        : defaultEarliestMonth;

    final months = <DateTime>[];
    DateTime monthCursor = currentMonthStart;

    while (!monthCursor.isBefore(monthStop)) {
      months.add(monthCursor);
      monthCursor = DateTime(monthCursor.year, monthCursor.month - 1, 1);
    }

    _availableMonths = months.reversed.toList();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  DateTime _getCurrentPeriodStart() {
    return _summaryMode == SummaryMode.weekly
        ? _selectedWeek
        : _selectedMonth;
  }

  DateTime _getCurrentPeriodEnd() {
    if (_summaryMode == SummaryMode.weekly) {
      return _getEndOfWeek(_selectedWeek);
    }

    return _getEndOfMonth(_selectedMonth);
  }

  DateTime _getPreviousPeriodStart() {
    if (_summaryMode == SummaryMode.weekly) {
      return _selectedWeek.subtract(const Duration(days: 7));
    }

    return DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
  }

  DateTime _getPreviousPeriodEnd() {
    final previousStart = _getPreviousPeriodStart();

    if (_summaryMode == SummaryMode.weekly) {
      return _getEndOfWeek(previousStart);
    }

    return _getEndOfMonth(previousStart);
  }

  List<Expense> _expensesInRange(DateTime start, DateTime end) {
    final cleanStart = _cleanDate(start);
    final cleanEnd = _cleanDate(end);

    return _expenses.where((expense) {
      final expenseDate = _cleanDate(expense.date);

      return !expenseDate.isBefore(cleanStart) &&
          !expenseDate.isAfter(cleanEnd);
    }).toList();
  }

  double _totalForRange(DateTime start, DateTime end) {
    return _expensesInRange(start, end)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<String, dynamic> calculateSummary() {
    final start = _getCurrentPeriodStart();
    final end = _getCurrentPeriodEnd();

    final previousStart = _getPreviousPeriodStart();
    final previousEnd = _getPreviousPeriodEnd();

    final periodExpenses = _expensesInRange(start, end);

    final total =
        periodExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    final previousTotal = _totalForRange(previousStart, previousEnd);

    final Map<String, double> categoryTotals = {};

    for (final expense in periodExpenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final categoryData = categoryTotals.entries.map((entry) {
      return {
        'name': entry.key,
        'amount': entry.value,
        'color': _getColorForCategory(entry.key),
      };
    }).toList();

    categoryData.sort(
      (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
    );

    final chartData = categoryData
        .where((data) => (data['amount'] as double) > 0)
        .toList();

    return {
      'total': total,
      'previousTotal': previousTotal,
      'categories': categoryData,
      'chartCategories': chartData,
      'periodExpenses': periodExpenses,
      'start': start,
      'end': end,
    };
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color.fromARGB(255, 219, 201, 147);
      case 'school':
        return const Color(0xFFFF7A45);
      case 'transpo':
        return const Color(0xFF4D78E6);
      case 'groceries':
        return const Color(0xFF8AD99A);
      case 'bill':
        return const Color.fromARGB(255, 117, 197, 213);
      case 'custom':
        return const Color.fromARGB(255, 187, 107, 227);
      default:
        return const Color(0xFFBFC7D5);
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'school':
        return Icons.school;
      case 'transpo':
        return Icons.directions_car;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'bill':
        return Icons.receipt;
      case 'custom':
        return Icons.shopping_cart;
      default:
        return Icons.shopping_cart;
    }
  }

  List<PieChartSectionData> _getPieChartSections(
    List<Map<String, dynamic>> categoryData,
    double total,
  ) {
    if (categoryData.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '',
          radius: 86,
        ),
      ];
    }

    return categoryData.map((data) {
      final amount = data['amount'] as double;
      final percentage = total == 0 ? 0 : (amount / total) * 100;

      return PieChartSectionData(
        color: data['color'] as Color,
        value: amount,
        title: percentage < 5 ? '' : '${percentage.toStringAsFixed(0)}%',
        radius: 86,
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  int _transactionCountForCategory(
    String category,
    DateTime start,
    DateTime end,
  ) {
    return _expensesInRange(start, end).where((expense) {
      return expense.category.toLowerCase() == category.toLowerCase();
    }).length;
  }

  Widget _buildSummaryModeToggle() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: summaryInnerCardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildModeButton(
            label: 'Weekly',
            selected: _summaryMode == SummaryMode.weekly,
            onTap: () async {
              setState(() {
                _summaryMode = SummaryMode.weekly;
              });

              await _loadBudgetFromPrefs();
            },
          ),
          _buildModeButton(
            label: 'Monthly',
            selected: _summaryMode == SummaryMode.monthly,
            onTap: () async {
              setState(() {
                _summaryMode = SummaryMode.monthly;
              });
              await _loadBudgetFromPrefs();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? summaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : summaryNavy,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartModeToggle() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: summaryInnerCardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildChartButton(
              label: 'Pie',
              icon: Icons.donut_large_rounded,
              selected: _chartMode == ChartMode.pie,
              onTap: () {
                setState(() {
                  _chartMode = ChartMode.pie;
                });
              },
            ),
            _buildChartButton(
              label: 'Bar',
              icon: Icons.bar_chart_rounded,
              selected: _chartMode == ChartMode.bar,
              onTap: () {
                setState(() {
                  _chartMode = ChartMode.bar;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? summaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected ? Colors.white : summaryNavy.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(
    List<PieChartSectionData> pieChartSections,
    double total,
  ) {
    return Center(
      child: SizedBox(
        height: 300,
        width: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sections: pieChartSections,
                centerSpaceRadius: 72,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
            SizedBox(
              width: 135,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: summaryMutedText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₱${total.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: summaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(DateTime start, DateTime end) {
  final days = <DateTime>[];
  DateTime cursor = DateTime(start.year, start.month, start.day);

  while (!cursor.isAfter(DateTime(end.year, end.month, end.day))) {
    days.add(cursor);
    cursor = cursor.add(const Duration(days: 1));
  }

  final dailyTotals = days.map((day) {
    final dayExpenses = _expenses.where((expense) {
      final expenseDate = _cleanDate(expense.date);
      return _isSameDate(expenseDate, day);
    });

    return dayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }).toList();

  final dailyBudget = _periodBudget > 0 ? _periodBudget / days.length : 0.0;

  final maxDailyTotal = dailyTotals.isEmpty
      ? 0.0
      : dailyTotals.reduce((a, b) => a > b ? a : b);

  final baseMaxY = _periodBudget > maxDailyTotal ? _periodBudget : maxDailyTotal;

  final chartMaxY = baseMaxY == 0 ? 100.0 : baseMaxY;

  final barGroups = List.generate(days.length, (index) {
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: dailyTotals[index],
          width: _summaryMode == SummaryMode.weekly ? 18 : 5,
          color: summaryNavy,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  });

  return SizedBox(
    height: 300,
    child: LayoutBuilder(
      builder: (context, constraints) {
        return BarChart(
          BarChartData(
            maxY: chartMaxY,
            barGroups: barGroups,
            alignment: BarChartAlignment.spaceAround,

             extraLinesData: ExtraLinesData(
             horizontalLines: [
              if (_periodBudget > 0)
                HorizontalLine(
                  y: _periodBudget,
                  color: summaryNavy.withValues(alpha: 0.35),
                  strokeWidth: 1,
                  dashArray: [6, 4],
                ),
              ],
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: chartMaxY / 4,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: summaryBorder,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: chartMaxY / 4,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value >= 1000
                          ? '${(value / 1000).toStringAsFixed(1)}k'
                          : value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 9,
                        color: summaryMutedText,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();

                    if (index < 0 || index >= days.length) {
                      return const SizedBox.shrink();
                    }

                    if (_summaryMode == SummaryMode.weekly) {
                      const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: summaryMutedText,
                          ),
                        ),
                      );
                    }

                    final day = days[index].day;
                    final lastDay = days.last.day;

                    if (day != 1 && day % 5 != 0 && day != lastDay) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: summaryMutedText,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildComparisonChip(double currentTotal, double previousTotal) {
    final previousPeriod =
        _summaryMode == SummaryMode.weekly ? 'last week' : 'last month';

    IconData icon;
    Color color;
    String text;

    if (currentTotal == 0 && previousTotal == 0) {
      icon = Icons.info_outline_rounded;
      color = Colors.grey;
      text = 'No expenses this period.';
    } else if (previousTotal == 0) {
      icon = Icons.info_outline_rounded;
      color = Colors.grey;
      text = 'No $previousPeriod data to compare.';
    } else {
      final difference = currentTotal - previousTotal;
      final percentage = (difference.abs() / previousTotal) * 100;

      if (difference > 0) {
        icon = Icons.arrow_upward_rounded;
        color = const Color(0xFFD65A5A);
        text = '${percentage.toStringAsFixed(0)}% higher than $previousPeriod';
      } else if (difference < 0) {
        icon = Icons.arrow_downward_rounded;
        color = const Color(0xFF3E9C6A);
        text = '${percentage.toStringAsFixed(0)}% lower than $previousPeriod';
      } else {
        icon = Icons.remove_rounded;
        color = Colors.grey;
        text = 'Same spending as $previousPeriod';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    List<Map<String, dynamic>> categoryData,
    double total,
  ) {
    if (categoryData.isEmpty) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: summaryInnerCardBg.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense legend',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: summaryNavy,
            ),
          ),
          const SizedBox(height: 10),
          ...categoryData.map((data) {
            final name = data['name'] as String;
            final amount = data['amount'] as double;
            final color = data['color'] as Color;
            final percentage = total == 0 ? 0 : (amount / total) * 100;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _capitalize(name),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₱${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    final periods = _summaryMode == SummaryMode.weekly
        ? _availableWeeks
        : _availableMonths;

    final selectedPeriod =
        _summaryMode == SummaryMode.weekly ? _selectedWeek : _selectedMonth;

    final safeValue = periods.any((p) => _isSameDate(p, selectedPeriod))
        ? periods.firstWhere((p) => _isSameDate(p, selectedPeriod))
        : periods.last;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: summaryInputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: summaryBorder),
      ),
      child: DropdownButton<DateTime>(
        isExpanded: true,
        value: safeValue,
        underline: const SizedBox(),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: summaryNavy,
        ),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        items: periods.map((periodStart) {
          String label;

          if (_summaryMode == SummaryMode.weekly) {
            final endOfWeek = _getEndOfWeek(periodStart);
            label =
                '${_formatFullDate(periodStart)} - ${_formatFullDate(endOfWeek)}';
          } else {
            label = _formatMonthYear(periodStart);
          }

          return DropdownMenuItem<DateTime>(
            value: periodStart,
            child: Text(label),
          );
        }).toList(),
        onChanged: (DateTime? newPeriod) {
          if (newPeriod == null) return;

          setState(() {
            if (_summaryMode == SummaryMode.weekly) {
              _selectedWeek = newPeriod;
            } else {
              _selectedMonth = newPeriod;
            }
          });
        },
      ),
    );
  }

  Widget _expenseTile({
    required Color color,
    required String title,
    required double amount,
    required IconData icon,
    required int transactions,
  }) {
    final displayTitle = _capitalize(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: summaryCardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: summaryNavy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$transactions transaction${transactions == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: summaryMutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₱${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: summaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final summary = calculateSummary();

    final double totalExpenses = summary['total'] as double;
    final double previousTotal = summary['previousTotal'] as double;

    final DateTime start = summary['start'] as DateTime;
    final DateTime end = summary['end'] as DateTime;

    final List<Map<String, dynamic>> categoryData =
        List<Map<String, dynamic>>.from(
      (summary['categories'] ?? const []) as List,
    );

    final List<Map<String, dynamic>> chartData =
        List<Map<String, dynamic>>.from(
      (summary['chartCategories'] ?? const []) as List,
    );

    final pieChartSections = _getPieChartSections(chartData, totalExpenses);
    final isDataEmpty = chartData.isEmpty;

    return Scaffold(
      backgroundColor: summaryPageBg,
      appBar: AppBar(
        backgroundColor: summaryPageBg,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          _summaryMode == SummaryMode.weekly
              ? 'Weekly Expense'
              : 'Monthly Expense',
          style: const TextStyle(
            color: summaryNavy,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryModeToggle(),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: BoxDecoration(
                color: summaryCardBg,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildChartModeToggle(),
                  const SizedBox(height: 10),

                  if (_chartMode == ChartMode.pie)
                    _buildPieChart(pieChartSections, totalExpenses)
                  else
                    _buildBarChart(start, end),

                  const SizedBox(height: 16),
                  _buildComparisonChip(totalExpenses, previousTotal),
                  const SizedBox(height: 14),
                  _buildLegend(categoryData, totalExpenses),
                  const SizedBox(height: 18),
                  _buildPeriodDropdown(),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Breakdown',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202124),
                  ),
                ),
                Text(
                  _summaryMode == SummaryMode.weekly
                      ? 'This week'
                      : 'This month',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...categoryData.map(
              (data) => _expenseTile(
                color: data['color'] as Color,
                title: data['name'] as String,
                amount: data['amount'] as double,
                icon: _getIconForCategory(data['name'] as String),
                transactions: _transactionCountForCategory(
                  data['name'] as String,
                  start,
                  end,
                ),
              ),
            ),

            if (isDataEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Text(
                    _summaryMode == SummaryMode.weekly
                        ? 'No expenses recorded for this week.'
                        : 'No expenses recorded for this month.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}