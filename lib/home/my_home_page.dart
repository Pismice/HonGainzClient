import 'package:flutter/material.dart';
import 'package:fronte/models/real_sessions.dart';
import 'package:fronte/models/real_workouts.dart';
import '../settings/settings_page.dart'; // Import SettingsPage
import 'active_workout/doing_workout_page.dart'; // Import ActiveWorkoutPage
import 'no_active_workout/no_active_workout_page.dart'; // Import NoActiveWorkoutPage

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Map<String, dynamic>?> _activeWorkoutFuture;

  @override
  void initState() {
    super.initState();
    _activeWorkoutFuture = fetchActiveWorkout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _activeWorkoutFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final activeWorkout = snapshot.data;
            if (activeWorkout == null) {
              return NoActiveWorkoutPage(
                onWorkoutSet: () {
                  setState(() {
                    _activeWorkoutFuture =
                        fetchActiveWorkout(); // Refresh active workout
                  });
                },
              ); // Use NoActiveWorkoutPage widget
            } else {
              final workoutName = activeWorkout["name"];
              final sessions =
                  (activeWorkout["sessions"] as List<dynamic>? ?? [])
                      .map((session) => RealSession(
                            id: session["id"],
                            name: session["name"],
                            startDate: session["start_date"],
                            finishDate: session["finish_date"],
                          ))
                      .toList(); // Cast to List<Session>
              return ActiveWorkoutPage(
                realWorkoutId: activeWorkout["id"],
                workoutName: workoutName,
                sessions: sessions,
                onDeactivate: () {
                  setState(() {
                    _activeWorkoutFuture =
                        fetchActiveWorkout(); // Refresh active workout
                  });
                },
              ); // Use ActiveWorkoutPage widget
            }
          }
        },
      ),
    );
  }
}
