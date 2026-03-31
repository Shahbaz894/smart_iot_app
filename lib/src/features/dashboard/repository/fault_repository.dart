import 'package:smart_iot_app/src/features/dashboard/api_services/fault_api_service.dart';

import '../model/fault_model.dart';


class FaultRepository {
  final FaultApiService apiService;

  FaultRepository(this.apiService);

  Future<List<FaultModel>> getFaultHistory(int deviceId) {
    return apiService.fetchFaults(deviceId);
  }
}