import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:flutter_final_sem4/data/model/user.dart';

class AuthRepository {
  final String baseUrl = "${ApiConstants.baseUrl}/auth";

  /// LOGIN: trả về User nếu thành công, null nếu thất bại
  Future<User?> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final body = jsonEncode({"email": email.trim(), "password": password.trim()});

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "accept": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // API của bạn trả 200 cả khi login thất bại => phải kiểm tra token/user có tồn tại
        if (data != null && data['token'] != null && data['user'] != null) {
          final token = data['token'] as String;
          final userJson = data['user'] as Map<String, dynamic>;

          // Lưu token + 1 vài thông tin user để dùng ở Profile/khởi chạy
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("auth_token", token);
          await prefs.setString("fullName", userJson['fullName'] ?? '');
          await prefs.setString("email", userJson['email'] ?? '');


          await prefs.setInt("userId", userJson['userId'] ?? 0); // giữ nguyên
          await prefs.setString("role", userJson['role']?.toString() ?? 'Customer'); // ✅ đổi sang String



          return User.fromJson(userJson);
        } else {
          // Login thất bại (API trả message) hoặc format khác
          print("AuthRepository.login -> failed: ${data['message'] ?? response.body}");
          return null;
        }
      } else {
        print("AuthRepository.login -> HTTP ${response.statusCode}: ${response.body}");
        return null;
      }
    } catch (e) {
      print("AuthRepository.login error: $e");
      return null;
    }
    

  }

  /// REGISTER: trả về true nếu thành công, false nếu thất bại
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String address,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/register');
      final body = jsonEncode({
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
        "email": email.trim(),
        "phone": phone.trim(),
        "address": address.trim(),
        "role": "Customer",
        "createdAt": DateTime.now().toIso8601String(),
        "password": password.trim(),
        "confirmPassword": confirmPassword.trim(),
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "accept": "application/json"},
        body: body,
      );

      print("👉 Register response: ${response.statusCode} | ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Nếu server trả lỗi validation (400), log để debug
        final data = jsonDecode(response.body);
        print("AuthRepository.register -> failed: $data");
        return false;
      }
    } catch (e) {
      print("AuthRepository.register error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("fullName");
    await prefs.remove("email");

    await prefs.remove("userId"); 

    // nếu cần xóa nhiều key thì xóa ở đây
  }
}
