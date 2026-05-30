class VfdReferenceFrequencyRequest {
  final double referenceFrequency;

  VfdReferenceFrequencyRequest({
    required this.referenceFrequency,
  });

  /// Creates a new instance with updated values
  VfdReferenceFrequencyRequest copyWith({
    double? referenceFrequency,
  }) {
    return VfdReferenceFrequencyRequest(
      referenceFrequency: referenceFrequency ?? this.referenceFrequency,
    );
  }

  /// Converts the instance to a Map for API requests
  Map<String, dynamic> toJson() {
    return {
      "reference_frequency": referenceFrequency,
    };
  }

  /// Creates an instance from a Map
  factory VfdReferenceFrequencyRequest.fromJson(Map<String, dynamic> json) {
    return VfdReferenceFrequencyRequest(
      referenceFrequency: double.tryParse(json["reference_frequency"]?.toString() ?? "") ?? 0.0,
    );
  }
}