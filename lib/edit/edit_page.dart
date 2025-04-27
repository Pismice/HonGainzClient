import 'package:flutter/material.dart';

import 'exercise/exercise_management_page.dart';
import 'workout/workout_management_page.dart';
import 'session/session_management_page.dart';

class EditPage extends StatelessWidget {
  const EditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit your templates"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity, // Full width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WorkoutManagementPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // No rounded corners
                  ),
                ),
                child: const Text("Manage Workouts"),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SizedBox(
              width: double.infinity, // Full width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SessionManagementPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // No rounded corners
                  ),
                ),
                child: const Text("Manage Sessions"),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SizedBox(
              width: double.infinity, // Full width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExerciseManagementPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // No rounded corners
                  ),
                ),
                child: const Text("Manage Exercises"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
