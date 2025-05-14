import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fronte/globals.dart';
import 'package:fronte/endpoints/real_sessions.dart'; // Import RealSession model

Future<double?> fetchMaxWeight(int templateExerciseID) async {
  var url = Uri.parse(
      '${baseUrl}auth/stats/max-weight/$templateExerciseID'); // Updated to use Uri.parse
  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return (data["max_weight"] as num?)?.toDouble(); // Convert to double
    } else {
      final error = json.decode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception('Failed to fetch max weight: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error fetching max weight: $e'); // Propagate the error
  }
}

Future<List<int>> fetchAllWeights(int templateExerciseID) async {
  var url = Uri.parse(
      '${baseUrl}auth/stats/all-weights/$templateExerciseID'); // Updated to use Uri.parse
  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data["weights"] != null) {
        return (data["weights"] as List)
            .map((weight) => weight as int)
            .toList();
      } else {
        return []; // Return an empty list if "weights" is null
      }
    } else {
      final error = json.decode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception('Failed to fetch all weights: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error fetching all weights: $e'); // Propagate the error
  }
}

Future<List<RealSession>> fetchRealSessions() async {
  var url = Uri.parse('${baseUrl}auth/stats/real-sessions'); // API endpoint
  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data.containsKey("real_sessions") && data["real_sessions"] != null) {
        return (data["real_sessions"] as List)
            .map((session) => RealSession.fromJson(session))
            .toList();
      } else {
        return []; // Return an empty list if "real_sessions" is null
      }
    } else {
      final error = json.decode(response.body)['error'];
      if (error == "Invalid session") {
        throw Exception("InvalidSessionError"); // Specific error
      }
      throw Exception('Failed to fetch real sessions: $error'); // General error
    }
  } catch (e) {
    throw Exception('Error fetching real sessions: $e'); // Propagate the error
  }
}
