import 'package:flutter/material.dart';
import 'package:fronte/endpoints/real_sessions.dart';
import 'package:fronte/endpoints/real_workouts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fronte/globals.dart';
import 'session_list.dart'; // Import SessionList

class ActiveWorkoutPage extends StatefulWidget {
  final String workoutName;
  final List<RealSession> sessions;
  final VoidCallback onDeactivate;
  final int realWorkoutId;

  const ActiveWorkoutPage({
    super.key,
    required this.workoutName,
    required this.sessions,
    required this.onDeactivate,
    required this.realWorkoutId,
  });

  @override
  _ActiveWorkoutPageState createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends State<ActiveWorkoutPage> with RouteAware {
  late List<RealSession> _sessions;
  late bool _allSessionsFinished; // Add to state

  @override
  void initState() {
    super.initState();
    _sessions = List.from(widget.sessions); // Initialize with provided sessions
    _updateAllSessionsFinished(); // Initialize _allSessionsFinished
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this widget with the RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unregister from the RouteObserver
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this page
    fetchActiveRealWorkout().then((updatedWorkout) {
      if (updatedWorkout != null) {
        setState(() {
          _sessions = updatedWorkout.sessions; // Update sessions
          _updateAllSessionsFinished(); // Refresh state
        });
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching workout: $e')),
      );
    });
  }

  void _updateAllSessionsFinished() {
    _allSessionsFinished =
        _sessions.every((session) => session.finishDate != null);
  }

  Future<void> _createRealSessions(BuildContext context) async {
    try {
      await createRealSessions(widget.realWorkoutId); // Call createRealSessions
      final updatedWorkout =
          await fetchActiveRealWorkout(); // Fetch updated workout
      if (updatedWorkout != null) {
        setState(() {
          _sessions = updatedWorkout.sessions; // Update sessions
          _updateAllSessionsFinished(); // Update _allSessionsFinished
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Real sessions created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void deactivateWorkout(BuildContext context) async {
    var url = Uri.parse('${baseUrl}auth/active-workout');
    try {
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Active workout deactivated successfully')),
        );
        widget.onDeactivate(); // Notify parent to refresh
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print('Error deactivating workout: $e');
    }
  }

  void _showChangeWorkoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm workout change"),
          content: const Text(
              "Are you sure you want to change the current workout and active an other ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                deactivateWorkout(context); // Proceed with action
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.workoutName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold, // Bold workoutName
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: "Change workout",
                    onPressed: () => _showChangeWorkoutConfirmation(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SessionList(
                sessions: _sessions, // Use updated sessions
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed:
              _allSessionsFinished ? () => _createRealSessions(context) : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(100), // Increased height
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // No rounded corners
            ),
          ),
          child: const Text("Finish this week !"),
        ),
      ),
    );
  }
}
