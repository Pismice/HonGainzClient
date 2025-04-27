import 'package:flutter/material.dart';
import 'package:fronte/models/template_exercises.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({super.key});

  @override
  ExerciseListState createState() => ExerciseListState();
}

class ExerciseListState extends State<ExerciseList> {
  late Future<List<TemplateExercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = fetchTemplateExercises();
  }

  void refreshExercises() {
    setState(() {
      _exercisesFuture = fetchTemplateExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TemplateExercise>>(
      future: _exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final exercises = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ListTile(
                title: Text(exercise.name),
                subtitle: Text('ID: ${exercise.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        // Prompt user for new name and modify exercise
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            String tempName = exercise.name;
                            return AlertDialog(
                              title: const Text('Modify Exercise'),
                              content: TextField(
                                onChanged: (value) => tempName = value,
                                controller:
                                    TextEditingController(text: exercise.name),
                                decoration: const InputDecoration(
                                    labelText: 'New Name'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, null),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, tempName),
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                        if (newName != null && newName.isNotEmpty) {
                          await modifyExercise(exercise.id, newName);
                          refreshExercises();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Confirm deletion and delete exercise
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Exercise'),
                              content: const Text(
                                  'Are you sure you want to delete this exercise?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          await deleteExercise(exercise.id);
                          refreshExercises();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Text('No exercises found.');
        }
      },
    );
  }
}
