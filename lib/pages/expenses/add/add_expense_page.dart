import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../builders/designs/bubble_background.dart';
import '../../builders/widgets/forms/addEdit_widget.dart';
import '../../expense_model.dart';
import '../../builders/designs/colors.dart';


class AddExpensePage extends StatefulWidget {
  final DateTime initialDate;
  const AddExpensePage({super.key, required this.initialDate});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  String name     = '';
  String amount   = '';
  String category = 'food';
  String details  = '';
  String customCategory = '';
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: AnimatedContainer(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut, width: 430, 
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
          maxWidth: 430,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: colorPageBg,
                ),
              ),

              // bg bubbles
              Bubble(top: -30, right: -20, size: 160, opacity: 0.45),
              Bubble(top: 40, right: 30, size: 80, opacity: 0.30),
              Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
              Bubble(bottom: 60, left: 20, size: 90, opacity: 0.25),
              Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),

            SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Add a new expense',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: colorNavy,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: colorNavy,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // card
                    Container(
                      decoration: BoxDecoration(
                        color: colorCardBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
                            buildLabel('Title'),
                            buildTextInput(
                              hint: 'Enter expense name here',
                              onChanged: (v) => name = v,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Enter a name'
                                  : null,
                            ),

                            const SizedBox(height: 14),

                            // Amount
                            buildLabel('Amount'),
                            buildTextInput(
                              hint: 'Enter amount here',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                              ],
                              onChanged: (v) => amount = v,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter amount';
                                }

                                final p = double.tryParse(v.trim());

                                if (p == null) return 'Enter valid amount';
                                if (p <= 0) return 'Amount must be positive';

                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // Category
                            buildLabel('Category'),
                            buildExpenseCategoryDropdown(
                              value: category,
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    category = v;

                                    if (category != 'custom') {
                                      customCategory = '';
                                    }
                                  });
                                }
                              },
                            ),

                            const SizedBox(height: 14),

                            if (category == 'custom') ...[
                              buildLabel('Custom Category'),
                              buildTextInput(
                                hint: 'Enter custom category',
                                onChanged: (v) => customCategory = v,
                                validator: (v) {
                                  if (category == 'custom' &&
                                      (v == null || v.trim().isEmpty)) {
                                    return 'Enter a custom category';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Date Spent
                            buildLabel('Date Spent'),
                            buildDatePicker(
                              context: context,
                              selectedDate: selectedDate,
                              onDateChanged: (d) {
                                setState(() => selectedDate = d);
                              },
                            ),

                            const SizedBox(height: 24),

                            // Add Expense button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final categoryToSave = category == 'custom'
                                        ? customCategory
                                        : category;

                                    final newExpense = Expense(
                                      name: name.trim(),
                                      amount: double.parse(amount.trim()),
                                      category: categoryToSave,
                                      date: selectedDate,
                                      details: details,
                                    );

                                    Navigator.pop(context, newExpense);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorNavy,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Add Expense',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}