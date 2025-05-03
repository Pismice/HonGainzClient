import 'package:flutter/material.dart';
import 'package:fronte/globals.dart';
import 'package:fronte/models/template_exercises.dart'; // Import exercises.dart
import 'package:http/http.dart' as http;

class NewSessionPage extends StatefulWidget {
  const NewSessionPage({super.key});

  @override
  State<NewSessionPage> createState() => _NewSessionPageState();
}

class _NewSessionPageState extends State<NewSessionPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<int> _selectedExerciseIds = [];
  late Future<List<TemplateExercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = fetchTemplateExercises(context); // Fetch exercises
  }

  Future<void> _createSession() async {
    final String name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session name cannot be empty")),
      );
      return;
    }

    var url =
        Uri.parse('${baseUrl}auth/template-sessions'); // Updated URL formation
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
        body:
            '{"name": "$name", "exercise_ids": ${_selectedExerciseIds.toString()}}', // Serialize IDs as a JSON array
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session created successfully")),
        );
        Navigator.pop(context, true); // Return true on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create session: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print('Error creating session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Session"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Session Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<TemplateExercise>>(
                future: _exercisesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final exercises = snapshot.data!;
                    return ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        final isSelected =
                            _selectedExerciseIds.contains(exercise.id);
                        return CheckboxListTile(
                          title: Text(exercise.name),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedExerciseIds.add(exercise.id);
                              } else {
                                _selectedExerciseIds.remove(exercise.id);
                              }
                            });
                          },
                        );
                      },
                    );
                  } else {
                    return const Text('No exercises found.');
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createSession,
              child: const Text("Create Session"),
            ),
          ],
        ),
      ),
    );
  }
}
