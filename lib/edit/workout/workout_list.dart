import 'package:flutter/material.dart';
import 'package:fronte/models/template_workouts.dart';

import 'modify_workout_page.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({super.key});

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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModifyWorkoutPage(
                              workoutId: workout.id,
                              initialName: workout.name,
                              initialSessionIds: workout.sessionIds,
                            ),
                          ),
                        );
                        if (result == true) {
                          refreshWorkouts(); // Refresh the list after modification
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Confirm deletion and delete workout
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Workout'),
                              content: const Text(
                                  'Are you sure you want to delete this workout?'),
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
                          await deleteWorkout(workout.id);
                          refreshWorkouts();
                        }
                      },
                    ),
                  ],
                ),
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
