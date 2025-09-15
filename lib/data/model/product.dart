class Product {
  final int productId;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final DateTime createdAt;

  Product({
    required this.productId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json['productId'],
    categoryId: json['categoryId'],
    name: json['name'],
    description: json['description'],
    price: json['price']?.toDouble(),
    stockQuantity: json['stockQuantity'],
    imageUrl: json['imageUrl'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'categoryId': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'stockQuantity': stockQuantity,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
  };
}
