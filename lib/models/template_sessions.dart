import 'package:fronte/globals.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class TemplateSession {
  final int id;
  final String name;
  final List<int> exerciseIds;

  TemplateSession(
      {required this.id, required this.name, required this.exerciseIds});
}

Future<List<TemplateSession>> fetchTemplateSessions() async {
  var url = Uri.parse("${baseUrl}auth/template-sessions"); // API endpoint
  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });

    if (response.statusCode == 200) {
      var data = convert.json.decode(response.body);
      if (data.containsKey("template_sessions")) {
        List<dynamic> sessionsJson = data["template_sessions"];
        return sessionsJson
            .map((s) => TemplateSession(
                  id: s["id"],
                  name: s["name"],
                  exerciseIds: List<int>.from(s["exercise_ids"] ?? []),
                ))
            .toList();
      }
    } else {
      final error = convert.json.decode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception(
          'Failed to fetch template sessions: $error'); // General error
    }
  } catch (e) {
    throw Exception(
        'Error fetching template sessions: $e'); // Propagate the error
  }
  return [];
}

Future<void> modifySession(int id, String newName) async {
  var url = Uri.parse("${baseUrl}auth/template-sessions/$id"); // API endpoint
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
      print('Session modified successfully');
    } else {
      final error = convert.json.decode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception('Failed to modify session: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error modifying session: $e'); // Propagate the error
  }
}

Future<void> deleteSession(int id) async {
  var url = Uri.parse("${baseUrl}auth/template-sessions/$id"); // API endpoint
  try {
    var response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${await storage.read(key: "session_id")}"
      },
    );

    if (response.statusCode == 200) {
      print('Session deleted successfully');
    } else {
      final error = convert.json.decode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception('Failed to delete session: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error deleting session: $e'); // Propagate the error
  }
}
