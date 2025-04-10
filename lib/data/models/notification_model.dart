class Notification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final int? referenceId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      referenceId: json['reference_id'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'reference_id': referenceId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class NotificationResponse {
  final bool success;
  final List<Notification> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  NotificationResponse({
    required this.success,
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final List<Notification> notifications = [];

    if (json['data']['data'] != null) {
      for (var item in json['data']['data']) {
        notifications.add(Notification.fromJson(item));
      }
    }

    return NotificationResponse(
      success: json['success'] ?? false,
      data: notifications,
      currentPage: json['data']['current_page'] ?? 1,
      lastPage: json['data']['last_page'] ?? 1,
      perPage: json['data']['per_page'] ?? 15,
      total: json['data']['total'] ?? 0,
    );
  }
}

class UnreadCountResponse {
  final bool success;
  final int count;

  UnreadCountResponse({required this.success, required this.count});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
    );
  }
}
