import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fronte/globals.dart';

class RealExercise {
  final int id;
  final String name;
  final int? templateExerciseId;
  final int? realSessionId;
  final int? userId;
  String? startDate; // Add startDate field
  String? finishDate; // Add finishDate field

  RealExercise({
    required this.id,
    this.name = '',
    this.templateExerciseId,
    this.realSessionId,
    this.userId,
    this.startDate, // Initialize startDate
    this.finishDate, // Initialize finishDate
  });

  // Factory constructor to create a RealExercise from JSON
  factory RealExercise.fromJson(Map<String, dynamic> json) {
    return RealExercise(
      id: json['id'],
      templateExerciseId: json['template_exercise_id'],
      realSessionId: json['real_session_id'],
      userId: json['user_id'],
      startDate: json['start_date'], // Parse startDate
      finishDate: json['finish_date'], // Parse finishDate
    );
  }

  // Method to convert a RealExercise to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_exercise_id': templateExerciseId,
      'real_session_id': realSessionId,
      'user_id': userId,
      'start_date': startDate, // Include startDate
      'finish_date': finishDate, // Include finishDate
    };
  }

  Future<void> registerSet({
    required int reps,
    required double weight,
  }) async {
    var url = Uri.parse("${baseUrl}auth/register-set"); // API endpoint
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
        body: jsonEncode({
          "real_exercise_id": id,
          "reps": reps,
          "weight": weight,
        }),
      );

      if (response.statusCode == 200) {
        print('Set registered successfully');
      } else {
        final error = jsonDecode(response.body)['error'];
        if (error == "Invalid session") {
          throw Exception("InvalidSessionError"); // Specific error
        }
        throw Exception('Failed to register set: $error'); // General error
      }
    } catch (e) {
      throw Exception('Error registering set: $e'); // Propagate the error
    }
  }

  Future<void> finishExercise() async {
    var url = Uri.parse("${baseUrl}auth/finish-exercise/$id"); // API endpoint
    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
      );

      if (response.statusCode == 200) {
        print('Exercise finished successfully');
      } else {
        final error = jsonDecode(response.body)['error'];
        if (error == "Invalid session") {
          throw Exception("InvalidSessionError"); // Specific error
        }
        throw Exception('Failed to finish exercise: $error'); // General error
      }
    } catch (e) {
      throw Exception('Error finishing exercise: $e'); // Propagate the error
    }
  }

  Future<int> getRealSetsCount() async {
    var url = Uri.parse("${baseUrl}auth/real-sets/count/$id"); // API endpoint
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${await storage.read(key: "session_id")}"
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['real_sets_count']; // Return the count
      } else {
        final error = jsonDecode(response.body)['error'];
        if (error == "Invalid session") {
          throw Exception("InvalidSessionError"); // Specific error
        }
        throw Exception(
            'Failed to fetch real sets count: $error'); // General error
      }
    } catch (e) {
      throw Exception(
          'Error fetching real sets count: $e'); // Propagate the error
    }
  }
}
