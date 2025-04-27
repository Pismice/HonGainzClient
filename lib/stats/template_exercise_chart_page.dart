import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fronte/models/stats.dart';

class TemplateExerciseChartPage extends StatefulWidget {
  final int templateExerciseID;
  final String exerciseName;

  const TemplateExerciseChartPage({
    super.key,
    required this.templateExerciseID,
    required this.exerciseName,
  });

  @override
  State<TemplateExerciseChartPage> createState() =>
      _TemplateExerciseChartPageState();
}

class _TemplateExerciseChartPageState extends State<TemplateExerciseChartPage> {
  late Future<List<int>> _weightsFuture;

  @override
  void initState() {
    super.initState();
    _weightsFuture = fetchAllWeights(widget.templateExerciseID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: FutureBuilder<List<int>>(
        future: _weightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final weights = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: weights
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                              entry.key.toDouble(), entry.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  borderData: FlBorderData(show: true),
                  gridData: const FlGridData(show: true),
                ),
              ),
            );
          } else {
            return const Center(child: Text("No data available."));
          }
        },
      ),
    );
  }
}
