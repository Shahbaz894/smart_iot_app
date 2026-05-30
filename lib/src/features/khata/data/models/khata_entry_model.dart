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
  final String paymentStatus;

  final DateTime? startTime;
  final DateTime? endTime;

  /// open / closed
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
        paymentStatus = paymentStatus ?? "unpaid",
        status = status ?? "closed";

  /// old compatibility getters
  double get totalAmount => totalBill;

  double get paidAmount => cashReceived;

  double get remainingAmount => remainingBalance;

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
      paymentStatus:
      paymentStatus ?? this.paymentStatus,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }

  KhataEntryModel addPayment(double amount) {
    final newCashReceived = cashReceived + amount;

    final double newRemaining =
    (totalBill - newCashReceived) <= 0
        ? 0
        : (totalBill - newCashReceived);

    return copyWith(
      cashReceived: newCashReceived,
      remainingBalance: newRemaining,
      paymentStatus: _paymentStatus(
        cashReceived: newCashReceived,
        totalBill: totalBill,
      ),
      status: newRemaining <= 0 ? "closed" : "open",
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
      "payment_status": paymentStatus,
      "start_time": startTime?.toIso8601String(),
      "end_time": endTime?.toIso8601String(),
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

    final paymentStatus =
        json["payment_status"]?.toString() ??
            _paymentStatus(
              cashReceived: cashReceived,
              totalBill: totalBill,
            );

    final bool isCleared =
        json["is_cleared"] == true;

    return KhataEntryModel(
      id: json["id"]?.toString(),

      customerName:
      json["customer_name"]?.toString(),

      deviceId:
      json["device_id"]?.toString(),

      pricePerHour:
      _toDouble(json["price_per_hour"]),

      motorLogId:
      json["motor_log_id"]?.toString() ?? "",

      cashReceived: cashReceived,

      date: json["date"]?.toString() ?? "",

      runHours: _toDouble(json["run_hours"]),

      totalBill: totalBill,

      remainingBalance: remainingBalance,

      paymentStatus: paymentStatus,

      startTime: _toDate(json["start_time"]),

      endTime: _toDate(json["end_time"]),

      status: json["status"]?.toString() ??
          ((isCleared ||
              paymentStatus.toLowerCase() ==
                  "paid")
              ? "closed"
              : "open"),
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

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(
      value.toString(),
    );
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