import 'package:flutter/material.dart';
import 'exercise_list.dart';
import 'new_exercise_page.dart';

class ExerciseManagementPage extends StatefulWidget {
  const ExerciseManagementPage({super.key});

  @override
  State<ExerciseManagementPage> createState() => _ExerciseManagementPageState();
}

class _ExerciseManagementPageState extends State<ExerciseManagementPage> {
  final GlobalKey<ExerciseListState> _exerciseListKey = GlobalKey();

  void _navigateToNewExercisePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewExercisePage(),
      ),
    );

    if (result == true) {
      // Refresh the ExerciseList when a new exercise is created
      _exerciseListKey.currentState?.refreshExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage exercises"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ExerciseList(key: _exerciseListKey), // Pass the key
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewExercisePage,
        child: const Icon(Icons.add),
      ),
    );
  }
}


