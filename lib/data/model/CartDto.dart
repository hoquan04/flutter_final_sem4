class CartDto {
  final int cartId;
  final int userId;
  final int productId;
  final int quantity;
  final String productName;
  final String? imageUrl;
  final double price;

  final String? description;
  final int stockQuantity;
  final DateTime createdAt;  // ✅ luôn có giá trị

  CartDto({
    required this.cartId,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.productName,
    this.imageUrl,
    required this.price,
    this.description,
    this.stockQuantity = 0,
    required this.createdAt,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    return CartDto(
      cartId: json['cartId'],
      userId: json['userId'],
      productId: json['productId'],
      quantity: json['quantity'],
      productName: json['productName'] ?? '',
      imageUrl: json['imageUrl'],
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      stockQuantity: json['stockQuantity'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']), // ✅ luôn parse
    );
  }
}
