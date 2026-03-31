import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/api_services/fault_api_service.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/fault_viewmodel.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/fault_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/fault_repository.dart';


final faultApiServiceProvider = Provider((ref) => FaultApiService());

final faultRepositoryProvider = Provider(
      (ref) => FaultRepository(ref.read(faultApiServiceProvider)),
);

final faultViewModelProvider =
StateNotifierProvider<FaultViewModel, FaultState>((ref) {
  return FaultViewModel(ref.read(faultRepositoryProvider));
});