// import "../../../../core/error/app_exception.dart";
// import "../../../motor/data/models/motor_log_response.dart";
// import "../models/khata_entry_model.dart";
// import "../services/khata_api_service.dart";
//
// class KhataRepository {
//   final KhataApiService khataApiService;
//
//   KhataRepository(this.khataApiService);
//
//   Future<List<KhataEntryModel>> getEntries() {
//     return khataApiService.getEntries();
//   }
//
//   Future<KhataEntryModel> createEntry({
//     required KhataEntryModel entry,
//   }) {
//     return khataApiService.createEntry(entry: entry);
//   }
//
//   Future<KhataEntryModel> updateEntry({
//     required KhataEntryModel entry,
//   }) {
//     return khataApiService.updateEntry(entry: entry);
//   }
//
//   Future<KhataEntryModel> addPayment({
//     required String entryId,
//     required double amount,
//     String? note,
//   }) {
//     return khataApiService.addPayment(
//       entryId: entryId,
//       amount: amount,
//       note: note,
//     );
//   }
//
//   Future<void> deleteEntry({
//     required String id,
//   }) {
//     return khataApiService.deleteEntry(id: id);
//   }
//
//   Future<KhataEntryModel> createFromMotorLog({
//     required MotorLogResponse log,
//     required String customerName,
//     required String deviceId,
//     required double pricePerHour,
//     double cashReceived = 0,
//     int fallbackRunSeconds = 0,
//   }) async {
//     final motorLogId = log.id?.trim() ?? "";
//
//     double runHours = _runHoursFromLog(log);
//
//     if (runHours <= 0 && fallbackRunSeconds > 0) {
//       runHours = fallbackRunSeconds / 3600.0;
//     }
//
//     if (runHours <= 0) {
//       runHours = 1 / 3600.0;
//     }
//
//     final totalBill = runHours * pricePerHour;
//     final remainingBalance = totalBill - cashReceived;
//
//     final entry = KhataEntryModel(
//       customerName: customerName.trim().isEmpty
//           ? "Mobile App"
//           : customerName.trim(),
//       deviceId: deviceId,
//       pricePerHour: pricePerHour,
//       motorLogId: motorLogId,
//       cashReceived: cashReceived,
//       date: _dateOnly(log.endTime ?? DateTime.now()),
//       runHours: runHours,
//       totalBill: totalBill,
//       remainingBalance: remainingBalance <= 0 ? 0 : remainingBalance,
//       paymentStatus: _paymentStatus(
//         cashReceived: cashReceived,
//         totalBill: totalBill,
//       ),
//     );
//
//     return khataApiService.createEntry(entry: entry);
//   }
//
//   double _runHoursFromLog(MotorLogResponse log) {
//     final durationMinutes = log.durationMinutes;
//
//     if (durationMinutes != null && durationMinutes > 0) {
//       return durationMinutes / 60.0;
//     }
//
//     final start = log.startTime;
//     final end = log.endTime;
//
//     if (start != null && end != null) {
//       final minutes = end.difference(start).inMinutes;
//
//       if (minutes > 0) {
//         return minutes / 60.0;
//       }
//     }
//
//     return 0;
//   }
//
//   String _dateOnly(DateTime date) {
//     return "${date.year.toString().padLeft(4, "0")}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
//   }
//
//   String _paymentStatus({
//     required double cashReceived,
//     required double totalBill,
//   }) {
//     if (totalBill <= 0) return "unpaid";
//     if (cashReceived >= totalBill) return "paid";
//     if (cashReceived > 0) return "partial";
//     return "unpaid";
//   }
//
//
//   Future<KhataEntryModel> startMotorKhataSession({
//     required String customerName,
//     required String deviceId,
//     required String motorLogId,
//     required DateTime startTime,
//   }) {
//     final entry = KhataEntryModel(
//       customerName: customerName.trim(),
//       deviceId: deviceId,
//       motorLogId: motorLogId,
//       date: _dateOnly(startTime),
//       startTime: startTime,
//       endTime: null,
//       status: "open",
//       runHours: 0,
//       pricePerHour: 0,
//       totalBill: 0,
//       cashReceived: 0,
//       remainingBalance: 0,
//       paymentStatus: "unpaid",
//     );
//
//     return khataApiService.createEntry(entry: entry);
//   }
//
//   Future<KhataEntryModel> closeMotorKhataSession({
//     required KhataEntryModel entry,
//     required DateTime endTime,
//   }) {
//     final startTime = entry.startTime ?? endTime;
//     final seconds = endTime.difference(startTime).inSeconds;
//     final runHours = seconds <= 0 ? 1 / 3600.0 : seconds / 3600.0;
//
//     final updated = entry.copyWith(
//       endTime: endTime,
//       runHours: runHours,
//       status: "closed",
//     );
//
//     return khataApiService.updateEntry(entry: updated);
//   }
// }
import "../../../../core/error/app_exception.dart";
import "../../../motor/data/models/motor_log_response.dart";
import "../models/khata_entry_model.dart";
import "../services/khata_api_service.dart";

