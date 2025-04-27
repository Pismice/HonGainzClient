import 'package:flutter/material.dart';
import 'package:fronte/home/active_session/doing_session_page.dart';
import 'package:fronte/models/real_sessions.dart';

class SessionList extends StatelessWidget {
  final List<RealSession> sessions;

  const SessionList({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sessions.map((session) {
        final hasFinishDate = session.finishDate != null;
        return Container(
          color: hasFinishDate
              ? Colors.red[100]
              : Colors.green[100], // Background color
          child: ListTile(
            title: Text(session.name ?? "Unnamed Session"),
            subtitle: Text('Session ID: ${session.id}'),
            onTap: () async {
              try {
                await startSession(session.id); // Call startSession
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Session started: ${session.name}')),
                );
                // Navigate to DoingSession
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoingSession(session: session),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }
}
