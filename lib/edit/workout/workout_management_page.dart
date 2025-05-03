import 'package:flutter/material.dart';
import 'workout_list.dart';
import 'new_workout_page.dart';

class WorkoutManagementPage extends StatefulWidget {
  const WorkoutManagementPage({super.key});

  @override
  State<WorkoutManagementPage> createState() => _WorkoutManagementPageState();
}

class _WorkoutManagementPageState extends State<WorkoutManagementPage> {
  final GlobalKey<WorkoutListState> _workoutListKey = GlobalKey();

  void _navigateToNewWorkoutPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewWorkoutPage(),
      ),
    );

    if (result == true) {
      // Refresh the WorkoutList when a new workout is created
      _workoutListKey.currentState?.refreshWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Workouts"),
      ),
      body: Column(
        children: [
          Expanded(
            child: WorkoutList(key: _workoutListKey), // Pass the key
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 100, // Increase the width of the button
        height: 100, // Increase the height of the button
        child: FloatingActionButton(
          onPressed: _navigateToNewWorkoutPage,
          backgroundColor: Colors.green, // Make the button green
          child: const Icon(
            Icons.add,
            size: 50, // Adjust the icon size
          ),
        ),
      ),
    );
  }
}
