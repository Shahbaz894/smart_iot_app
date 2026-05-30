import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../../core/error/app_exception.dart";
import "../../data/repositories/vfd_repository.dart";
import "../state/vfd_state.dart";

class VfdViewModel extends StateNotifier<VfdState> {
  final VfdRepository vfdRepository;

  VfdViewModel({
    required this.vfdRepository,
  }) : super(const VfdState());

  Future<void> resetVfd(String deviceId) async {
    try {
      state = state.copyWith(isLoading: true, error: null, message: null);

      await vfdRepository.reset(deviceId: deviceId);

      state = state.copyWith(
        isLoading: false,
        message: "VFD reset command sent",
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: "Failed to reset VFD");
    }
  }

  Future<void> setFrequency({
    required String deviceId,
    required double frequency,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null, message: null);

      await vfdRepository.setReferenceFrequency(
        deviceId: deviceId,
        frequency: frequency,
      );

      state = state.copyWith(
        isLoading: false,
        message: "Reference frequency updated",
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to update reference frequency",
      );
    }
  }
}