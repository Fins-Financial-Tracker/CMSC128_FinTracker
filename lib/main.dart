import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// overall themes for the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 29, 67, 30),
        ),
      ),
      home: const ExpenseHomePage(),
    );
  }
}

class Expense {
  final String name;
  final double amount;
  final String category;
  final DateTime date;
  final String details;

  Expense({
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    required this.details,
  });
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final List<Expense> _expenses = [];

  void _addExpense(
      String name, double amount, String category, DateTime date, String details) {
    setState(() {
      _expenses.add(
        Expense(
          name: name,
          amount: amount,
          category: category,
          date: date,
          details: details,
        ),
      );
    });
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  void _openAddExpenseDialog() {
    String name = '';
    String amount = '';
    String category = 'transpo';
    String details = '';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Expense'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Expense Name'),
                      onChanged: (value) => name = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => amount = value,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration:
                          const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'transpo', child: Text('Transpo')),
                        DropdownMenuItem(value: 'food', child: Text('Food')),
                        DropdownMenuItem(
                            value: 'education', child: Text('Education')),
                        DropdownMenuItem(value: 'wants', child: Text('Wants')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            category = value;
                          });
                        }
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Details'),
                      onChanged: (value) => details = value,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                        ),
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
                              setStateDialog(() {
                                selectedDate = pickedDate;
                              });
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
                ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty && double.tryParse(amount) != null) {
                      _addExpense(name, double.parse(amount), category,
                          selectedDate, details);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editExpense(int index, String name, double amount, String category,
    DateTime date, String details) {
  setState(() {
    _expenses[index] = Expense(
      name: name,
      amount: amount,
      category: category,
      date: date,
      details: details,
    );
  });
} 

void _openEditExpenseDialog(int index) {
  // get current values
  Expense e = _expenses[index];
  String name = e.name;
  String amount = e.amount.toString();
  String category = e.category;
  String details = e.details;
  DateTime selectedDate = e.date;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: SingleChildScrollView(
            child: Column(
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
                  initialValue: category,
                  items: const [
                    DropdownMenuItem(value: 'transpo', child: Text('Transpo')),
                    DropdownMenuItem(value: 'food', child: Text('Food')),
                    DropdownMenuItem(value: 'education', child: Text('Education')),
                    DropdownMenuItem(value: 'wants', child: Text('Wants')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setStateDialog(() => category = value);
                    }
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
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && double.tryParse(amount) != null) {
                  _editExpense(
                    index,
                    name,
                    double.parse(amount),
                    category,
                    selectedDate,
                    details,
                  );
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

  @override
  Widget build(BuildContext context) {
    double total = _expenses.fold(0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FINS'),
        backgroundColor: const Color.fromARGB(255, 24, 67, 26),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.green.shade100,
            child: Text(
              'Total: ₱${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('No expenses yet.'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return ListTile(
                        onTap: () => _openEditExpenseDialog(index), // <--- ADD THIS
                        title: Text(expense.name),
                        subtitle: Text(
                          '₱${expense.amount.toStringAsFixed(2)} • ${expense.category}\n'
                          '${expense.details.isNotEmpty ? "${expense.details}\n" : ""}'
                          '${expense.date.toLocal().toString().split(" ")[0]}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Color.fromARGB(255, 94, 23, 18)),
                          onPressed: () => _deleteExpense(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}