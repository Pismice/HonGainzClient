import 'package:flutter/material.dart';
import 'package:fronte/globals.dart';
import 'package:fronte/endpoints/template_sessions.dart';
import 'package:http/http.dart' as http;

class ModifyWorkoutPage extends StatefulWidget {
  final int workoutId;
  final String initialName;
  final List<int> initialSessionIds;

  const ModifyWorkoutPage({
    super.key,
    required this.workoutId,
    required this.initialName,
    required this.initialSessionIds,
  });

  @override
  State<ModifyWorkoutPage> createState() => _ModifyWorkoutPageState();
}

class _ModifyWorkoutPageState extends State<ModifyWorkoutPage> {
  late TextEditingController _nameController;
  List<int> _selectedSessionIds = [];
  late Future<List<TemplateSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedSessionIds = List<int>.from(widget.initialSessionIds);
    _sessionsFuture = fetchTemplateSessions(context); // Fetch sessions
  }

  Future<void> _modifyWorkout() async {
    final String name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout name cannot be empty")),
      );
      return;
    }
    var url = Uri.parse('${baseUrl}auth/template-workouts/${widget.workoutId}');
    try {
      var response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
        body:
            '{"name": "$name", "session_ids": ${_selectedSessionIds.toString()}}', // Serialize IDs as a JSON array
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Workout modified successfully")),
        );
        Navigator.pop(context, true); // Return true on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to modify workout: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print('Error modifying workout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modify Workout"),
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
              onPressed: _modifyWorkout,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
