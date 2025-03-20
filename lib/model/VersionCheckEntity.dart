class VersionCheckEntity {
  final int success;
  final String message;

  VersionCheckEntity({required this.success, required this.message});

  // Factory constructor to create an instance from JSON
  factory VersionCheckEntity.fromJson(Map<String, dynamic> json) {
    return VersionCheckEntity(
      success: json['success'],
      message: json['message'],
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
