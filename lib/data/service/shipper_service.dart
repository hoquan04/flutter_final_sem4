import 'dart:convert';
import 'package:flutter_final_sem4/data/model/ShipperOrder.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:nb_utils/nb_utils.dart';

class ShipperService {
  final String baseUrl = "${ApiConstants.baseUrl}/shipper";

  /// 🪪 Gửi yêu cầu đăng ký shipper (ảnh CCCD 2 mặt)
  /// 🪪 Gửi yêu cầu đăng ký Shipper có ảnh thực tế
  Future<Map<String, dynamic>> registerShipperWithFiles(
      int userId, File frontFile, File backFile) async {
    final uri = Uri.parse("$baseUrl/request-shipper");

    var request = http.MultipartRequest('POST', uri);
    request.fields['userId'] = userId.toString();
    request.files.add(await http.MultipartFile.fromPath('CccdFront', frontFile.path));
    request.files.add(await http.MultipartFile.fromPath('CccdBack', backFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception("Lỗi gửi yêu cầu Shipper: ${response.statusCode}");
    }
  }
  /// 📦 Lấy danh sách đơn hàng có thể nhận
  Future<List<ShipperOrder>> getAvailableOrders() async {
    final url = Uri.parse("$baseUrl/available");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List<dynamic> list = data['data'] ?? [];
      return list.map((e) => ShipperOrder.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load available orders");
    }
  }

  /// 🚚 Lấy danh sách đơn hàng của shipper
  Future<List<ShipperOrder>> getMyOrders(int shipperId) async {
    final url = Uri.parse("$baseUrl/my-orders/$shipperId");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List<dynamic> list = data['data'] ?? [];
      return list.map((e) => ShipperOrder.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load my orders");
    }
  }

  /// 📬 Nhận đơn hàng
  Future<void> assignOrder(int orderId, int shipperId) async {
    final url = Uri.parse("$baseUrl/assign?orderId=$orderId&shipperId=$shipperId");
    final res = await http.post(url);
    if (res.statusCode != 200) {
      throw Exception("Failed to assign order: ${res.statusCode}");
    }
  }

  /// ✅ Hoàn tất giao hàng
  /// ✅ Hoàn tất giao hàng
  Future<Map<String, dynamic>> completeOrder(int orderId, int shipperId) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/Order/shipper/$shipperId/complete/$orderId");
    final response = await http.put(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to complete order: ${response.statusCode}");
    }
  }


  /// 🔄 Lấy role hiện tại của user (Customer / Shipper / Admin)
  Future<String?> fetchUserRole(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token'); // ✅ lấy token từ login

      if (token == null) {
        print("⚠️ Không có token -> không thể lấy role");
        return null;
      }

      final url = Uri.parse("${ApiConstants.baseUrl}/user/$userId");
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ Gửi token
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print("📦 Role API trả về: ${data['data']['role']}");
        return data['data']['role'];
      } else {
        print("❌ Không lấy được role: ${res.statusCode} | ${res.body}");
        return null;
      }
    } catch (e) {
      print("🔥 Lỗi fetchUserRole: $e");
      return null;
    }
  }


}
