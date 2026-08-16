class KhataEntryModel {
  final String? id;
  final String customerName;
  final String deviceId;
  final double pricePerHour;
  final String motorLogId;
  final double cashReceived;
  final String date;
  final double runHours;
  final double totalBill;
  final double remainingBalance;
  final double advanceAmount;
  final String paymentStatus;

  final DateTime? startTime;
  final DateTime? endTime;

  /// open / closed MOTOR SESSION status.
  /// This is deliberately separate from paid / unpaid payment status.
  final String status;

  const KhataEntryModel({
    this.id,
    String? customerName,
    String? deviceId,
    double? pricePerHour,
    String? motorLogId,
    double? cashReceived,
    String? date,
    double? runHours,
    double? totalBill,
    double? remainingBalance,
    double? advanceAmount,
    String? paymentStatus,
    this.startTime,
    this.endTime,
    String? status,

    // old field support
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
  })  : customerName = customerName ?? "",
        deviceId = deviceId ?? "",
        pricePerHour = pricePerHour ?? 0,
        motorLogId = motorLogId ?? "",
        cashReceived = cashReceived ?? paidAmount ?? 0,
        date = date ?? "",
        runHours = runHours ?? 0,
        totalBill = totalBill ?? totalAmount ?? 0,
        remainingBalance =
            remainingBalance ?? remainingAmount ?? 0,
        advanceAmount = advanceAmount ?? 0,
        paymentStatus = paymentStatus ?? "unpaid",
        status = status ?? "closed";

  /// old compatibility getters
  double get totalAmount => totalBill;

  double get paidAmount => cashReceived;

  double get remainingAmount => remainingBalance;

  double get creditAmount => advanceAmount;

  bool get isOpen => status.toLowerCase() == "open";

  bool get isClosed => status.toLowerCase() == "closed";

  bool get isPaid => paymentStatus.toLowerCase() == "paid";

  bool get isPartial => paymentStatus.toLowerCase() == "partial";

  bool get isUnpaid => paymentStatus.toLowerCase() == "unpaid";

  KhataEntryModel copyWith({
    String? id,
    String? customerName,
    String? deviceId,
    double? pricePerHour,
    String? motorLogId,
    double? cashReceived,
    String? date,
    double? runHours,
    double? totalBill,
    double? remainingBalance,
    double? advanceAmount,
    String? paymentStatus,
    DateTime? startTime,
    DateTime? endTime,
    String? status,

    // old aliases
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
  }) {
    return KhataEntryModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      deviceId: deviceId ?? this.deviceId,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      motorLogId: motorLogId ?? this.motorLogId,
      cashReceived:
      cashReceived ?? paidAmount ?? this.cashReceived,
      date: date ?? this.date,
      runHours: runHours ?? this.runHours,
      totalBill: totalBill ?? totalAmount ?? this.totalBill,
      remainingBalance:
      remainingBalance ??
          remainingAmount ??
          this.remainingBalance,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      paymentStatus:
      paymentStatus ?? this.paymentStatus,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  KhataEntryModel addPayment(double amount) {
    final newCashReceived = cashReceived + amount;

    final difference = totalBill - newCashReceived;

    final double newRemaining =
    difference > 0 ? difference : 0;

    final double newAdvance =
    newCashReceived > totalBill
        ? newCashReceived - totalBill
        : 0;

    return copyWith(
      cashReceived: newCashReceived,
      remainingBalance: newRemaining,
      advanceAmount: newAdvance,
      paymentStatus: _paymentStatus(
        cashReceived: newCashReceived,
        totalBill: totalBill,
      ),

      // IMPORTANT:
      // Payment state must never open/close the MOTOR session.
      // Preserve the existing motor-session status.
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      "customer_name": customerName,
      "device_id": deviceId,
      "price_per_hour": pricePerHour,
      "cash_received": cashReceived,
      "date": date,
      "run_hours": runHours,
      "total_bill": totalBill,
      "remaining_balance": remainingBalance,
      "advance_amount": advanceAmount,
      "payment_status": paymentStatus,

      // Keep old keys for backward compatibility.
      "start_time": startTime?.toUtc().toIso8601String(),
      "end_time": endTime?.toUtc().toIso8601String(),
      "status": status,
    };

    if (motorLogId.trim().isNotEmpty) {
      data["motor_log_id"] = motorLogId.trim();
    }

    return data;
  }

  factory KhataEntryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final totalBill = _toDouble(
      json["total_bill"] ?? json["total_amount"],
    );

    final cashReceived = _toDouble(
      json["cash_received"] ?? json["paid_amount"],
    );

    final remainingBalance = _toDouble(
      json["remaining_balance"] ??
          json["remaining_amount"] ??
          json["balance"],
    );

    final advanceAmount = _toDouble(
      json["advance_amount"],
    );

    final motorLogId =
        json["motor_log_id"]?.toString() ?? "";

    // Backend now returns started_at / ended_at.
    // Keep start_time / end_time as fallbacks for old API responses.
    final startTime = _toDate(
      json["started_at"] ?? json["start_time"],
    );

    final endTime = _toDate(
      json["ended_at"] ?? json["end_time"],
    );

    final rawStatus =
    json["status"]?.toString().trim().toLowerCase();

    final backendIsOpen = _toBool(json["is_open"]);

    // Motor session state must come from motor fields,
    // NOT from payment_status or is_cleared.
    String motorStatus;

    if (rawStatus == "open" || rawStatus == "closed") {
      motorStatus = rawStatus!;
    } else if (motorLogId.trim().isNotEmpty) {
      if (backendIsOpen != null) {
        motorStatus =
        backendIsOpen && endTime == null ? "open" : "closed";
      } else {
        // Backward compatibility when old backend omitted is_open.
        motorStatus =
        startTime != null && endTime == null ? "open" : "closed";
      }
    } else {
      // Manual Khata rows are not live motor sessions.
      // This also prevents old DB rows with default is_open=true
      // from appearing as running.
      motorStatus = "closed";
    }

    var paymentStatus =
        json["payment_status"]?.toString() ??
            _paymentStatus(
              cashReceived: cashReceived,
              totalBill: totalBill,
            );

    // An open motor session with provisional bill=0 must not display PAID.
    if (motorStatus == "open" && totalBill <= 0) {
      paymentStatus = "unpaid";
    }

    return KhataEntryModel(
      id: json["id"]?.toString(),

      customerName:
      json["customer_name"]?.toString(),

      deviceId:
      json["device_id"]?.toString(),

      pricePerHour:
      _toDouble(json["price_per_hour"]),

      motorLogId: motorLogId,

      cashReceived: cashReceived,

      date: json["date"]?.toString() ?? "",

      runHours: _toDouble(json["run_hours"]),

      totalBill: totalBill,

      remainingBalance: remainingBalance,

      advanceAmount: advanceAmount,

      paymentStatus: paymentStatus,

      startTime: startTime,

      endTime: endTime,

      status: motorStatus,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;

    final text = value.toString().trim().toLowerCase();

    if (text == "true" || text == "1") return true;
    if (text == "false" || text == "0") return false;

    return null;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;

    final raw = value.toString().trim();

    if (raw.isEmpty) return null;

    final parsed = DateTime.tryParse(raw);

    if (parsed == null) return null;

    // If backend already supplied Z or an offset, Dart knows the timezone.
    final hasTimezone = raw.endsWith("Z") ||
        RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(raw);

    if (hasTimezone) {
      return parsed.toLocal();
    }

    // Your backend timestamps are currently returned without a timezone
    // suffix but are UTC (for example 13:26 UTC = 18:26 Pakistan).
    // Treat a naive backend timestamp as UTC, then convert to phone local time.
    final utc = DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );

    return utc.toLocal();
  }

  static String _paymentStatus({
    required double cashReceived,
    required double totalBill,
  }) {
    if (totalBill <= 0) return "unpaid";

    if (cashReceived >= totalBill) {
      return "paid";
    }

    if (cashReceived > 0) {
      return "partial";
    }

    return "unpaid";
  }
}

