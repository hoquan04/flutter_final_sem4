import 'package:flutter_final_sem4/data/service/CartService.dart';
import 'package:flutter_final_sem4/data/model/CartDto.dart';
class CartRepository {
  final CartService _service = CartService();

  Future<List<CartDto>> getCartByUser(int userId) => _service.getCartByUser(userId);
  Future<bool> addToCart(int userId, int productId, int quantity) => _service.addToCart(userId, productId, quantity);
  Future<bool> updateQuantity(int cartId, int quantity) => _service.updateQuantity(cartId, quantity);
  Future<bool> removeItem(int cartId) => _service.removeItem(cartId);
  Future<bool> clearCart(int userId) => _service.clearCart(userId);
}
