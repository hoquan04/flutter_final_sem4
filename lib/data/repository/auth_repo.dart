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
      final cleanEmail = email.trim().toLowerCase();          // ✅ lowercase + trim
      final cleanPass  = password.trim();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': cleanEmail, 'password': cleanPass}),
      );

      if (response.statusCode == 200) {
        // body should be JSON, but guard anyway
        final raw = response.body;
        if (raw.isEmpty) return null;
        final data = jsonDecode(raw);

        if (data != null && data['token'] != null && data['user'] != null) {
          final token = data['token'] as String;
          final userJson = data['user'] as Map<String, dynamic>;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('fullName', userJson['fullName'] ?? '');
          await prefs.setString('email', userJson['email'] ?? '');

          return User.fromJson(userJson);
        } else {
          // API may return { message: ... } on bad creds
          // print('login failed: ${data['message'] ?? raw}');
          return null;
        }
      } else {
        // print('HTTP ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      // print('login error: $e');
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
    // nếu cần xóa nhiều key thì xóa ở đây
  }
}
