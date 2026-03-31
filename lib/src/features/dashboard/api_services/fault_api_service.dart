import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/fault_model.dart';

class FaultApiService {
  static const String baseUrl =
      "http://178.128.107.36/get_fault_history.php";

  Future<List<FaultModel>> fetchFaults(int deviceId) async {
    final response = await http.get(
      Uri.parse("$baseUrl?device_id=$deviceId&limit=100"),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => FaultModel.fromMap(e)).toList();
    } else {
      throw Exception("Failed to load faults");
    }
  }
}