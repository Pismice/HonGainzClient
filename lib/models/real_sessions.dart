import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fronte/globals.dart';
import 'package:fronte/models/real_exercises.dart'; // Import RealExercise model

class RealSession {
  final int id;
  final String? name;
  final int? templateSessionId;
  final int? realWorkoutId;
  String? startDate;
  final String? finishDate;
  final int? userId;

  RealSession({
    required this.id,
    this.name,
    this.templateSessionId,
    this.realWorkoutId,
    this.startDate,
    this.finishDate,
    this.userId,
  });

  // Factory constructor to create a RealSession from JSON
  factory RealSession.fromJson(Map<String, dynamic> json) {
    return RealSession(
      id: json['id'],
      templateSessionId: json['template_session_id'],
      realWorkoutId: json['real_workout_id'],
      startDate: json['start_date'],
      finishDate: json['finish_date'],
      userId: json['user_id'],
    );
  }

  // Method to convert a RealSession to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_session_id': templateSessionId,
      'real_workout_id': realWorkoutId,
      'start_date': startDate,
      'finish_date': finishDate,
      'user_id': userId,
    };
  }
}

Future<void> startSession(int sessionId) async {
  var url = Uri.parse(
      "${baseUrl}auth/active-session/$sessionId/start"); // API endpoint
  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${await storage.read(key: "session_id")}"
      },
    );

    if (response.statusCode == 200) {
      print('Session started successfully');
    } else {
      final error = jsonDecode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception('Failed to start session: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error starting session: $e'); // Propagate the error
  }
}

Future<void> finishSession(int sessionId) async {
  var url = Uri.parse(
      "${baseUrl}auth/active-session/$sessionId/finish"); // API endpoint
  try {
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer ${await storage.read(key: "session_id")}"
      },
    );

    if (response.statusCode == 200) {
      print('Session finished successfully');
    } else {
      final error = jsonDecode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception('Failed to finish session: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error finishing session: $e'); // Propagate the error
  }
}

Future<List<RealExercise>> fetchRealExercisesForSession(int sessionId) async {
  var url = Uri.parse(
      "${baseUrl}auth/real-session/$sessionId/exercises"); // API endpoint
  try {
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${await storage.read(key: "session_id")}"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['real_exercises'] as List<dynamic>;
      return data
          .map((exercise) => RealExercise(
                id: exercise["id"],
                templateExerciseId: exercise["template_exercise_id"],
                name: exercise["name"], // Add name to RealExercise if needed
                startDate: exercise["start_date"], // Fetch start_date
                finishDate: exercise["finish_date"], // Fetch finish_date
              ))
          .toList();
    } else {
      final error = jsonDecode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception('Failed to fetch exercises: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error fetching exercises: $e'); // Propagate the error
  }
}
