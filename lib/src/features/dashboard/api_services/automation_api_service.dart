import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/schedule_model.dart';

class AutomationApiService {
  final String baseUrl = "http://178.128.107.36";

  Future<List<ScheduleModel>> getSchedules(int deviceId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_schedules.php?device_id=$deviceId"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ScheduleModel.fromMap(e)).toList();
    } else {
      throw Exception("Failed to fetch schedules");
    }
  }
}