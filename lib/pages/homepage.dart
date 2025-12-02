// Store data and display it broken down by day of the week

import 'package:flutter/material.dart';
import 'expense_model.dart';
import 'dart:core';

class HomePage extends StatefulWidget {
  final List<Expense> expenses; 
  final Function(int) onDelete;

  const HomePage({
    super.key, 
    required this.expenses, 
    required this.onDelete,
  });
  // Permanent storage for every expense (static to make it accessible from anywhere in the app)
  static final List<Expense> expenses = [];
  // Global key to access state of Home Page from outside
  static final GlobalKey<_HomePageState> homePageStateKey = GlobalKey<_HomePageState>();

  @override
  State<HomePage> createState() => _HomePageState();
}

// Set up a stateful widget with mixing for animation control
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  
  final Color kBlueLight = const Color(0xFFDCE8F5);
  final Color kSelectedBlue = const Color(0xFF5E6C85);

  late List<DateTime> weekDates;
  late String currentMonthName;
  // Manage tabs on top of screen (the days of the week)
  late TabController _tabController;

List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday -1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

late List<DateTime> weekDates; 
  @override
  void initState() {
    super.initState();
    weekDates = _getCurrentWeekDates();
    
    final now = DateTime.now();
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    currentMonthName = months[now.month - 1];

    _tabController = TabController(length: weekDates.length, vsync: this);

    int todayIndex = 0;
    for (int i = 0; i < weekDates.length; i++) {
      if (_isSameDay(weekDates[i], now)) {
        todayIndex = i;
        break;
      }
    }
    _tabController.index = todayIndex;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); 
      }
    });
    // Calculate dates for the current week
    weekDates = getCurrentWeekDates(); 
    _tabController = TabController(length: weekDates.length, vsync: this, initialIndex: DateTime.now().weekday - 1); 
  }

  @override
  // Clean up page
  void dispose() {
    _tabController.dispose(); 
    super.dispose();
  }

  List<DateTime> _getCurrentWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // --- LOGIC: EDIT EXPENSE ---
  void _editExpense(int index, String name, double amount, String category, DateTime date, String details) {
    setState(() {
      widget.expenses[index] = Expense(
    // Tell the controller to free up system sources (manages the Mon-Sun tabs)
    _tabController.dispose();
    super.dispose(); 
  }

  DateTime getSelectedDate() {
    // Get actual date time object for the day 
    return weekDates[_tabController.index];
  }

  void _deleteExpense(int index) {
    // Notify flutter with the data change and trigger build method to run again
    setState(() {
      HomePage.expenses.removeAt(index);
    });
  }

  void _editExpense(int index, String name, double amount, String category,
      DateTime date, String details) {
    // Update UI after change
    setState(() {
      // Instead of removing, we update the existing data
      HomePage.expenses[index] = Expense(
        name: name,
        amount: amount,
        category: category,
        date: date,
        details: details,
      );
    });
  }

  // Edit popup
  void _openEditExpenseDialog(int index) {
    // Retrieve current expense object
    Expense e = HomePage.expenses[index];
    // Extract values from the object
    String name = e.name;
    String amount = e.amount.toString();
    String category = e.category;
    String details = e.details;
    DateTime selectedDate = e.date;

    // Display popup window
    showDialog(
      context: context,
      builder: (context) {
        // Self contained state since AlertDialog doesnt redraw after change
        //  Redraw the dialog only
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // Input boxes to change details
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Expense Name'),
                    controller: TextEditingController(text: name),
                    onChanged: (value) => name = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    controller: TextEditingController(text: amount),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => amount = value,
                  ),
                  DropdownButtonFormField(
                    value: ['transpo', 'food', 'education', 'wants'].contains(category) ? category : 'transpo',
                    items: const [
                      DropdownMenuItem(value: 'transpo', child: Text('Transpo')),
                      DropdownMenuItem(value: 'food', child: Text('Food')),
                      DropdownMenuItem(value: 'education', child: Text('Education')),
                      DropdownMenuItem(value: 'wants', child: Text('Wants')),
                    ],
                    onChanged: (value) {
                      if (value != null) setStateDialog(() => category = value.toString());
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Details'),
                    controller: TextEditingController(text: details),
                    onChanged: (value) => details = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setStateDialog(() => selectedDate = pickedDate);
                          }
                        },
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              // Submission Point
              ElevatedButton(
                onPressed: () {
                  if (name.isNotEmpty && double.tryParse(amount) != null) {
                    _editExpense(realIndex, name, double.parse(amount), category, selectedDate, details);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }
  String _getDayTotal(DateTime date) {
    final dayExpenses = widget.expenses.where((e) => _isSameDay(e.date, date)).toList();
    double total = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
    return "₱${total.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          currentMonthName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text("Weekly Expenses"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: weekDates.map((date) => Tab(
            text: '${['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][date.weekday-1]} ${date.day}/${date.month}',
          )).toList(),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 90,
            padding: const EdgeInsets.symmetric(horizontal: 8), // Add padding to sides
            // switched to ROW to fit everything on one screen
            child: Row(
              children: weekDates.asMap().entries.map((entry) {
                final index = entry.key;
                final date = entry.value;
                final dayName = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][date.weekday - 1];
                
                bool isSelected = _tabController.index == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(index);
                    },
                    child: Container(
                      // We removed the fixed width (55) and right margin
                      margin: const EdgeInsets.symmetric(horizontal: 4), // Small gap between bubbles
                      decoration: BoxDecoration(
                        color: isSelected ? kSelectedBlue : const Color(0xFFE0E0E0).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName, 
                            style: TextStyle(
                              fontSize: 11, // Slightly smaller to prevent clipping
                              color: isSelected ? Colors.white70 : Colors.grey
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(), 
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              color: isSelected ? Colors.white : Colors.grey[700]
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: weekDates.map((date) {
                return _buildDayPage(date);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPage(DateTime date) {
    final dayExpenses = widget.expenses.where((e) => _isSameDay(e.date, date)).toList();
      body: TabBarView(
        controller: _tabController,
        children: weekDates.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value; 
          // Filter expenses by selected weekday
          final filtered = HomePage.expenses.where((e) {
            return e.date.year == weekDates[index].year &&
                   e.date.month == weekDates[index].month &&
                   e.date.day == weekDates[index].day;
          }).toList();

    return Column(
      children: [
        // SUMMARY CARDS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard("Expenses", _getDayTotal(date)),
              const SizedBox(width: 8),
              _buildSummaryCard("Balance Left", "₱12,000"), 
              const SizedBox(width: 8),
              _buildSummaryCard("Savings", "₱12,000"), 
            ],
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: dayExpenses.isEmpty
              ? Center(
                  child: Text(
                    "No expenses for ${['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][date.weekday - 1]}.",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80), 
                  itemCount: dayExpenses.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = dayExpenses[index];
                    final realIndex = widget.expenses.indexOf(item);

                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (direction) => widget.onDelete(realIndex),
                      child: _buildTransactionItem(item, realIndex),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kBlueLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
            const SizedBox(height: 5),
            Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Expense item, int realIndex) {
    return Container(
      color: const Color(0xFFECF3FA),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.edit_square, color: Colors.grey[400], size: 24),
            onPressed: () => _openEditExpenseDialog(realIndex, item),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.directions_car_filled, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(item.category.toUpperCase(), style: TextStyle(color: Colors.blueGrey[300], fontSize: 10)),
            ],
          ),
          const Spacer(),
          Text("-₱${item.amount.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[400])),
        ],
      ),
    );
  }
}