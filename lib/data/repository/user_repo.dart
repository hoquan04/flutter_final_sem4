import 'dart:convert';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {
  final String baseUrl = "${ApiConstants.baseUrl}/Auth";

  // ✅ Cập nhật thông tin
  Future<bool> updateProfile(String fullName, String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token") ?? "";

      final url = Uri.parse("$baseUrl/profile");
      final body = jsonEncode({
        "fullName": fullName,
        "email": email,
      });

      print("🔹 Update Profile URL: $url");
      print("🔹 Token: $token");
      print("🔹 Request body: $body");

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      print("📥 Status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Lưu lại thông tin mới vào local
        await prefs.setString("fullName", fullName);
        await prefs.setString("email", email);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Update profile error: $e");
      return false;
    }
  }

  // ✅ Đổi mật khẩu
  Future<bool> changePassword(String oldPass, String newPass) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token") ?? "";

      final url = Uri.parse("$baseUrl/change-password");
      final body = jsonEncode({
        "currentPassword": oldPass,
        "newPassword": newPass,
      });

      print("🔑 Token: $token");
      print("📡 URL: $url");
      print("📦 Request body: $body");

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      print("📥 Status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Change password error: $e");
      return false;
    }
  }
}
