import 'package:smart_iot_app/src/core/exceptions/device_exception.dart';

class MotorModel {
  // ---------------------------------------------------------------------------
  // CORE STATE
  // ---------------------------------------------------------------------------
  final bool isOn;
  final DateTime? startTime;
  final String mode; // manual / schedule / auto

  // ---------------------------------------------------------------------------
  // FAULTS
  // ---------------------------------------------------------------------------
  final bool phaseFault;
  final bool voltageFault;
  final bool tripFault;
  final bool maintenanceRequired;

  // ---------------------------------------------------------------------------
  // DEVICE ERROR
  // ---------------------------------------------------------------------------
  final DeviceException? deviceError;

  // ---------------------------------------------------------------------------
  // ELECTRICAL PARAMETERS
  // ---------------------------------------------------------------------------

  // Voltage
  final double vL1;
  final double vL2;
  final double vL3;

  // Current
  final double cL1;
  final double cL2;
  final double cL3;

  // Power & Energy
  final double frequency;       // Hz
  final double load;            // %
  final double activePower;     // kW
  final double reactivePower;   // kVAR
  final double apparentPower;   // kVA
  final double powerFactor;     // PF

  const MotorModel({
    // Core
    required this.isOn,
    this.startTime,
    required this.mode,

    // Faults
    required this.phaseFault,
    required this.voltageFault,
    required this.tripFault,
    required this.maintenanceRequired,

    // Error
    this.deviceError,

    // Voltage
    required this.vL1,
    required this.vL2,
    required this.vL3,

    // Current
    required this.cL1,
    required this.cL2,
    required this.cL3,

    // Power
    required this.frequency,
    required this.load,
    required this.activePower,
    required this.reactivePower,
    required this.apparentPower,
    required this.powerFactor,
  });

  // ---------------------------------------------------------------------------
  // FIREBASE / API MAPPING
  // ---------------------------------------------------------------------------
  // factory MotorModel.fromMap(Map<String, dynamic> map) {
  //   return MotorModel(
  //     // Core
  //     isOn: map['isOn'] ?? false,
  //     startTime: map['startTime'] != null
  //         ? DateTime.parse(map['startTime'])
  //         : null,
  //     mode: map['mode'] ?? "manual",
  //
  //     // Faults
  //     phaseFault: map['phaseFault'] ?? false,
  //     voltageFault: map['voltageFault'] ?? false,
  //     tripFault: map['tripFault'] ?? false,
  //     maintenanceRequired: map['maintenanceRequired'] ?? false,
  //
  //     // Error
  //     deviceError: map['deviceError'] != null
  //         ? DeviceException.fromCode(
  //       code: map['deviceError']['code'],
  //       message: map['deviceError']['message'],
  //     )
  //         : null,
  //
  //     // Voltage
  //     vL1: (map['vL1'] ?? 0).toDouble(),
  //     vL2: (map['vL2'] ?? 0).toDouble(),
  //     vL3: (map['vL3'] ?? 0).toDouble(),
  //
  //     // Current
  //     cL1: (map['cL1'] ?? 0).toDouble(),
  //     cL2: (map['cL2'] ?? 0).toDouble(),
  //     cL3: (map['cL3'] ?? 0).toDouble(),
  //
  //     // Power
  //     frequency: (map['frequency'] ?? 0).toDouble(),
  //     load: (map['load'] ?? 0).toDouble(),
  //     activePower: (map['activePower'] ?? 0).toDouble(),
  //     reactivePower: (map['reactivePower'] ?? 0).toDouble(),
  //     apparentPower: (map['apparentPower'] ?? 0).toDouble(),
  //     powerFactor: (map['powerFactor'] ?? 0).toDouble(),
  //   );
  // }
  factory MotorModel.fromMap(Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);

    final electrical = Map<String, dynamic>.from(map['electrical'] ?? {});
    final voltage = Map<String, dynamic>.from(electrical['voltage'] ?? {});
    final current = Map<String, dynamic>.from(electrical['current'] ?? {});
    final power = Map<String, dynamic>.from(electrical['power'] ?? {});
    final faults = Map<String, dynamic>.from(map['faults'] ?? {});
    final status = Map<String, dynamic>.from(map['status'] ?? {});
    final powerFactor = Map<String, dynamic>.from(map['powerFactor'] ?? {});

