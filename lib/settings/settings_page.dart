import 'package:flutter/material.dart';
import '../globals.dart';
import '../auth/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    // Clear session_id from storage
    await storage.delete(key: "session_id");

    // Navigate to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Set button color to red
          ),
          onPressed: () => _logout(context),
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
