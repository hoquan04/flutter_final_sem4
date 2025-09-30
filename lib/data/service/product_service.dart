import 'dart:convert';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final String baseUrl = ApiConstants.productUrl;

  Future<List<Product>> getFeaturedProducts({int count = 4}) async {
    final url = Uri.parse('$baseUrl/newest?count=$count');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception(
        "Failed to load featured products: ${response.statusCode}",
      );
    }
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final url = Uri.parse('$baseUrl/category/$categoryId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception(
        "Failed to load products by category: ${response.statusCode}",
      );
    }
  }

  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load products: ${response.statusCode}");
    }
  }
}