    return MotorModel(
      // CORE
      isOn: map['isOn'] == true,
      startTime: map['startTime'] != null
          ? DateTime.tryParse(map['startTime'].toString())
          : null,
      mode: map['mode']?.toString() ?? "manual",

      // FAULTS
      phaseFault: faults['phaseFault'] == true,
      voltageFault: faults['voltageFault'] == true,
      tripFault: faults['tripFault'] == true,
      maintenanceRequired: faults['maintenanceRequired'] == true,

      // ERROR
      deviceError: status['deviceError'] is Map
          ? DeviceException.fromCode(
        code: status['deviceError']['code'],
        message: status['deviceError']['message'],
      )
          : null,

      // VOLTAGE
      vL1: (voltage['L1'] as num?)?.toDouble() ?? 0,
      vL2: (voltage['L2'] as num?)?.toDouble() ?? 0,
      vL3: (voltage['L3'] as num?)?.toDouble() ?? 0,

      // CURRENT
      cL1: (current['L1'] as num?)?.toDouble() ?? 0,
      cL2: (current['L2'] as num?)?.toDouble() ?? 0,
      cL3: (current['L3'] as num?)?.toDouble() ?? 0,

      // POWER
      frequency: (electrical['frequency'] as num?)?.toDouble() ?? 0,
      load: (electrical['load'] as num?)?.toDouble() ?? 0,
      activePower: (power['active'] as num?)?.toDouble() ?? 0,
      reactivePower: (power['reactive'] as num?)?.toDouble() ?? 0,
      apparentPower: (power['apparent'] as num?)?.toDouble() ?? 0,
      powerFactor: (power['powerFactor'] as num?)?.toDouble() ?? 0,

    );
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     // Core
  //     'isOn': isOn,
  //     'startTime': startTime?.toIso8601String(),
  //     'mode': mode,
  //
  //     // Faults
  //     'phaseFault': phaseFault,
  //     'voltageFault': voltageFault,
  //     'tripFault': tripFault,
  //     'maintenanceRequired': maintenanceRequired,
  //
  //     // Error
  //     'deviceError': deviceError == null
  //         ? null
  //         : {
  //       'code': deviceError!.code,
  //       'message': deviceError!.message,
  //     },
  //
  //     // Voltage
  //     'vL1': vL1,
  //     'vL2': vL2,
  //     'vL3': vL3,
  //
  //     // Current
  //     'cL1': cL1,
  //     'cL2': cL2,
  //     'cL3': cL3,
  //
  //     // Power
  //     'frequency': frequency,
  //     'load': load,
  //     'activePower': activePower,
  //     'reactivePower': reactivePower,
  //     'apparentPower': apparentPower,
  //     'powerFactor': powerFactor,
  //   };
  // }

  // ---------------------------------------------------------------------------
  // COPY WITH
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      "isOn": isOn,
      "startTime": startTime?.toIso8601String(),
      "mode": mode,

      "faults": {
        "phaseFault": phaseFault,
        "voltageFault": voltageFault,
        "tripFault": tripFault,
        "maintenanceRequired": maintenanceRequired,
      },

      "status": {
        "deviceError": deviceError == null
            ? null
            : {
          "code": deviceError!.code,
          "message": deviceError!.message,
        },
      },

      "electrical": {
        "frequency": frequency,
        "load": load,

        "voltage": {
          "L1": vL1,
          "L2": vL2,
          "L3": vL3,
        },

        "current": {
          "L1": cL1,
          "L2": cL2,
          "L3": cL3,
        },

        "power": {
          "active": activePower,
          "reactive": reactivePower,
          "apparent": apparentPower,
          "powerFactor": powerFactor,
        },
      }
    };
  }
  MotorModel copyWith({
    bool? isOn,
    DateTime? startTime,
    String? mode,

    bool? phaseFault,
    bool? voltageFault,
    bool? tripFault,
    bool? maintenanceRequired,

    DeviceException? deviceError,

    double? vL1,
    double? vL2,
    double? vL3,

    double? cL1,
    double? cL2,
    double? cL3,

    double? frequency,
    double? load,
    double? activePower,
    double? reactivePower,
    double? apparentPower,
    double? powerFactor,
  }) {
    return MotorModel(
      isOn: isOn ?? this.isOn,
      startTime: startTime ?? this.startTime,
      mode: mode ?? this.mode,

      phaseFault: phaseFault ?? this.phaseFault,
      voltageFault: voltageFault ?? this.voltageFault,
      tripFault: tripFault ?? this.tripFault,
      maintenanceRequired: maintenanceRequired ?? this.maintenanceRequired,

      deviceError: deviceError ?? this.deviceError,

      vL1: vL1 ?? this.vL1,
      vL2: vL2 ?? this.vL2,
      vL3: vL3 ?? this.vL3,

      cL1: cL1 ?? this.cL1,
      cL2: cL2 ?? this.cL2,
      cL3: cL3 ?? this.cL3,

      frequency: frequency ?? this.frequency,
      load: load ?? this.load,
      activePower: activePower ?? this.activePower,
      reactivePower: reactivePower ?? this.reactivePower,
      apparentPower: apparentPower ?? this.apparentPower,
      powerFactor: powerFactor ?? this.powerFactor,
    );
  }
}