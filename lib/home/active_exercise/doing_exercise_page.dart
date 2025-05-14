import 'package:flutter/material.dart';
import 'package:fronte/endpoints/real_exercises.dart';
import 'package:fronte/endpoints/stats.dart'; // Import fetchMaxWeight
import 'package:confetti/confetti.dart'; // Import Confetti package
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

class DoingExercisePage extends StatefulWidget {
  final RealExercise exercise;

  const DoingExercisePage({super.key, required this.exercise});

  @override
  _DoingExercisePageState createState() => _DoingExercisePageState();
}

class _DoingExercisePageState extends State<DoingExercisePage> {
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  int setCount = 0; // Counter for the number of sets submitted
  late ConfettiController _confettiController; // Confetti controller

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose of the confetti controller
    super.dispose();
  }

  Future<double?> _fetchMaxWeight() async {
    try {
      return await fetchMaxWeight(
          widget.exercise.templateExerciseId ?? 0); // Fetch max weight
    } catch (e) {
      throw Exception('Error fetching max weight: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<double?>(
                future: _fetchMaxWeight(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final maxWeight = snapshot.data;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sets done: $setCount",
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Colors.blue, // Blue text
                              ),
                        ),
                        const SizedBox(height: 32), // Increased spacing
                        TextField(
                          controller: repsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Reps",
                            labelStyle:
                                TextStyle(fontSize: 22.0), // Even larger label
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(
                              fontSize: 22.0), // Even larger input text
                        ),
                        const SizedBox(height: 32), // Increased spacing
                        TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: "Weight",
                            labelStyle:
                                TextStyle(fontSize: 22.0), // Even larger label
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(
                              fontSize: 22.0), // Even larger input text
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+([.,]\d{0,10})?$')),
                          ], // Allow numbers with commas or dots
                        ),
                        const SizedBox(height: 32), // Increased spacing
                        if (maxWeight != null)
                          Text(
                            "Current PR : ${maxWeight.toStringAsFixed(2)} kg",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.purple, // Purple text
                                ),
                          ),
                        const SizedBox(height: 32), // Increased spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final reps = int.tryParse(repsController.text);
                                final weight = double.tryParse(
                                    weightController.text.replaceAll(',', '.'));

                                if (reps == null || weight == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please enter valid numbers for reps and weight')),
                                  );
                                  return;
                                }

                                try {
                                  await widget.exercise.registerSet(
                                      reps: reps,
                                      weight: weight); // Trigger registerSet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Set registered successfully')),
                                  );
                                  setState(() {
                                    setCount++; // Increment the set count
                                  });
                                  _confettiController
                                      .play(); // Trigger confetti
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0, // Even larger button height
                                  horizontal: 40.0, // Even larger button width
                                ),
                                textStyle: const TextStyle(
                                    fontSize: 22.0), // Even larger text
                              ),
                              child: const Text("Register set"),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              blastDirectionality: BlastDirectionality.explosive,
              confettiController: _confettiController,
              blastDirection: -3.14 / 2, // Blast upwards
              emissionFrequency: 0.2,
              numberOfParticles: 40,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.6,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(0), // Remove padding for full width
        child: ElevatedButton(
          onPressed: () async {
            try {
              await widget.exercise.finishExercise(); // Trigger finishExercise
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exercise finished successfully')),
              );
              Navigator.pop(context, true); // Navigate back
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Green button
            minimumSize: const Size.fromHeight(100), // Increased height
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // No rounded corners
            ),
          ),
          child: const Text(
            "Finish exercise",
            style: TextStyle(fontSize: 30.0), // Even larger text
          ),
        ),
      ),
    );
  }
}
