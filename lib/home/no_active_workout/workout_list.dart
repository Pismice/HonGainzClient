import 'package:flutter/material.dart';
import 'package:fronte/globals.dart';
import 'package:fronte/models/template_workouts.dart';
import 'package:http/http.dart' as http; // Add this import
import 'dart:convert'; // Add this import for JSON encoding

class WorkoutList extends StatefulWidget {
  final VoidCallback onWorkoutSet; // Add a callback to notify parent

  const WorkoutList({super.key, required this.onWorkoutSet});

  @override
  WorkoutListState createState() => WorkoutListState();
}

class WorkoutListState extends State<WorkoutList> {
  late Future<List<TemplateWorkout>> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = fetchTemplateWorkouts();
  }

  void refreshWorkouts() {
    setState(() {
      _workoutsFuture = fetchTemplateWorkouts();
    });
  }

  void setActiveWorkout(int workoutId) async {
    var url = Uri.parse('${baseUrl}auth/active-workout');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
        body: jsonEncode({'workout_id': workoutId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Active workout set successfully')),
        );
        widget.onWorkoutSet(); // Notify parent to refresh
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TemplateWorkout>>(
      future: _workoutsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final workouts = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return ListTile(
                title: Text(workout.name),
                subtitle: Text('ID: ${workout.id}'),
                onTap: () {
                  setActiveWorkout(workout.id); // Call the function on tap
                },
              );
            },
          );
        } else {
          return const Text('No workouts found.');
        }
      },
    );
  }
}
