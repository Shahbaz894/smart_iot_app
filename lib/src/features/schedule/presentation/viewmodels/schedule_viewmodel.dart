import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../../core/error/app_exception.dart";
import "../../data/models/schedule_model.dart";
import "../../data/repositories/schedule_repository.dart";
import "../state/schedule_state.dart";

class ScheduleViewModel extends StateNotifier<ScheduleState> {
  final ScheduleRepository scheduleRepository;

  ScheduleViewModel({
    required this.scheduleRepository,
  }) : super(const ScheduleState());
  Future<void> loadSchedule(String deviceId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final schedule = await scheduleRepository.getSchedule(deviceId: deviceId);

      state = state.copyWith(
        isLoading: false,
        schedule: schedule,
        error: null,
        message: null,
      );
    } on AppException catch (e) {
      final text = e.message.toLowerCase();

      if (text.contains("404") ||
          text.contains("not found") ||
          text.contains("no schedule")) {
        state = state.copyWith(
          isLoading: false,
          schedule: null,
          error: null,
          message: null,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to load schedule: ${e.toString()}",
      );
    }
  }

  Future<void> createSchedule(ScheduleModel schedule) async {
    await saveSchedule(schedule);
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    await saveSchedule(schedule);
  }

  Future<void> saveSchedule(ScheduleModel schedule) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final saved = await scheduleRepository.saveSchedule(schedule: schedule);

      state = state.copyWith(
        isLoading: false,
        schedule: saved,
        error: null,
        message: "Schedule saved successfully",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to save schedule: ${e.toString()}",
      );
    }
  }

  Future<void> deleteSchedule(String deviceId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      await scheduleRepository.deleteSchedule(deviceId: deviceId);

      state = state.copyWith(
        isLoading: false,
        schedule: null,
        error: null,
        message: "Schedule deleted successfully",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to delete schedule: ${e.toString()}",
      );
    }
  }
}