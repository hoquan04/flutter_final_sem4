class Review {
  final int reviewId;
  final int productId;
  final int userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.reviewId,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    reviewId: json['reviewId'],
    productId: json['productId'],
    userId: json['userId'],
    rating: json['rating'],
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'reviewId': reviewId,
    'productId': productId,
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };
}
