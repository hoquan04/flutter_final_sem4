import 'dart:convert';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:http/http.dart' as http;

class FavoriteService {
  final String baseUrl = '${ApiConstants.baseUrl}/favorite';

  // POST /api/favorite - Thêm sản phẩm yêu thích
  Future<bool> addToFavorites(int userId, int productId) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'productId': productId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  // DELETE /api/favorite - Xóa sản phẩm yêu thích
  Future<bool> removeFromFavorites(int userId, int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl?userId=$userId&productId=$productId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  // GET /api/favorite/check - Kiểm tra trạng thái yêu thích
  Future<bool> checkFavoriteStatus(int userId, int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check?userId=$userId&productId=$productId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  // GET /api/favorite/user/{userId} - Danh sách yêu thích của user
  Future<List<Product>> getUserFavorites(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];

        // Trả về danh sách Product từ favorites
        return data.map((item) {
          // Nếu API trả về product trực tiếp trong favorite object
          if (item['product'] != null) {
            return Product.fromJson(item['product']);
          }
          // Hoặc nếu item chính là product object
          return Product.fromJson(item);
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get user favorites: $e');
    }
  }

  // GET /api/favorite/product/{productId}/count - Đếm số lượt yêu thích
  Future<int> getFavoriteCount(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/$productId/count'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? 0;
      }
      return 0;
    } catch (e) {
      throw Exception('Failed to get favorite count: $e');
    }
  }

  // Toggle favorite status (add/remove based on current status)
  Future<bool> toggleFavorite(int userId, int productId) async {
    final isFavorite = await checkFavoriteStatus(userId, productId);
    if (isFavorite) {
      return await removeFromFavorites(userId, productId);
    } else {
      return await addToFavorites(userId, productId);
    }
  }
}
