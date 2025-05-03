import 'package:flutter/material.dart';
import 'package:fronte/endpoints/real_sessions.dart';
import 'package:fronte/endpoints/stats.dart'; // Import for date formatting
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:intl/date_symbol_data_local.dart'; // Import for locale initialization
import 'session_details_page.dart'; // Import the session details page

class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  late Future<List<RealSession>> _realSessionsFuture =
      Future.value([]); // Initialize with an empty Future

  @override
  void initState() {
    super.initState();
    initializeDateFormatting("fr_FR", null).then((_) {
      setState(() {
        _realSessionsFuture =
            fetchRealSessions(); // Fetch real sessions after locale initialization
      });
    }).catchError((error) {
      print("Error initializing locale data: $error");
    });
  }

  String _calculateTimeSpent(String? startDate, String? finishDate) {
    try {
      if (startDate == null ||
          finishDate == null ||
          startDate == "" ||
          finishDate == "") return "N/A";
      final start = DateTime.parse(startDate);
      final finish = DateTime.parse(finishDate);
      final duration = finish.difference(start);
      return "${duration.inHours}h ${duration.inMinutes % 60}m";
    } catch (e) {
      return "N/A"; // Handle invalid date formats
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat("d MMMM yyyy HH:mm", "en_US")
          .format(parsedDate); // Use English locale for month names
    } catch (e) {
      print("Error parsing date: $e");
      return "N/A"; // Handle invalid date formats
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Session History"),
      ),
      body: FutureBuilder<List<RealSession>>(
        future: _realSessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final sessions = snapshot.data!;
            if (sessions.isEmpty) {
              return const Center(child: Text("No session history available."));
            }
            return ListView.builder(
              itemCount: sessions
                  .where((session) => session.finishDate != null)
                  .length,
              itemBuilder: (context, index) {
                final session = sessions
                    .where((session) => session.finishDate != null)
                    .toList()[index];
                return ListTile(
                  title: Text(session.name ?? "Unnamed Session"),
                  subtitle: Text(
                    "Started: ${_formatDate(session.startDate)}\n"
                    "Time Spent: ${_calculateTimeSpent(session.startDate, session.finishDate)}",
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SessionDetailsPage(session: session),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("No session history available."));
          }
        },
      ),
    );
  }
}
