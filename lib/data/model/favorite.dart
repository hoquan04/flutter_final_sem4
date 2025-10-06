import 'package:flutter_final_sem4/data/model/product.dart';

class Favorite {
  final int favoriteId;
  final int userId;
  final int productId;
  final Product?
  product; // Thông tin sản phẩm kèm theo (cho API get user favorites)
  final DateTime createdAt;

  Favorite({
    required this.favoriteId,
    required this.userId,
    required this.productId,
    this.product,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      favoriteId: json['favoriteId'] ?? 0,
      userId: json['userId'] ?? 0,
      productId: json['productId'] ?? 0,
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favoriteId': favoriteId,
      'userId': userId,
      'productId': productId,
      'product': product?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
