import 'dart:convert';
import 'package:flutter_final_sem4/data/model/CartDto.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class CartService {
  final String baseUrl = ApiConstants.cartUrl;

  Future<List<CartDto>> getCartByUser(int userId) async {
    final res = await http.get(Uri.parse("$baseUrl/$userId"));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List<dynamic> data = body['data'];
      return data.map((e) => CartDto.fromJson(e)).toList();
    }
    throw Exception("Failed to load cart");
  }

  Future<bool> addToCart(int userId, int productId, int quantity) async {
    final res = await http.post(
      Uri.parse("$baseUrl/add?userId=$userId&productId=$productId&quantity=$quantity"),
    );
    return res.statusCode == 200;
  }

  Future<bool> updateQuantity(int cartId, int quantity) async {
    final res = await http.put(
      Uri.parse("$baseUrl/update?cartId=$cartId&quantity=$quantity"),
    );
    return res.statusCode == 200;
  }

  Future<bool> removeItem(int cartId) async {
    final res = await http.delete(Uri.parse("$baseUrl/remove/$cartId"));
    return res.statusCode == 200;
  }

  Future<bool> clearCart(int userId) async {
    final res = await http.delete(Uri.parse("$baseUrl/clear/$userId"));
    return res.statusCode == 200;
  }
}
