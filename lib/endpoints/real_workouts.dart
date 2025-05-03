import 'dart:convert';

import 'package:fronte/globals.dart';
import 'package:fronte/endpoints/real_sessions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class RealWorkout {
  final int id;
  final String? name;
  final String? startDate;
  final int? finishDate;
  final int templateWorkoutId;
  final int userId;

  List<RealSession> sessions = [];

  RealWorkout({
    required this.id,
    this.name,
    this.startDate,
    this.finishDate,
    required this.templateWorkoutId,
    required this.userId,
  });

  // Factory constructor to create a RealWorkout from JSON
  factory RealWorkout.fromJson(Map<String, dynamic> json) {
    return RealWorkout(
      id: json['id'],
      startDate: json['start_date'],
      finishDate: json['finish_date'],
      templateWorkoutId: json['template_workout_id'],
      userId: json['user_id'],
    );
  }

  // Method to convert a RealWorkout to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate,
      'finish_date': finishDate,
      'template_workout_id': templateWorkoutId,
      'user_id': userId,
    };
  }
}

Future<Map<String, dynamic>?> fetchActiveWorkout() async {
  var url = Uri.parse("${baseUrl}auth/active-workout"); // API endpoint
  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });
    if (response.statusCode == 200) {
      var data = convert.json.decode(response.body);
      return data["active_workout"];
    }
  } catch (e) {
    print('Error fetching active workout: $e');
  }
  return null;
}

Future<void> createRealSessions(int realWorkoutId) async {
  var url = Uri.parse("${baseUrl}auth/new-sessions"); // API endpoint
  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${await storage.read(key: "session_id")}"
      },
      body: jsonEncode({'real_workout_id': realWorkoutId}),
    );

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      final error = jsonDecode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception(
          'Failed to create real sessions: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error creating real sessions: $e'); // Propagate the error
  }
}

Future<RealWorkout?> fetchActiveRealWorkout() async {
  var url = Uri.parse("${baseUrl}auth/active-workout"); // API endpoint
  try {
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });

    if (response.statusCode == 200) {
      var data = convert.json.decode(response.body);
      var activeWorkout = data["active_workout"];
      if (activeWorkout != null) {
        List<RealSession> sessions =
            (activeWorkout["sessions"] as List<dynamic>)
                .map((session) => RealSession(
                      id: session["id"],
                      name: session["name"],
                      startDate: session["start_date"],
                      finishDate: session["finish_date"],
                    ))
                .toList();

        var workout = RealWorkout.fromJson(activeWorkout);
        workout.sessions = sessions;
        return workout;
      }
    } else {
      final error = jsonDecode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception(
          'Failed to fetch active real workout: $error'); // General error
    }
  } catch (e) {
    throw Exception(
        'Error fetching active real workout: $e'); // Propagate the error
  }
  return null;
}
