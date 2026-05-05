import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../expense_model.dart';
import 'package:fins/themes/logic/app_themes.dart';

class AddExpensePage extends StatefulWidget {
  final DateTime initialDate;
  const AddExpensePage({super.key, required this.initialDate});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String amount = '';
  String category = 'food';
  String details = '';
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(context.backgroundImagePath, fit: BoxFit.cover),
          ),
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Image.asset(context.jeanScrapImagePath, fit: BoxFit.contain),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Page title
                    const Text(
                      'Add a new expense',
                      style: TextStyle(
                        fontFamily: 'Cartoon',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 8),
                            blurRadius: 0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // card
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(context.leatherTextureImagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
                            _buildLabel('Title'),
                            _buildTextInput(
                              hint: 'Enter expense name here',
                              onChanged: (v) => name = v,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Enter a name'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // Amount
                            _buildLabel('Amount'),
                            _buildTextInput(
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
                                if (v == null || v.trim().isEmpty)
                                  return 'Enter amount';
                                final p = double.tryParse(v.trim());
                                if (p == null) return 'Enter valid amount';
                                if (p <= 0) return 'Amount must be positive';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Category
                            _buildLabel('Category'),
                            _buildExpenseCategoryDropdown(
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
                              _buildLabel('Custom Category'),
                              _buildTextInput(
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
                            _buildLabel('Date Spent'),
                            _buildDatePicker(
                              context: context,
                              selectedDate: selectedDate,
                              onDateChanged: (d) =>
                                  setState(() => selectedDate = d),
                            ),
                            const SizedBox(height: 24),

                            // Add Expense button
                            SizedBox(
                              height: 70,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      final newExpense = Expense(
                                        name: name,
                                        amount: double.parse(amount),
                                        category: category == 'custom'
                                            ? customCategory.trim()
                                            : category,
                                        date: selectedDate,
                                        details: details,
                                      );
                                      Navigator.pop(context, newExpense);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned.fill(
                                        child: Image.asset(
                                          context.buttonImagePath,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      const Text(
                                        'Add Expense',
                                        style: TextStyle(
                                          fontFamily: 'Cartoon',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
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
            ),
          ),

          // back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextInput({
    TextEditingController? controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildExpenseCategoryDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    const validCategories = [
      'transpo',
      'food',
      'school',
      'groceries',
      'bill',
      'education',
      'wants',
      'custom',
    ];
    final safeValue = validCategories.contains(value) ? value : 'food';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: const Color(0xFF70372A),
          borderRadius: BorderRadius.circular(14),
          items: const [
            DropdownMenuItem(value: 'transpo', child: Text('Transpo')),
            DropdownMenuItem(value: 'food', child: Text('Food')),
            DropdownMenuItem(value: 'school', child: Text('School')),
            DropdownMenuItem(value: 'groceries', child: Text('Groceries')),
            DropdownMenuItem(value: 'bill', child: Text('Bill')),
            DropdownMenuItem(value: 'education', child: Text('Education')),
            DropdownMenuItem(value: 'wants', child: Text('Wants')),
            DropdownMenuItem(value: 'custom', child: Text('Custom')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required BuildContext context,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onDateChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formattedDate(selectedDate),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
