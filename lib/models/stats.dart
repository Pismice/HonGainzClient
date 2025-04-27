import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fronte/globals.dart';

Future<int?> fetchMaxWeight(int templateExerciseID) async {
  var url = Uri.parse(
      '${baseUrl}auth/stats/max-weight/$templateExerciseID'); // Updated to use Uri.parse
  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await storage.read(key: "session_id")}"
    });
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data["max_weight"] as int?;
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
      return (data["weights"] as List).map((weight) => weight as int).toList();
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
