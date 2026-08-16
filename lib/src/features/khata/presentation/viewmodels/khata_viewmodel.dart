// import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:flutter_riverpod/legacy.dart";
//
// import "../../../../core/error/app_exception.dart";
// import "../../../motor/data/models/motor_log_response.dart";
// import "../../data/models/khata_entry_model.dart";
// import "../../data/repositories/khata_repository.dart";
// import "../state/khata_state.dart";
//
// class KhataViewModel extends StateNotifier<KhataState> {
//   final KhataRepository khataRepository;
//
//   KhataViewModel({
//     required this.khataRepository,
//   }) : super(const KhataState());
//
//   // Future<void> loadEntries() async {
//   //   try {
//   //     state = state.copyWith(
//   //       isLoading: true,
//   //       error: null,
//   //       message: null,
//   //     );
//   //
//   //     final entries = await khataRepository.getEntries();
//   //
//   //     state = state.copyWith(
//   //       isLoading: false,
//   //       entries: entries,
//   //     );
//   //   } on AppException catch (e) {
//   //     state = state.copyWith(
//   //       isLoading: false,
//   //       error: e.message,
//   //     );
//   //   } catch (e) {
//   //     state = state.copyWith(
//   //       isLoading: false,
//   //       error: "Failed to load Khata: ${e.toString()}",
//   //     );
//   //   }
//   // }
//
//   Future<void> createEntry(KhataEntryModel entry) async {
//     try {
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final created = await khataRepository.createEntry(entry: entry);
//       final updatedList = [created, ...state.entries];
//
//       state = state.copyWith(
//         isLoading: false,
//         entries: updatedList,
//         message: "Khata entry created",
//       );
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to create Khata entry: ${e.toString()}",
//       );
//     }
//   }
//
//   Future<void> createFromMotorLog({
//     required MotorLogResponse log,
//     required String customerName,
//     required String deviceId,
//     required double pricePerHour,
//     double cashReceived = 0,
//     int fallbackRunSeconds = 0,
//   }) async {
//     try {
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final created = await khataRepository.createFromMotorLog(
//         log: log,
//         customerName: customerName,
//         deviceId: deviceId,
//         pricePerHour: pricePerHour,
//         cashReceived: cashReceived,
//         fallbackRunSeconds: fallbackRunSeconds,
//       );
//
//       final updatedList = [created, ...state.entries];
//
//       state = state.copyWith(
//         isLoading: false,
//         entries: updatedList,
//         message: "Khata entry created from motor run",
//       );
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to create Khata from motor log: ${e.toString()}",
//       );
//     }
//   }
//
//   Future<void> createFromLatestMotorLog({
//     required String customerName,
//     required String deviceId,
//     required double pricePerHour,
//     double cashReceived = 0,
//   }) async {
//     state = state.copyWith(
//       error:
//       "Latest motor log endpoint is not available. Stop motor first, then create Khata from the stop response.",
//     );
//   }
//
//   Future<void> loadEntries() async {
//     try {
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final entries = await khataRepository.getEntries();
//
//       state = state.copyWith(
//         isLoading: false,
//         entries: entries,
//         error: null,
//         message: null,
//       );
//     } on AppException catch (e) {
//       final text = e.message.toLowerCase();
//
//       if (text.contains("get_all_entries") ||
//           text.contains("database error during get_all_entries")) {
//         state = state.copyWith(
//           isLoading: false,
//           error:
//           "Khata could not load because backend database query failed. Motor logs and Khata table mapping need backend fix.",
//           message: null,
//         );
//         return;
//       }
//
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//         message: null,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to load Khata.",
//         message: null,
//       );
//     }
//   }
//   Future<void> updatePriceAndBill({
//     required KhataEntryModel entry,
//     required double pricePerHour,
//     double cashReceived = 0,
//   }) async {
//     try {
//       if (pricePerHour <= 0) {
//         state = state.copyWith(
//           error: "Enter a valid price per hour",
//           message: null,
//         );
//         return;
//       }
//
//       if (entry.runHours <= 0) {
//         state = state.copyWith(
//           error: "Run hours missing. Cannot calculate bill.",
//           message: null,
//         );
//         return;
//       }
//
//       final entryId = entry.id;
//
//       if (entryId == null || entryId.isEmpty) {
//         state = state.copyWith(
//           error: "Khata entry ID missing",
//           message: null,
//         );
//         return;
//       }
//
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final totalBill = entry.runHours * pricePerHour;
//       final remainingBalance = totalBill - cashReceived;
//
//       final updated = entry.copyWith(
//         pricePerHour: pricePerHour,
//         cashReceived: cashReceived,
//         totalBill: totalBill,
//         remainingBalance: remainingBalance <= 0 ? 0 : remainingBalance,
//         paymentStatus: _paymentStatus(
//           cashReceived: cashReceived,
//           totalBill: totalBill,
//         ),
//       );
//
//       final saved = await khataRepository.updateEntry(entry: updated);
//
//       final entries = state.entries.map((item) {
//         return item.id == saved.id ? saved : item;
//       }).toList();
//
//       state = state.copyWith(
//         isLoading: false,
//         entries: entries,
//         message: "Bill calculated successfully",
//       );
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to calculate bill: ${e.toString()}",
//       );
//     }
//   }
//
//   Future<void> updateEntry(KhataEntryModel entry) async {
//     try {
//       final entryId = entry.id;
//
//       if (entryId == null || entryId.isEmpty) {
//         state = state.copyWith(
//           error: "Khata entry ID missing",
//           message: null,
//         );
//         return;
//       }
//
//       if (entry.customerName.trim().isEmpty) {
//         state = state.copyWith(
//           error: "Customer name is required",
//           message: null,
//         );
//         return;
//       }
//
//       if (entry.runHours <= 0) {
//         state = state.copyWith(
//           error: "Run hours must be greater than zero",
//           message: null,
//         );
//         return;
//       }
//
//       if (entry.pricePerHour < 0) {
//         state = state.copyWith(
//           error: "Price per hour cannot be negative",
//           message: null,
//         );
//         return;
//       }
//
//       if (entry.cashReceived < 0) {
//         state = state.copyWith(
//           error: "Cash received cannot be negative",
//           message: null,
//         );
//         return;
//       }
//
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final totalBill = entry.runHours * entry.pricePerHour;
//       final remainingBalance = totalBill - entry.cashReceived;
//
//       final normalized = entry.copyWith(
//         totalBill: totalBill,
//         remainingBalance: remainingBalance <= 0 ? 0 : remainingBalance,
//         paymentStatus: _paymentStatus(
//           cashReceived: entry.cashReceived,
//           totalBill: totalBill,
//         ),
//       );
//
//       final saved = await khataRepository.updateEntry(entry: normalized);
//
//       final entries = state.entries.map((item) {
//         return item.id == saved.id ? saved : item;
//       }).toList();
//
//       state = state.copyWith(
//         isLoading: false,
//         entries: entries,
//         message: "Khata entry updated",
//       );
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to update Khata entry: ${e.toString()}",
//       );
//     }
//   }
//
//   Future<void> addPayment({
//     required KhataEntryModel entry,
//     required double amount,
//   }) async {
//     try {
//       if (amount <= 0) {
//         state = state.copyWith(
//           error: "Enter a valid payment amount",
//           message: null,
//         );
//         return;
//       }
//
//       final entryId = entry.id;
//
//       if (entryId == null || entryId.isEmpty) {
//         state = state.copyWith(
//           error: "Khata entry ID missing",
//           message: null,
//         );
//         return;
//       }
//
//       if (entry.totalBill <= 0 || entry.pricePerHour <= 0) {
//         state = state.copyWith(
//           error: "Set price per hour before adding payment",
//           message: null,
//         );
//         return;
//       }
//
//       if (entry.remainingBalance <= 0) {
//         state = state.copyWith(
//           error: "This Khata entry is already cleared",
//           message: null,
//         );
//         return;
//       }
//
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final saved = await khataRepository.addPayment(
//         entryId: entryId,
//         amount: amount,
//       );
//
//       final entries = state.entries.map((item) {
//         return item.id == saved.id ? saved : item;
//       }).toList();
//
//       state = state.copyWith(
//         isLoading: false,
//         entries: entries,
//         message: saved.remainingBalance <= 0
//             ? "Payment completed. Balance cleared."
//             : "Payment added. Remaining balance updated.",
//       );
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to add payment: ${e.toString()}",
//       );
//     }
//   }
//
//   Future<void> deleteEntry(String id) async {
//     try {
//       if (id.trim().isEmpty) {
//         state = state.copyWith(
//           error: "Khata entry ID missing",
//           message: null,
//         );
//         return;
//       }
//
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       await khataRepository.deleteEntry(id: id);
//
//       final entries = state.entries.where((item) => item.id != id).toList();
//
//       state = state.copyWith(
//         isLoading: false,
//         entries: entries,
//         message: "Khata entry deleted",
//       );
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to delete Khata entry: ${e.toString()}",
//       );
//     }
//   }
//   Future<KhataEntryModel?> startMotorKhataSession({
//     required String customerName,
//     required String deviceId,
//     required String motorLogId,
//     required DateTime startTime,
//   }) async {
//     try {
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final created =
//       await khataRepository.startMotorKhataSession(
//         customerName: customerName,
//         deviceId: deviceId,
//         motorLogId: motorLogId,
//         startTime: startTime,
//       );
//
//       final updatedList = [created, ...state.entries];
//
//       state = state.copyWith(
//         isLoading: false,
//         entries: updatedList,
//         message: "Khata session started",
//       );
//
//       return created;
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//       return null;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to start Khata session: ${e.toString()}",
//       );
//       return null;
//     }
//   }
//
//   Future<KhataEntryModel?> closeMotorKhataSession({
//     required KhataEntryModel entry,
//     required DateTime endTime,
//   }) async {
//     try {
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final saved =
//       await khataRepository.closeMotorKhataSession(
//         entry: entry,
//         endTime: endTime,
//       );
//
//       final updatedEntries = state.entries.map((item) {
//         return item.id == saved.id ? saved : item;
//       }).toList();
//
//       state = state.copyWith(
//         isLoading: false,
//         entries: updatedEntries,
//         message: "Khata session closed",
//       );
//
//       return saved;
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//       return null;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to close Khata session: ${e.toString()}",
//       );
//       return null;
//     }
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
// }
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../../core/error/app_exception.dart";
import "../../../motor/data/models/motor_log_response.dart";
import "../../data/models/khata_entry_model.dart";
import "../../data/repositories/khata_repository.dart";
import "../state/khata_state.dart";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../../core/error/app_exception.dart";
import "../../../motor/data/models/motor_log_response.dart";
import "../../data/models/khata_entry_model.dart";
import "../../data/repositories/khata_repository.dart";
import "../state/khata_state.dart";

class KhataViewModel extends StateNotifier<KhataState> {
  final KhataRepository khataRepository;

  KhataViewModel({
    required this.khataRepository,
  }) : super(const KhataState());

  // Future<void> loadEntries() async {
  //   try {
  //     state = state.copyWith(
  //       isLoading: true,
  //       error: null,
  //       message: null,
  //     );
  //
  //     final entries = await khataRepository.getEntries();
  //
  //     state = state.copyWith(
  //       isLoading: false,
  //       entries: entries,
  //     );
  //   } on AppException catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: e.message,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: "Failed to load Khata: ${e.toString()}",
  //     );
  //   }
  // }

  Future<void> createEntry(KhataEntryModel entry) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final created = await khataRepository.createEntry(entry: entry);
      final updatedList = [created, ...state.entries];

      state = state.copyWith(
        isLoading: false,
        entries: updatedList,
        message: "Khata entry created",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to create Khata entry: ${e.toString()}",
      );
    }
  }

  Future<void> createFromMotorLog({
    required MotorLogResponse log,
    required String customerName,
    required String deviceId,
    required double pricePerHour,
    double cashReceived = 0,
    int fallbackRunSeconds = 0,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final created = await khataRepository.createFromMotorLog(
        log: log,
        customerName: customerName,
        deviceId: deviceId,
        pricePerHour: pricePerHour,
        cashReceived: cashReceived,
        fallbackRunSeconds: fallbackRunSeconds,
      );

      final updatedList = [created, ...state.entries];

      state = state.copyWith(
        isLoading: false,
        entries: updatedList,
        message: "Khata entry created from motor run",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to create Khata from motor log: ${e.toString()}",
      );
    }
  }

  Future<void> createFromLatestMotorLog({
    required String customerName,
    required String deviceId,
    required double pricePerHour,
    double cashReceived = 0,
  }) async {
    state = state.copyWith(
      error:
      "Latest motor log endpoint is not available. Stop motor first, then create Khata from the stop response.",
    );
  }

  Future<void> loadEntries() async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final entries = await khataRepository.getEntries();

      state = state.copyWith(
        isLoading: false,
        entries: entries,
        error: null,
        message: null,
      );
    } on AppException catch (e) {
      final text = e.message.toLowerCase();

      if (text.contains("get_all_entries") ||
          text.contains("database error during get_all_entries")) {
        state = state.copyWith(
          isLoading: false,
          error:
          "Khata could not load because backend database query failed. Motor logs and Khata table mapping need backend fix.",
          message: null,
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        error: e.message,
        message: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to load Khata.",
        message: null,
      );
    }
  }
  Future<void> updatePriceAndBill({
    required KhataEntryModel entry,
    required double pricePerHour,
    double cashReceived = 0,
  }) async {
    try {
      if (pricePerHour <= 0) {
        state = state.copyWith(
          error: "Enter a valid price per hour",
          message: null,
        );
        return;
      }

      if (entry.runHours <= 0 && !entry.isOpen) {
        state = state.copyWith(
          error: "Run hours missing. Cannot calculate bill.",
          message: null,
        );
        return;
      }

      final entryId = entry.id;

      if (entryId == null || entryId.isEmpty) {
        state = state.copyWith(
          error: "Khata entry ID missing",
          message: null,
        );
        return;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final totalBill =
      entry.isOpen ? 0.0 : entry.runHours * pricePerHour;

      final remainingBalance = totalBill - cashReceived;

      final updated = entry.copyWith(
        pricePerHour: pricePerHour,
        cashReceived: cashReceived,
        totalBill: totalBill,
        remainingBalance: remainingBalance <= 0 ? 0 : remainingBalance,
        paymentStatus: entry.isOpen
            ? "unpaid"
            : _paymentStatus(
          cashReceived: cashReceived,
          totalBill: totalBill,
        ),
      );

      final saved = await khataRepository.updateEntry(entry: updated);

      final entries = state.entries.map((item) {
        return item.id == saved.id ? saved : item;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        entries: entries,
        message: "Bill calculated successfully",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to calculate bill: ${e.toString()}",
      );
    }
  }

  Future<void> updateEntry(KhataEntryModel entry) async {
    try {
      final entryId = entry.id;

      if (entryId == null || entryId.isEmpty) {
        state = state.copyWith(
          error: "Khata entry ID missing",
          message: null,
        );
        return;
      }

      if (entry.customerName.trim().isEmpty) {
        state = state.copyWith(
          error: "Customer name is required",
          message: null,
        );
        return;
      }

      if (entry.runHours <= 0 && !entry.isOpen) {
        state = state.copyWith(
          error: "Run hours must be greater than zero",
          message: null,
        );
        return;
      }

      if (entry.pricePerHour < 0) {
        state = state.copyWith(
          error: "Price per hour cannot be negative",
          message: null,
        );
        return;
      }

      if (entry.cashReceived < 0) {
        state = state.copyWith(
          error: "Cash received cannot be negative",
          message: null,
        );
        return;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final totalBill = entry.isOpen
          ? 0.0
          : entry.runHours * entry.pricePerHour;

      final remainingBalance = totalBill - entry.cashReceived;

      final normalized = entry.copyWith(
        totalBill: totalBill,
        remainingBalance: remainingBalance <= 0 ? 0 : remainingBalance,
        paymentStatus: entry.isOpen
            ? "unpaid"
            : _paymentStatus(
          cashReceived: entry.cashReceived,
          totalBill: totalBill,
        ),
      );

      final saved = await khataRepository.updateEntry(entry: normalized);

      final entries = state.entries.map((item) {
        return item.id == saved.id ? saved : item;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        entries: entries,
        message: "Khata entry updated",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to update Khata entry: ${e.toString()}",
      );
    }
  }

  Future<void> addPayment({
    required KhataEntryModel entry,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        state = state.copyWith(
          error: "Enter a valid payment amount",
          message: null,
        );
        return;
      }

      final entryId = entry.id;

      if (entryId == null || entryId.isEmpty) {
        state = state.copyWith(
          error: "Khata entry ID missing",
          message: null,
        );
        return;
      }

      if (entry.totalBill <= 0 || entry.pricePerHour <= 0) {
        state = state.copyWith(
          error: "Set price per hour before adding payment",
          message: null,
        );
        return;
      }

      if (entry.remainingBalance <= 0) {
        state = state.copyWith(
          error: "This Khata entry is already cleared",
          message: null,
        );
        return;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final saved = await khataRepository.addPayment(
        entryId: entryId,
        amount: amount,
      );

      final entries = state.entries.map((item) {
        return item.id == saved.id ? saved : item;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        entries: entries,
        message: saved.remainingBalance <= 0
            ? "Payment completed. Balance cleared."
            : "Payment added. Remaining balance updated.",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to add payment: ${e.toString()}",
      );
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      if (id.trim().isEmpty) {
        state = state.copyWith(
          error: "Khata entry ID missing",
          message: null,
        );
        return;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      await khataRepository.deleteEntry(id: id);

      final entries = state.entries.where((item) => item.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        entries: entries,
        message: "Khata entry deleted",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to delete Khata entry: ${e.toString()}",
      );
    }
  }
  Future<KhataEntryModel?> startMotorKhataSession({
    required String customerName,
    required String deviceId,
    required String motorLogId,
    required DateTime startTime,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final created =
      await khataRepository.startMotorKhataSession(
        customerName: customerName,
        deviceId: deviceId,
        motorLogId: motorLogId,
        startTime: startTime,
      );

      final updatedList = [created, ...state.entries];

      state = state.copyWith(
        isLoading: false,
        entries: updatedList,
        message: "Khata session started",
      );

      return created;
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to start Khata session: ${e.toString()}",
      );
      return null;
    }
  }

  Future<KhataEntryModel?> closeMotorKhataSession({
    required KhataEntryModel entry,
    required DateTime endTime,
  }) async {
    try {
      final entryId = entry.id?.trim() ?? "";

      if (entryId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: "Khata entry ID missing",
          message: null,
        );
        return null;
      }

      if (entry.motorLogId.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: "Khata motor_log_id missing. Cannot finalize motor runtime.",
          message: null,
        );
        return null;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      KhataEntryModel? saved;

      // The STOP endpoint and PostgreSQL update can finish a fraction apart.
      // Retry finalization so the Khata is not left open forever if the first
      // request reaches KhataService just before MotorLog.end_time is visible.
      for (var attempt = 1; attempt <= 4; attempt++) {
        saved = await khataRepository.closeMotorKhataSession(
          entry: entry,
          endTime: endTime,
        );

        // Backend response is the authority.
        if (!saved.isOpen &&
            saved.endTime != null &&
            saved.runHours > 0) {
          break;
        }

        if (attempt < 4) {
          await Future.delayed(
            Duration(milliseconds: 500 * attempt),
          );
        }
      }

      if (saved == null ||
          saved.isOpen ||
          saved.endTime == null ||
          saved.runHours <= 0) {
        state = state.copyWith(
          isLoading: false,
          error:
          "Motor is OFF, but Khata is still open. "
              "Backend did not finalize the linked MotorLog yet.",
          message: null,
        );
        return null;
      }

      final finalized = saved;

      final updatedEntries = state.entries.map((item) {
        return item.id == finalized.id ? finalized : item;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        entries: updatedEntries,
        error: null,
        message:
        "Khata session closed. Run time: ${finalized.runHours.toStringAsFixed(2)} hr",
      );

      return finalized;
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        message: null,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to close Khata session: ${e.toString()}",
        message: null,
      );
      return null;
    }
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
}

