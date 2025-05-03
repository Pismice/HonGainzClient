import 'package:fronte/auth/helper.dart';
import 'package:fronte/globals.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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

Future<List<TemplateExercise>> fetchTemplateExercises(
    BuildContext context) async {
  var url = Uri.parse("${baseUrl}auth/template-exercises"); // API endpoint

  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });

    if (response.statusCode == 200) {
      var data = convert.json.decode(response.body);
      if (data.containsKey("template_exercises") &&
          data["template_exercises"] != null) {
        List<dynamic> exercisesJson = data["template_exercises"];
        return exercisesJson.map((e) => TemplateExercise.fromJson(e)).toList();
      } else {
        return []; // Return an empty list if "template_exercises" is null
      }
    } else {
      final error = convert.json.decode(response.body)['error'];
      if (error == "Invalid session") {
        navigateToLogin(context);
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception(
          'Failed to fetch template exercises: $error'); // General error
    }
  } catch (e) {
    throw Exception(
        'Error fetching template exercises: $e'); // Propagate the error
  }
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
