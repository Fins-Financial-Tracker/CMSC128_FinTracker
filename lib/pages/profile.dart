import 'package:fins/main.dart';
import 'package:fins/themes/logic/app_themes.dart';
import 'package:flutter/material.dart';
import 'builders/designs/bubble_background.dart'; 
import 'settings_page.dart'; 
import 'package:fins/pages/homepage.dart';
import 'package:fins/pages/builders/widgets/profile_and_settings/settings_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isButtonDisabled = true;

  void _handleButtonTap() {
    setState(() {
      _isButtonDisabled = true;
    });
  }
  // AI WILL BE HERE
  // Soph: will add the theme settings here for now to fix multiple settings issue
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surface,
      body: Stack(
        children: [
          // Keep the bubbles so the app looks consistent!
          const Bubble(top: -30, right: -20, size: 160, opacity: 0.45),
          const Bubble(top: 40, right: 30, size: 80, opacity: 0.30),
          const Bubble(bottom: -40, left: -30, size: 180, opacity: 0.35),
          const Bubble(bottom: 60, left: 20, size: 90, opacity: 0.25),
          const Bubble(bottom: 180, right: -10, size: 110, opacity: 0.20),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context, 
                            MaterialPageRoute(builder: (context) => const ExpenseHomePage()), 
                            (route) => false);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_ios_new_rounded,
                                color: context.onSurface, size: 16),
                            const SizedBox(width: 4),  
                            Text(
                              'Back',
                              style: TextStyle(
                                color: context.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Profile',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Column(
                      children: [
                        /// FOR AI WIDGET - PLACEHOLDER & DISABLED FOR NOW
                        ListTileTheme.merge(
                          textColor: _isButtonDisabled ? context.onSurface.withValues(alpha: 0.4) : null,
                          iconColor: _isButtonDisabled ? context.onSurface.withValues(alpha: 0.4) : null,
                          child: buildItemRow(
                            label: "AI Assistant", 
                            icon: Icons.smart_toy_outlined,
                            isFirstRow: true,
                            isLastRow: false,
                            onTap: _isButtonDisabled ? null : _handleButtonTap,
                          ),
                        ),

                        /// SETTINGS PAGE - THEME SETTINGS FOR NOW
                        buildItemRow(
                          label: "Settings", 
                          icon: Icons.settings, 
                          isFirstRow: false,
                          isLastRow: true,
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsPage()),
                            );
                          },
                          trailing: Icon(
                            Icons.chevron_right_rounded, 
                            color: context.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ]
                    ),
                ], 
              ),
            ),
          ),
        ], 
      ),
    );
  }
}