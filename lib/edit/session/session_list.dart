import 'package:flutter/material.dart';
import 'package:fronte/models/template_sessions.dart';

import 'modify_session_page.dart';

class SessionList extends StatefulWidget {
  const SessionList({super.key});

  @override
  SessionListState createState() => SessionListState();
}

class SessionListState extends State<SessionList> {
  late Future<List<TemplateSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = fetchTemplateSessions();
  }

  void refreshSessions() {
    setState(() {
      _sessionsFuture = fetchTemplateSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TemplateSession>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final sessions = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                title: Text(session.name),
                subtitle: Text('ID: ${session.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModifySessionPage(
                              sessionId: session.id,
                              initialName: session.name,
                              initialExerciseIds: session.exerciseIds,
                            ),
                          ),
                        );
                        if (result == true) {
                          refreshSessions(); // Refresh the list after modification
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Confirm deletion and delete session
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Session'),
                              content: const Text(
                                  'Are you sure you want to delete this session?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          await deleteSession(session.id);
                          refreshSessions();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Text('No sessions found.');
        }
      },
    );
  }
}
