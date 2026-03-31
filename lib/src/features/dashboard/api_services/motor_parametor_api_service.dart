import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_iot_app/src/features/dashboard/model/motor_parameter.dart';


class MotorParameterApiService {
  final String baseUrl = "http://178.128.107.36";

  Future<MotorParameter> fetchMotorParameter(int deviceId) async {
    final url = Uri.parse("$baseUrl/get_latest.php?device_id=$deviceId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MotorParameter.fromMap(data);
    } else {
      throw Exception("Failed to load motor parameter");
    }
  }
}