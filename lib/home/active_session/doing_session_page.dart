import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:fronte/home/active_exercise/doing_exercise_page.dart'; // Import DoingExercisePage
import 'package:fronte/models/real_exercises.dart'; // Import RealExercise model
import 'package:fronte/models/real_sessions.dart';

class DoingSession extends StatefulWidget {
  final RealSession session;

  const DoingSession({super.key, required this.session});

  @override
  _DoingSessionState createState() => _DoingSessionState();
}

class _DoingSessionState extends State<DoingSession> {
  Timer? _timer;
  int _elapsedSeconds = -1;
  List<RealExercise> _exercises = []; // List of exercises

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.session.startDate != null && widget.session.finishDate != null) {
      // Calculate the difference between start and finish dates
      final startDate = DateTime.parse(widget.session.startDate!);
      final finishDate = DateTime.parse(widget.session.finishDate!);
      _elapsedSeconds = finishDate.difference(startDate).inSeconds;
    } else if (widget.session.startDate != null &&
        widget.session.finishDate == null) {
      // Automatically continue the timer if the session has a start date but no finish date
      final startDate = DateTime.parse(widget.session.startDate!);
      _elapsedSeconds = DateTime.now().difference(startDate).inSeconds;
      _startTimerWithoutReset(); // Start the timer without resetting elapsed time
    }
    _fetchExercises(); // Fetch exercises and populate the list
  }

  Future<void> _fetchExercises() async {
    try {
      final exercises = await fetchRealExercisesForSession(widget.session.id);
      setState(() {
        _exercises = exercises;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching exercises: $e')),
      );
    }
  }

  void _startTimerWithoutReset() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _startTimer() async {
    try {
      if (widget.session.startDate != null) {
        // Use the existing start date to calculate elapsed time
        final startDate = DateTime.parse(widget.session.startDate!);
        _elapsedSeconds = DateTime.now().difference(startDate).inSeconds;
      } else {
        // Set the start date if it doesn't exist
        widget.session.startDate = DateTime.now().toString();
        await startSession(widget.session.id); // Call startSession
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session started successfully')),
        );
        _elapsedSeconds = 0; // Reset elapsed time
      }

      setState(() {}); // Update the UI immediately
      _startTimerWithoutReset(); // Start the timer
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatElapsedTime() {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name ?? "Session"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_exercises.isEmpty)
                const Text('No exercises found.')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      final hasFinished = exercise.finishDate != null;
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey, // Border color
                            width: 1.0, // Border width
                          ),
                          borderRadius: BorderRadius.zero, // No rounded corners
                          color: hasFinished
                              ? Colors.green[900]
                              : null, // Background color
                        ),
                        margin: EdgeInsets.zero, // Remove spacing between items
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0, // Increased vertical padding
                            horizontal: 16.0,
                          ),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(
                                fontSize: 18.0), // Larger font size
                          ),
                          onTap: !hasFinished &&
                                  widget.session.startDate != null
                              ? () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DoingExercisePage(exercise: exercise),
                                    ),
                                  );
                                  // Refresh exercises after returning
                                  _fetchExercises();
                                }
                              : null, // Disable tap if exercise is finished or session is not started
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.session.startDate == null)
              ElevatedButton(
                onPressed: () async {
                  _startTimer(); // Start the session
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(70), // Larger button
                ),
                child: const Text("Start Session"),
              ),
            if (widget.session.startDate != null &&
                widget.session.finishDate == null)
              Text(
                "Elapsed Time: ${_formatElapsedTime()}",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (widget.session.startDate != null &&
                widget.session.finishDate == null)
              const SizedBox(height: 16),
            if (widget.session.startDate != null &&
                widget.session.finishDate == null)
              ElevatedButton(
                onPressed: () async {
                  try {
                    await finishSession(
                        widget.session.id); // Call finishSession
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Session finished successfully')),
                    );
                    Navigator.pop(
                        context, true); // Navigate back and indicate success
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(70), // Larger button
                ),
                child: const Text("Finish Session"),
              ),
          ],
        ),
      ),
    );
  }
}
