import 'package:flutter/material.dart';
import 'package:fronte/globals.dart';
import 'package:http/http.dart' as http;

class NewExercisePage extends StatefulWidget {
  const NewExercisePage({super.key});

  @override
  State<NewExercisePage> createState() => _NewExercisePageState();
}

class _NewExercisePageState extends State<NewExercisePage> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _createExercise() async {
    final String name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exercise name cannot be empty")),
      );
      return;
    }

    var url = Uri.parse(
        '${baseUrl}auth/template-exercises'); // Updated to use baseUrl
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
        body: '{"name": "$name"}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Exercise created successfully")),
        );
        Navigator.pop(context, true); // Return true on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to create exercise: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Exercise"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Exercise Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createExercise,
              child: const Text("Create Exercise"),
            ),
          ],
        ),
      ),
    );
  }
}
