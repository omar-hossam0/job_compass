class HRNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  HRNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.metadata,
  });

  factory HRNotification.fromJson(Map<String, dynamic> json) {
    return HRNotification(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['read'] ?? json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
