import 'dart:convert';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:http/http.dart' as http;

class testproductService {
  final String baseUrl = ApiConstants.productUrl;


  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Vì API của bạn trả về object { success, message, data }
      final List<dynamic> data = jsonResponse['data'];

      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load products: ${response.statusCode}");
    }
  }
}
