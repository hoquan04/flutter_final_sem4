import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/service/test_service.dart';

class TestRepository {
  final testproductService _repo = testproductService();

  Future<void> fetchAndPrint() async {
    try {
      List<Product> products = await _repo.getAllProducts();
      for (var p in products) {
        print("${p.productId} - ${p.name} - ${p.price}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
