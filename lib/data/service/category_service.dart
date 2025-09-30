import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/category.dart';
import 'api_constants.dart';

class CategoryService {
  final String baseUrl = ApiConstants.categoryUrl;

  Future<List<Category>> getAllCategories() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load categories: ${response.statusCode}");
    }
  }
}
