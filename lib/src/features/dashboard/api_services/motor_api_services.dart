import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_iot_app/src/core/exceptions/app_error.dart';
import 'package:smart_iot_app/src/core/exceptions/app_exception.dart';
import '../model/motor_on_off_model.dart';


class MotorApiService {
  final String baseUrl;

  MotorApiService({
    required this.baseUrl,
  });

  Future<MotorOnOffModel> sendCommand({
    required int deviceId,
    required String command, // start / stop
  }) async {
    try {
      final url =
          "$baseUrl/send_command.php?device_id=$deviceId&command_name=$command";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return MotorOnOffModel.fromMap(data);
      } else {
        throw AppError(
          message: "Server error",
          code: "HTTP_ERROR",
        );
      }
    } catch (e) {
      throw AppError(
        message: "Server error",
        code: "HTTP_ERROR",
      );
    }
  }
}