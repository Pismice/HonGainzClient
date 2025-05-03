import 'package:flutter/material.dart';
import 'package:fronte/auth/login_page.dart';

void navigateToLogin(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
        builder: (context) =>
            const LoginPage()), // Replace with your login page widget
    (route) => false, // Clear all previous routes
  );
}
