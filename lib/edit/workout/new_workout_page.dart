import 'package:flutter/material.dart';
import 'package:fronte/globals.dart';
import 'package:fronte/models/template_sessions.dart';
import 'package:http/http.dart' as http;

class NewWorkoutPage extends StatefulWidget {
  const NewWorkoutPage({super.key});

  @override
  State<NewWorkoutPage> createState() => _NewWorkoutPageState();
}

class _NewWorkoutPageState extends State<NewWorkoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final List<int> _selectedSessionIds = [];
  late Future<List<TemplateSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchTemplateSessions(context); // Fetch sessions
  }

  Future<void> _createWorkout() async {
    final String name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout name cannot be empty")),
      );
      return;
    }

    var url = Uri.parse('${baseUrl}auth/template-workouts');
    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
        body:
            '{"name": "$name", "session_ids": ${_selectedSessionIds.toString()}}', // Serialize IDs as a JSON array
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Workout created successfully")),
        );
        Navigator.pop(context, true); // Return true on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create workout: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print('Error creating workout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Workout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Workout Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<TemplateSession>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final sessions = snapshot.data!;
                    return ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final isSelected =
                            _selectedSessionIds.contains(session.id);
                        return CheckboxListTile(
                          title: Text(session.name),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedSessionIds.add(session.id);
                              } else {
                                _selectedSessionIds.remove(session.id);
                              }
                            });
                          },
                        );
                      },
                    );
                  } else {
                    return const Text('No sessions found.');
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createWorkout,
              child: const Text("Create Workout"),
            ),
          ],
        ),
      ),
    );
  }
}
