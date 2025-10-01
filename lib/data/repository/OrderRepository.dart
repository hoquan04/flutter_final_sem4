import 'dart:convert';
import 'package:flutter_final_sem4/data/model/OrderHistoryDto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_final_sem4/data/service/api_constants.dart';

class OrderRepository {
  final String baseUrl = "${ApiConstants.baseUrl}/order";

  Future<List<OrderHistoryDto>> getOrdersByUser(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/user/$userId"));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List<dynamic> data = body['data'];
      return data.map((e) => OrderHistoryDto.fromJson(e)).toList();
    }
    throw Exception("Lấy lịch sử đơn hàng thất bại");
  }
}
