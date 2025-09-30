class Review {
  final int reviewId;
  final int productId;
  final int userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  
  // Thông tin bổ sung từ API
  final String? productName;
  final String? userFullName;

  Review({
    required this.reviewId,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.productName,
    this.userFullName,
  });

  // Getter để tương thích với code hiện tại
  String get userDisplayName => userFullName ?? 'Người dùng ẩn danh';

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    reviewId: json['reviewId'] ?? 0,
    productId: json['productId'] ?? 0,
    userId: json['userId'] ?? 0,
    rating: json['rating'] ?? 0,
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    productName: json['productName'],
    userFullName: json['userFullName'],
  );

  Map<String, dynamic> toJson() => {
    'reviewId': reviewId,
    'productId': productId,
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'productName': productName,
    'userFullName': userFullName,
  };

  // Tạo CreateReviewDto cho API
  Map<String, dynamic> toCreateJson() => {
    'productId': productId,
    'userId': userId,
    'rating': rating,
    'comment': comment,
  };

  // Tạo UpdateReviewDto cho API
  Map<String, dynamic> toUpdateJson() => {
    'rating': rating,
    'comment': comment,
  };
}