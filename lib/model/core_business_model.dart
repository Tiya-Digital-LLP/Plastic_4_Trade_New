class CoreApiResponse {
  final int status;
  final String message;
  final List<Core> getCore;

  CoreApiResponse({
    required this.status,
    required this.message,
    required this.getCore,
  });

  factory CoreApiResponse.fromJson(Map<String, dynamic> json) {
    return CoreApiResponse(
      status: json['status'] ?? 0, // Default to 0 if 'status' is null
      message: json['message'] ?? 'Unknown error', // Default message if null
      getCore: (json['getcore'] as List<dynamic>?)
              ?.map((item) => Core.fromJson(item))
              .toList() ??
          [], // Handle 'getcore' being null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'getcore': getCore.map((core) => core.toJson()).toList(),
    };
  }
}

class Core {
  final int id;
  final String name;
  final int? userId;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Core({
    required this.id,
    required this.name,
    this.userId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Core.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) {
      if (dateString != null && dateString.isNotEmpty) {
        return DateTime.parse(dateString);
      }
      return null;
    }

    return Core(
      id: json['id'] ?? 0, // Default to 0 if id is null
      name: json['name'] ?? 'Unknown', // Default name if null
      userId: json['user_id'],
      status: json['status'] ?? 0, // Default to 0 if status is null
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      deletedAt: parseDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
