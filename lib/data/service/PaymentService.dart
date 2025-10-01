import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_final_sem4/data/model/payment.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';

class PaymentService {
  final String baseUrl = ApiConstants.paymentUrl;

  // GET: tất cả checkout
  Future<List<Payment>> getAllPayments() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => Payment.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load payments: ${response.statusCode}");
    }
  }

  // POST: tạo mới Payment
  Future<Payment> createPayment(int orderId, String method) async {
    final body = jsonEncode({
      "orderId": orderId,
      "paymentMethod": method,
    });

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return Payment.fromJson(jsonResponse['data']);
    } else {
      throw Exception("Failed to create checkout: ${response.body}");
    }
  }
}
