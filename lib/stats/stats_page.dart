import 'package:flutter/material.dart';
import 'package:fronte/models/template_exercises.dart';
import 'package:fronte/stats/template_exercise_chart_page.dart';

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
    _templateExercisesFuture = fetchTemplateExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stats"),
      ),
      body: FutureBuilder<List<TemplateExercise>>(
        future: _templateExercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final exercises = snapshot.data!;
            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  title: Text(exercise.name),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TemplateExerciseChartPage(
                          templateExerciseID: exercise.id,
                          exerciseName: exercise.name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("No exercises available."));
          }
        },
      ),
    );
  }
}
