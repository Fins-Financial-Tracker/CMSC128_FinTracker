import 'package:flutter/material.dart';

class CustomizationPage extends StatelessWidget {
  const CustomizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "customizations page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
