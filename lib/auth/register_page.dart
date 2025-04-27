import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart';
import '../navigation_home.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      try {
        // Send POST request to the backend
        var url = Uri.parse('${baseUrl}register');
        final response = await http.post(
          url, // Replace with your backend URL
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "username": _usernameController.text,
            "password": _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          // Save session_id to storage
          await storage.write(
              key: "session_id", value: responseData["session_id"]);

          // Navigate to the main app
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const NavigationHome()),
            (route) => false, // Remove all previous routes
          );
        } else if (response.statusCode == 409) {
          // Username already exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Username already exists")),
          );
        } else {
          // Other errors
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to register user")),
          );
        }
      } catch (e) {
        // Handle network or other errors
        debugPrint(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    } else {
      // Show error message for empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
