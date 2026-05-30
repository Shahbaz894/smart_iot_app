class VfdCommandResponse {
  final String? id;
  final String? deviceId;
  final String? command;
  final String? status;
  final String? message;
  final DateTime? createdAt;

  VfdCommandResponse({
    this.id,
    this.deviceId,
    this.command,
    this.status,
    this.message,
    this.createdAt,
  });

  /// Returns a new instance of VfdCommandResponse with updated fields.
  VfdCommandResponse copyWith({
    String? id,
    String? deviceId,
    String? command,
    String? status,
    String? message,
    DateTime? createdAt,
  }) {
    return VfdCommandResponse(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      command: command ?? this.command,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts the model instance into a Map for JSON serialization.
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "device_id": deviceId,
      "command": command,
      "status": status,
      "message": message,
      "created_at": createdAt?.toIso8601String(),
    };
  }

  factory VfdCommandResponse.fromJson(Map<String, dynamic> json) {
    return VfdCommandResponse(
      id: json["id"]?.toString(),
      deviceId: json["device_id"]?.toString(),
      command: json["command"]?.toString(),
      status: json["status"]?.toString(),
      // Handles both 'message' and 'detail' keys from the JSON
      message: json["message"]?.toString() ?? json["detail"]?.toString(),
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"].toString())
          : null,
    );
  }
}