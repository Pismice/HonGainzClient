import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart';
import '../navigation_home.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      try {
        // Send POST request to the backendpdated to use baseUrl
        var url = Uri.parse('${baseUrl}login');
        final response = await http.post(
          url,
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
        } else if (response.statusCode == 401) {
          // Invalid username or password
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid username or password")),
          );
        } else {
          // Other errors
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to log in")),
          );
        }
      } catch (e) {
        // Handle network or other errors
        debugPrint(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not connect to the server")),
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
        title: const Text("Login"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome Back!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
