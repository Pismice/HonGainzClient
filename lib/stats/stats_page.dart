import 'package:flutter/material.dart';
import 'package:fronte/endpoints/template_exercises.dart';
import 'package:fronte/stats/exercises_pr_page.dart';
import 'package:fronte/stats/session_history_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late Future<List<TemplateExercise>> _templateExercisesFuture;

  @override
  void initState() {
    super.initState();
    _templateExercisesFuture = fetchTemplateExercises(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stats"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const ExercisesPRPage(), // Navigate to the exercises screen
                  ),
                );
              },
              child: const Text(
                "View the progress of your exercises",
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16), // Add spacing between buttons
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const SessionHistoryPage(), // Navigate to the session history screen
                  ),
                );
              },
              child: const Text(
                "View your session history",
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
