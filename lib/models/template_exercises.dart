import 'package:fronte/globals.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class TemplateExercise {
  final int id;
  final String name;

  TemplateExercise({
    required this.id,
    required this.name,
  });

  factory TemplateExercise.fromJson(Map<String, dynamic> json) {
    return TemplateExercise(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

Future<List<TemplateExercise>> fetchTemplateExercises() async {
  var url = Uri.parse("${baseUrl}auth/template-exercises"); // API endpoint

  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });

    if (response.statusCode == 200) {
      var data = convert.json.decode(response.body);
      if (data.containsKey("template_exercises")) {
        List<dynamic> exercisesJson = data["template_exercises"];
        return exercisesJson.map((e) => TemplateExercise.fromJson(e)).toList();
      }
    }
  } catch (e) {
    print('Error fetching template exercises: $e');
  }
  return [];
}

Future<void> modifyExercise(int id, String newName) async {
  var url = Uri.parse("${baseUrl}auth/template-exercises/$id"); // API endpoint
  try {
    var response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${await storage.read(key: "session_id")}"
      },
      body: convert.json.encode({"name": newName}),
    );

    if (response.statusCode == 200) {
      print('Exercise modified successfully');
    } else {
      print('Failed to modify exercise: ${response.body}');
    }
  } catch (e) {
    print('Error modifying exercise: $e');
  }
}

Future<void> deleteExercise(int id) async {
  var url = Uri.parse("${baseUrl}auth/template-exercises/$id"); // API endpoint
  try {
    var response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${await storage.read(key: "session_id")}"
      },
    );

    if (response.statusCode == 200) {
      print('Exercise deleted successfully');
    } else {
      print('Failed to delete exercise: ${response.body}');
    }
  } catch (e) {
    print('Error deleting exercise: $e');
  }
}
