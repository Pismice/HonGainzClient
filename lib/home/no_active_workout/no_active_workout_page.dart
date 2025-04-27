import 'package:flutter/material.dart';
import 'workout_list.dart';

class NoActiveWorkoutPage extends StatelessWidget {
  final VoidCallback onWorkoutSet;

  const NoActiveWorkoutPage({
    super.key,
    required this.onWorkoutSet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No active workout available. Please select a workout:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: WorkoutList(onWorkoutSet: onWorkoutSet), // Use WorkoutList
        ),
      ],
    );
  }
}
