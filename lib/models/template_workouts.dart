import 'package:fronte/globals.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class TemplateWorkout {
  final int id;
  final String name;
  final List<int> sessionIds;

  TemplateWorkout(
      {required this.id, required this.name, required this.sessionIds});
}

Future<List<TemplateWorkout>> fetchTemplateWorkouts() async {
  var url = Uri.parse("${baseUrl}auth/template-workouts"); // API endpoint
  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });
    print(response.body);

    if (response.statusCode == 200) {
      var data = convert.json.decode(response.body);
      if (data.containsKey("template_workouts") &&
          data["template_workouts"] != null) {
        List<dynamic> workoutsJson = data["template_workouts"];
        return workoutsJson.map((w) {
          List<int> sessionIds = List<int>.from(w["session_ids"] ?? []);
          return TemplateWorkout(
            id: w["id"],
            name: w["name"],
            sessionIds: sessionIds,
          );
        }).toList();
      } else {
        return []; // Return an empty list if "template_workouts" is null
      }
    } else {
      final error = convert.json.decode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception(
          'Failed to fetch template workouts: $error'); // General error
    }
  } catch (e) {
    throw Exception(
        'Error fetching template workouts: $e'); // Propagate the error
  }
}

Future<void> deleteWorkout(int id) async {
  var url = Uri.parse("${baseUrl}auth/template-workouts/$id"); // API endpoint
  try {
    var response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${await storage.read(key: "session_id")}"
      },
    );

    if (response.statusCode == 200) {
      print('Workout deleted successfully');
    } else {
      final error = convert.json.decode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception('Failed to delete workout: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error deleting workout: $e'); // Propagate the error
  }
}
