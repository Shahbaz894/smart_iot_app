class VfdResetRequest {
  final bool confirm;

  VfdResetRequest({
    required this.confirm,
  });

  /// Creates a copy of this request with the ability to toggle the confirmation.
  VfdResetRequest copyWith({
    bool? confirm,
  }) {
    return VfdResetRequest(
      confirm: confirm ?? this.confirm,
    );
  }

  /// Converts the instance to a Map for JSON serialization.
  Map<String, dynamic> toJson() {
    return {
      "confirm": confirm,
    };
  }

  /// Creates an instance from a Map, defaulting to false if parsing fails.
  factory VfdResetRequest.fromJson(Map<String, dynamic> json) {
    return VfdResetRequest(
      confirm: json["confirm"] == true || json["confirm"] == 1,
    );
  }
}