class KhataRepository {
  final KhataApiService khataApiService;

  KhataRepository(this.khataApiService);

  Future<List<KhataEntryModel>> getEntries() {
    return khataApiService.getEntries();
  }

  Future<KhataEntryModel> createEntry({
    required KhataEntryModel entry,
  }) {
    return khataApiService.createEntry(entry: entry);
  }

  Future<KhataEntryModel> updateEntry({
    required KhataEntryModel entry,
  }) {
    return khataApiService.updateEntry(entry: entry);
  }

  Future<KhataEntryModel> addPayment({
    required String entryId,
    required double amount,
    String? note,
  }) {
    return khataApiService.addPayment(
      entryId: entryId,
      amount: amount,
      note: note,
    );
  }

  Future<void> deleteEntry({
    required String id,
  }) {
    return khataApiService.deleteEntry(id: id);
  }

  Future<KhataEntryModel> createFromMotorLog({
    required MotorLogResponse log,
    required String customerName,
    required String deviceId,
    required double pricePerHour,
    double cashReceived = 0,
    int fallbackRunSeconds = 0,
  }) async {
    final motorLogId = log.id?.trim() ?? "";

    double runHours = _runHoursFromLog(log);

    if (runHours <= 0 && fallbackRunSeconds > 0) {
      runHours = fallbackRunSeconds / 3600.0;
    }

    if (runHours <= 0) {
      runHours = 1 / 3600.0;
    }

    final totalBill = runHours * pricePerHour;
    final remainingBalance = totalBill - cashReceived;

    final entry = KhataEntryModel(
      customerName: customerName.trim().isEmpty
          ? "Mobile App"
          : customerName.trim(),
      deviceId: deviceId,
      pricePerHour: pricePerHour,
      motorLogId: motorLogId,
      cashReceived: cashReceived,
      date: _dateOnly(log.endTime ?? DateTime.now()),
      runHours: runHours,
      totalBill: totalBill,
      remainingBalance: remainingBalance <= 0 ? 0 : remainingBalance,
      paymentStatus: _paymentStatus(
        cashReceived: cashReceived,
        totalBill: totalBill,
      ),
    );

    return khataApiService.createEntry(entry: entry);
  }

  double _runHoursFromLog(MotorLogResponse log) {
    final durationMinutes = log.durationMinutes;

    if (durationMinutes != null && durationMinutes > 0) {
      return durationMinutes / 60.0;
    }

    final start = log.startTime;
    final end = log.endTime;

    if (start != null && end != null) {
      final seconds = end.difference(start).inSeconds;

      if (seconds > 0) {
        return seconds / 3600.0;
      }
    }

    return 0;
  }

  String _dateOnly(DateTime date) {
    return "${date.year.toString().padLeft(4, "0")}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
  }

  String _paymentStatus({
    required double cashReceived,
    required double totalBill,
  }) {
    if (totalBill <= 0) return "unpaid";
    if (cashReceived >= totalBill) return "paid";
    if (cashReceived > 0) return "partial";
    return "unpaid";
  }

  Future<KhataEntryModel> startMotorKhataSession({
    required String customerName,
    required String deviceId,
    required String motorLogId,
    required DateTime startTime,
  }) {
    final entry = KhataEntryModel(
      customerName: customerName.trim(),
      deviceId: deviceId,
      motorLogId: motorLogId,
      date: _dateOnly(startTime),
      startTime: startTime,
      endTime: null,
      status: "open",
      runHours: 0,
      pricePerHour: 0,
      totalBill: 0,
      cashReceived: 0,
      remainingBalance: 0,
      paymentStatus: "unpaid",
    );

    return khataApiService.createEntry(entry: entry);
  }

  Future<KhataEntryModel> closeMotorKhataSession({
    required KhataEntryModel entry,
    required DateTime endTime,
  }) async {
    final id = entry.id?.trim() ?? "";

    if (id.isEmpty) {
      throw AppException(message: "Khata entry ID missing");
    }

    if (entry.motorLogId.trim().isEmpty) {
      throw AppException(
        message: "Cannot finalize Khata: motor_log_id is missing",
      );
    }

    // Do NOT trust a phone-calculated duration here.
    // The backend KhataService already knows how to resolve the linked
    // MotorLog and calculate:
    //   run_hours = (MotorLog.end_time - MotorLog.start_time) / 3600
    //
    // endTime remains in this signature for compatibility with the rest
    // of your existing code, but final billing is server-authoritative.
    return khataApiService.finalizeMotorSession(entry: entry);
  }
}
