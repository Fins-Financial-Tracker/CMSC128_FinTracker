import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'builders/designs/bubble_background.dart';
import 'package:fins/themes/logic/app_themes.dart';

import '../main.dart';
import '../utils/notification_helper.dart';

bool get _supportsNotifications =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);

class CustomizationPage extends StatefulWidget {
  const CustomizationPage({super.key});

  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String _selectedBudgetFrequency = 'Weekly';
  String _selectedReminderFrequency = 'Daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _notificationsEnabled = true;
  double? _savedBudget;
  bool _isButtonHovered = false;

  final List<String> _budgetFrequencies = ['Weekly', 'Monthly'];
  final List<String> _reminderFrequencies = ['Daily', 'Weekly', 'Monthly'];
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    if (_supportsNotifications) {
      _initializeNotifications();
    }
    _loadExistingSettings();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    await NotificationHelper.ensureInitialized();
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveCustomizations() async {
    final prefs = await SharedPreferences.getInstance();

    final parsedBudget = double.tryParse(_budgetController.text.trim());
    final budgetToStore = parsedBudget ?? _savedBudget ?? 0.0;

    await prefs.setDouble('budgetAmount', budgetToStore);
    await prefs.setString('budgetCycle', _selectedBudgetFrequency);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('reminderFrequency', _selectedReminderFrequency);
    await prefs.setInt('reminderHour', _selectedTime.hour);
    await prefs.setInt('reminderMinute', _selectedTime.minute);
    await prefs.setBool('pendingSchedule', true);
    await prefs.setBool('hasCompletedOnboarding', true);
    await prefs.setBool('isFirstTime', false);

    if (_notificationsEnabled) {
      await NotificationHelper.checkBatteryOptimizations();
      await NotificationHelper.scheduleFromPrefs();
      await NotificationHelper.showTestNotification(
        message: 'Reminders set for ${_selectedTime.format(context)}',
      );
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseHomePage()),
      (route) => false,
    );
  }

  Future<void> _loadExistingSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final b = prefs.getDouble('budgetAmount');
    if (b != null) setState(() => _savedBudget = b);

    final cycle = prefs.getString('budgetCycle');
    if (cycle != null && _budgetFrequencies.contains(cycle)) {
      setState(() => _selectedBudgetFrequency = cycle);
    }

    final notif = prefs.getBool('notificationsEnabled');
    if (notif != null) setState(() => _notificationsEnabled = notif);

    final savedFreq = prefs.getString('reminderFrequency');
    if (savedFreq != null && _reminderFrequencies.contains(savedFreq)) {
      setState(() => _selectedReminderFrequency = savedFreq);
    }

    final hour = prefs.getInt('reminderHour');
    final minute = prefs.getInt('reminderMinute');
    if (hour != null && minute != null) {
      setState(() => _selectedTime = TimeOfDay(hour: hour, minute: minute));
    }
  }

  String _formatCurrency(double value) => '₱${value.toStringAsFixed(2)}';

  Future<void> _updateNotificationsEnabled(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);

    if (enabled && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidImpl = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      try {
        final allowed = await androidImpl?.areNotificationsEnabled();
        if (allowed == false) {
          await androidImpl?.requestNotificationsPermission();
        }
      } catch (e) {
        debugPrint('Permission request failed: $e');
      }
    }

    if (!enabled && _supportsNotifications) {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/denim/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/denim/jean_scrap.png',
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(
                      'Customizations',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Cartoon',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        shadows: const [
                          Shadow(
                            offset: Offset(1, 8),
                            blurRadius: 0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: isSmallScreen ? 320 : 480,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/denim/leather.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Shape your account around\nyour habits and goals.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 22),
                            _buildLabel('Set your budget'),
                            _buildBudgetInputField(),
                            const SizedBox(height: 16),
                            _buildLabel('Choose your budget cycle'),
                            _buildDropdownSelector(
                              value: _selectedBudgetFrequency,
                              items: _budgetFrequencies,
                              onChanged: (v) =>
                                  setState(() => _selectedBudgetFrequency = v!),
                            ),
                            const SizedBox(height: 16),
                            _buildNotificationToggle(),
                            Visibility(
                              visible: _notificationsEnabled,
                              maintainState: true,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Divider(color: Colors.white24, height: 28),
                                  _buildLabel('Set your reminder frequency'),
                                  _buildReminderRow(context),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                width: isSmallScreen ? 250 : 250,
                                height: isSmallScreen ? 80 : 90,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  onEnter: (_) {
                                    if (!_isButtonHovered) {
                                      setState(() => _isButtonHovered = true);
                                    }
                                  },
                                  onExit: (_) {
                                    if (_isButtonHovered) {
                                      setState(() => _isButtonHovered = false);
                                    }
                                  },
                                  child: AnimatedScale(
                                    scale: _isButtonHovered ? 1.06 : 1.0,
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _saveCustomizations,
                                        borderRadius: BorderRadius.circular(14),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Positioned.fill(
                                              child: Image.asset(
                                                'assets/images/denim/button.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            Text(
                                              'Done',
                                              style: TextStyle(
                                                fontFamily: 'Cartoon',
                                                fontSize: isSmallScreen
                                                    ? 14
                                                    : 15,
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
                                ),
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBudgetInputField() {
    return TextField(
      controller: _budgetController,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 15, color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintText: _savedBudget != null
            ? _formatCurrency(_savedBudget!)
            : 'Enter your budget here...',
        hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
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
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: const Color(0xFF70372A),
          borderRadius: BorderRadius.circular(14),
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Enable Expense Reminders',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Switch(
          value: _notificationsEnabled,
          activeThumbColor: Colors.white,
          onChanged: _updateNotificationsEnabled,
        ),
      ],
    );
  }

  Widget _buildReminderRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildDropdownSelector(
            value: _selectedReminderFrequency,
            items: _reminderFrequencies,
            onChanged: (v) => setState(() => _selectedReminderFrequency = v!),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () => _selectTime(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              foregroundColor: Colors.white,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedTime.format(context),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.access_time_rounded, size: 16, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
