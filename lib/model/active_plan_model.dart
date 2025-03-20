class ActivePlan {
  final String chat;

  ActivePlan({required this.chat});

  factory ActivePlan.fromJson(Map<String, dynamic> json) {
    final chat =
        json['chat'] as String? ?? ''; // Default to empty string if null
    return ActivePlan(
      chat: chat,
    );
  }
}
