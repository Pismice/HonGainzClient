import 'package:flutter/material.dart';
import 'package:fronte/models/real_sessions.dart';
import '../active_session/doing_session_page.dart'; // Import DoingSession
import 'package:fronte/models/real_workouts.dart';

class SessionList extends StatefulWidget {
  final List<RealSession> sessions; // Use a single variable

  const SessionList({
    super.key,
    required this.sessions,
  });

  @override
  _SessionListState createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  Future<void> _refreshSessions() async {
    final updatedWorkout =
        await fetchActiveRealWorkout(); // Fetch updated workout
    if (updatedWorkout != null) {
      setState(() {
        widget.sessions.clear();
        widget.sessions.addAll(updatedWorkout.sessions); // Update sessions
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.sessions.map((session) {
        Color backgroundColor;

        if (session.finishDate != null) {
          backgroundColor = Colors.green[900]!; // Finished: Dark Red
        } else if (session.startDate != null) {
          backgroundColor = Colors.blue[900]!; // Started: Dark Blue
        } else {
          backgroundColor = Colors.grey[500]!; // Not started: Dark Green
        }

        return Container(
          decoration: session.startDate == null && session.finishDate == null
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(16.0), // Match card corners
                )
              : null,
          padding: session.startDate == null && session.finishDate == null
              ? const EdgeInsets.all(0.0) // Reduced border thickness
              : null,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // Rounded corners
            ),
            color: backgroundColor,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 25.0, // Increase vertical padding
                horizontal: 16.0,
              ),
              title: Text(
                session.name ?? "Unnamed Session",
                style:
                    const TextStyle(color: Colors.white), // White text for dark mode
              ),
              trailing: session.finishDate != null
                  ? const Icon(Icons.check,
                      color: Colors.white) // Checkmark for finished sessions
                  : session.startDate != null && session.finishDate == null
                      ? const Icon(Icons.timer,
                          color:
                              Colors.white) // Timer icon for ongoing sessions
                      : null,
              onTap: session.finishDate == null
                  ? () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoingSession(session: session),
                        ),
                      );
                      _refreshSessions(); // Refresh sessions if changes were made or nothing is returned
                    }
                  : null, // Disable tap if session is finished
            ),
          ),
        );
      }).toList(),
    );
  }
}
