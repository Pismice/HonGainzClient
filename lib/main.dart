import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'globals.dart'; // Import globals.dart
import 'navigation_home.dart';
import 'introduction_screen.dart'; // Import the introduction screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize storage
    storage = const FlutterSecureStorage();
    // Check if session_id exists
    String? sessionId = await storage.read(key: "session_id");
    runApp(MyApp(isLoggedIn: sessionId != null));
  } catch (e) {
    // Handle keyring errors
    debugPrint('Error initializing secure storage: $e');
    runApp(const MyApp(isLoggedIn: false));
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HonGym',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const NavigationHome() : const IntroductionPage(),
    );
  }
}
