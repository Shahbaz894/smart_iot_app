class PaymentModel {
  final double amount;
  final String? note;

  const PaymentModel({
    required this.amount,
    this.note,
  });

  PaymentModel copyWith({
    double? amount,
    String? note,
  }) {
    return PaymentModel(
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "note": note,
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      amount: double.tryParse(json["amount"]?.toString() ?? "") ?? 0,
      note: json["note"]?.toString(),
    );
  }
}