enum NotificationType { Order, Payment, Shipping, System, Promotion }

class Notification {
  final int notificationId;
  final int userId;
  final String title;
  final String message;
  final NotificationType type;
  final int? orderId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  Notification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.orderId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      notificationId: json['notificationId'] ?? 0,
      userId: json['userId'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.System,
      ),
      orderId: json['orderId'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'userId': userId,
        'title': title,
        'message': message,
        'type': type.toString().split('.').last,
        'orderId': orderId,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
      };
}