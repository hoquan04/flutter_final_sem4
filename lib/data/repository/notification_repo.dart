import 'dart:convert';
import 'package:flutter_final_sem4/data/model/Nofication.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';

class NotificationRepository {
  final String baseUrl = "${ApiConstants.baseUrl}/notification";

  // Lấy tất cả thông báo của user
  Future<List<Notification>> getNotificationsByUserId(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/user/$userId');
      final response = await http.get(url);

      print("📬 Get Notifications URL: $url");
      print("📬 Status: ${response.statusCode}");
      print("📬 Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> notificationList = data['data'];
          return notificationList
              .map((json) => Notification.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("❌ Get notifications error: $e");
      return [];
    }
  }

  // Đếm số thông báo chưa đọc
  Future<int> getUnreadCount(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/user/$userId/unread-count');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      print("❌ Get unread count error: $e");
      return 0;
    }
  }

  // Đánh dấu một thông báo đã đọc
  Future<bool> markAsRead(int notificationId) async {
    try {
      final url = Uri.parse('$baseUrl/$notificationId/mark-read');
      final response = await http.put(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("❌ Mark as read error: $e");
      return false;
    }
  }

  // Đánh dấu tất cả thông báo đã đọc
  Future<bool> markAllAsRead(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/user/$userId/mark-all-read');
      final response = await http.put(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("❌ Mark all as read error: $e");
      return false;
    }
  }

  // Xóa một thông báo
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final url = Uri.parse('$baseUrl/$notificationId');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("❌ Delete notification error: $e");
      return false;
    }
  }

  // Xóa tất cả thông báo của user
  Future<bool> deleteAllNotifications(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/user/$userId/clear-all');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("❌ Delete all notifications error: $e");
      return false;
    }
  }

  // ✅ THÊM MỚI: Tạo thông báo sau khi checkout
  Future<bool> createNotification({
    required int userId,
    required String title,
    required String message,
    required String type, // "Order", "Payment", "Shipping", "System", "Promotion"
    int? orderId,
  }) async {
    try {
      final url = Uri.parse(baseUrl);
      final body = jsonEncode({
        "userId": userId,
        "title": title,
        "message": message,
        "type": type,
        "orderId": orderId,
        "isRead": false,
        "createdAt": DateTime.now().toIso8601String(),
      });

      print("🔔 Create Notification URL: $url");
      print("🔔 Request body: $body");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("🔔 Status: ${response.statusCode}");
      print("🔔 Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print("❌ Create notification error: $e");
      return false;
    }
  }
}