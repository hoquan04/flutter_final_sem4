import 'dart:convert';
import 'package:flutter_final_sem4/data/model/CheckoutRequestDto.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class CheckoutService {
  final String baseUrl = "${ApiConstants.baseUrl}/Checkout";

  Future<Map<String, dynamic>> checkout(CheckoutRequestDto dto) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(dto.toJson()), // gửi JSON đúng
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Checkout failed: ${res.body}");
    }
  }
}
