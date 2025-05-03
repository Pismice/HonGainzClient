import 'package:flutter/material.dart';
import 'package:fronte/globals.dart';
import 'package:fronte/endpoints/template_exercises.dart'; // Import exercises.dart
import 'package:http/http.dart' as http;

class ModifySessionPage extends StatefulWidget {
  final int sessionId;
  final String initialName;
  final List<int> initialExerciseIds;

  const ModifySessionPage({
    super.key,
    required this.sessionId,
    required this.initialName,
    required this.initialExerciseIds,
  });

  @override
  State<ModifySessionPage> createState() => _ModifySessionPageState();
}

class _ModifySessionPageState extends State<ModifySessionPage> {
  late TextEditingController _nameController;
  List<int> _selectedExerciseIds = [];
  late Future<List<TemplateExercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedExerciseIds = List<int>.from(widget.initialExerciseIds);
    _exercisesFuture = fetchTemplateExercises(context); // Fetch exercises
  }

  Future<void> _modifySession() async {
    final String name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session name cannot be empty")),
      );
      return;
    }

    var url = Uri.parse(
        '${baseUrl}auth/template-sessions/${widget.sessionId}'); // Updated to use baseUrl
    try {
      var response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
        body:
            '{"name": "$name", "exercise_ids": ${_selectedExerciseIds.toString()}}', // Serialize IDs as a JSON array
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session modified successfully")),
        );
        Navigator.pop(context, true); // Return true on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to modify session: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print('Error modifying session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modify Session"),
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
              onPressed: _modifySession,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
