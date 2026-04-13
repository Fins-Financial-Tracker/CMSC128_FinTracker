import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import 'expense_model.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  List<Expense> _expenses = [];
  bool _isLoading = true;
  late DateTime _selectedWeek;
  List<DateTime> _availableWeeks = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    _selectedWeek = currentDate.subtract(Duration(days: currentDate.weekday - 1));
    loadExpensesFromDB();
  }

  Future<void> loadExpensesFromDB() async {
    final db = DBHelper();
    final data = await db.getAllExpenses();

    setState(() {
      _expenses = data;
      _generateAvailableWeeks();
      _isLoading = false;
    });
  }

  void _generateAvailableWeeks() {
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);

    final currentStartOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));

    final List<DateTime> weeks = [];
    DateTime weekStart = currentStartOfWeek;

    while (true) {
      final weekEnd = weekStart.add(const Duration(days: 6));
      final isInCurrentMonth = weekStart.month == now.month || weekEnd.month == now.month;

      if (!isInCurrentMonth) {
        break;
      }

      weeks.add(weekStart);
      weekStart = weekStart.subtract(const Duration(days: 7));
    }

    _availableWeeks = weeks.reversed.toList();
  }

  String _formatWeekRange(DateTime startOfWeek) {
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${startOfWeek.month}/${startOfWeek.day} - ${endOfWeek.month}/${endOfWeek.day}';
  }

  Map<String, dynamic> calculateWeeklySummary() {
    final startOfWeek = DateTime(
      _selectedWeek.year,
      _selectedWeek.month,
      _selectedWeek.day,
    );

    final endOfWeek =
        startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    if (_expenses.isEmpty) {
      return {
        'total': 0.0,
        'categories': <Map<String, dynamic>>[],
        'chartCategories': <Map<String, dynamic>>[],
        'startOfWeek': startOfWeek,
        'endOfWeek': endOfWeek,
      };
    }

    final List<Expense> weeklyExpensesList = _expenses.where((e) {
      final expenseDate = DateTime(e.date.year, e.date.month, e.date.day);
      return (expenseDate.isAfter(startOfWeek) || expenseDate.isAtSameMomentAs(startOfWeek)) &&
          (expenseDate.isBefore(endOfWeek) || expenseDate.isAtSameMomentAs(endOfWeek));
    }).toList();

    final double total = weeklyExpensesList.fold(0.0, (sum, e) => sum + e.amount);

    final Map<String, double> categoryTotals = {};
    for (final expense in weeklyExpensesList) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final List<Map<String, dynamic>> categoryData = categoryTotals.entries.map((entry) {
      return {
        'name': entry.key,
        'amount': entry.value,
        'color': _getColorForCategory(entry.key),
      };
    }).toList();

    final double positiveSum = categoryTotals.values
        .where((v) => v > 0)
        .fold(0.0, (sum, v) => sum + v);

    final List<Map<String, dynamic>> chartData = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
      final percent = positiveSum > 0 ? ((entry.value / positiveSum) * 100).round() : 0;
      return {
        'name': entry.key,
        'amount': entry.value,
        'color': _getColorForCategory(entry.key),
        'percent': percent,
      };
    }).toList();

    return {
      'total': total,
      'categories': categoryData,
      'chartCategories': chartData,
      'startOfWeek': startOfWeek,
      'endOfWeek': endOfWeek,
    };
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color.fromARGB(255, 190, 173, 124);
      case 'school':
      case 'education':
        return const Color(0xFFFF7A45);
      case 'transpo':
        return const Color(0xFF4D78E6);
      case 'groceries':
        return const Color(0xFF8AD99A);
      case 'bill':
        return const Color.fromARGB(255, 117, 197, 213);
      case 'custom':
      case 'wants':
        return const Color.fromARGB(255, 187, 107, 227);
      default:
        return Colors.blueGrey.shade400;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'school':
      case 'education':
        return Icons.school;
      case 'transpo':
        return Icons.directions_car;
      case 'groceries':
        return Icons.local_grocery_store;
      case 'bill':
        return Icons.receipt;
      case 'custom':
      case 'wants':
        return Icons.account_balance_wallet;
      default:
        return Icons.category;
    }
  }

  List<PieChartSectionData> _getPieChartSections(List<Map<String, dynamic>> categoryData) {
    if (categoryData.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '0%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    return categoryData.map((data) {
      final color = data['color'] as Color;
      final value = data['amount'] as double;
      final title = '${data['percent']}%';

      return PieChartSectionData(
        color: color,
        value: value,
        title: title,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        showTitle: (data['percent'] as int) > 1,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final summary = calculateWeeklySummary();
    final double weeklyExpenses = summary['total'] as double;
    final List<Map<String, dynamic>> categoryData =
        List<Map<String, dynamic>>.from((summary['categories'] ?? const []) as List);
    final List<Map<String, dynamic>> chartData =
        List<Map<String, dynamic>>.from((summary['chartCategories'] ?? const []) as List);

    final pieChartSections = _getPieChartSections(chartData);
    final isDataEmpty = chartData.isEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'WEEKLY SUMMARY',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'TOTAL EXPENSE THIS WEEK',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '₱${weeklyExpenses.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Center(
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: PieChart(
                    PieChartData(
                      sections: pieChartSections,
                      centerSpaceRadius: 0,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 221, 226, 228),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCFD8DC)),
                ),
                child: DropdownButton<DateTime>(
                  value: _availableWeeks.contains(_selectedWeek)
                      ? _selectedWeek
                      : (_availableWeeks.isNotEmpty ? _availableWeeks.first : _selectedWeek),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF5E6C85)),
                  items: _availableWeeks.map((weekStart) {
                    return DropdownMenuItem<DateTime>(
                      value: weekStart,
                      child: Text(
                        _formatWeekRange(weekStart),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (DateTime? newWeek) {
                    if (newWeek != null) {
                      setState(() {
                        _selectedWeek = newWeek;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Expense Breakdown:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.blueGrey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: categoryData
                        .map((data) => CategoryListItem(
                              color: data['color'] as Color,
                              category: data['name'] as String,
                              amount: data['amount'] as double,
                              icon: _getIconForCategory(data['name'] as String),
                            ))
                        .toList(),
                  ),
                ),
              ),
              if (isDataEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: Text(
                      'No expenses recorded for this week.',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryListItem extends StatelessWidget {
  final Color color;
  final String category;
  final double amount;
  final IconData icon;

  const CategoryListItem({
    super.key,
    required this.color,
    required this.category,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final displayCategory =
        category.isNotEmpty ? category[0].toUpperCase() + category.substring(1) : category;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                displayCategory,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            '₱${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
