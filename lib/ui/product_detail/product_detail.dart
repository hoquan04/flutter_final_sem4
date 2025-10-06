import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/model/review.dart';
import 'package:flutter_final_sem4/data/repository/CartRepository.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:flutter_final_sem4/data/service/review_service.dart';
import 'package:flutter_final_sem4/ui/review/reviewPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  late TextEditingController _quantityController;
  bool isFavorite = false;
  final CartRepository _cartRepo = CartRepository();
  // Dữ liệu đánh giá từ API
  double rating = 0.0;
  int totalReviews = 0;
  List<Review> recentReviews = [];
  bool isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: quantity.toString());
    _loadReviewData();
  }
  @override
  void dispose() {
    _quantityController.dispose(); // ✅ nhớ dispose
    super.dispose();
  }

  Future<void> _loadReviewData() async {
    try {
      // Lấy điểm trung bình
      final avgRating = await ReviewService.getAverageRating(widget.product.productId);

      // Lấy tất cả reviews của sản phẩm
      final allReviews = await ReviewService.getReviewsByProductId(widget.product.productId);

      setState(() {
        rating = avgRating;
        totalReviews = allReviews.length;
        // Lấy 2 review gần nhất để hiển thị preview
        recentReviews = allReviews.take(3).toList();
        isLoadingReviews = false;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu đánh giá: $e');
      setState(() {
        isLoadingReviews = false;
      });
    }
  }

  void incrementQuantity() {
    if (quantity < widget.product.stockQuantity) {
      setState(() {
        quantity++;
        _quantityController.text = quantity.toString();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chỉ còn ${widget.product.stockQuantity} sản phẩm trong kho'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
        _quantityController.text = quantity.toString();
      });
    }
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
            ? 'Đã thêm vào yêu thích'
            : 'Đã xóa khỏi yêu thích'
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void navigateToReviewPage() async {  // ← THÊM async
  final result = await Navigator.push(  // ← THÊM await và nhận result
    context,
    MaterialPageRoute(
      builder: (context) => ReviewPage(productId: widget.product.productId),
    ),
  );

  // Reload dữ liệu đánh giá nếu có thay đổi
  if (result == true) {
    _loadReviewData();
  }
}

  Future<void> addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Bạn cần đăng nhập để thêm giỏ hàng")),
      );
      return;
    }

    final success = await _cartRepo.addToCart(userId, widget.product.productId, quantity);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã thêm $quantity sản phẩm vào giỏ hàng'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Thêm vào giỏ hàng thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getImageUrl() {
    String imageUrl = widget.product.imageUrl ?? "";
    if (imageUrl.isNotEmpty && !imageUrl.startsWith("http")) {
      return "http://${ApiConstants.domain}$imageUrl";
    }
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header với hình ảnh sản phẩm
                    Stack(
                      children: [
                        Container(
                          height: 400,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 120,
                                          color: Colors.green.shade200,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 120,
                                    color: Colors.green.shade200,
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: toggleFavorite,
                            ),
                          ),
                        ),
                        if (widget.product.stockQuantity <= 5)
                          Positioned(
                            top: 24,
                            left: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              // decoration: BoxDecoration(
                              //   color: Colors.red,
                              //   borderRadius: BorderRadius.circular(8),
                              // ),
                              // child: Text(
                              //   'Chỉ còn ${widget.product.stockQuantity} sản phẩm',
                              //   style: const TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Thông tin sản phẩm
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tên sản phẩm
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Nút đánh giá - Có thể click để xem trang review
                          if (isLoadingReviews)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          else
                            InkWell(
                              onTap: navigateToReviewPage,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      totalReviews > 0
                                          ? rating.toStringAsFixed(1)
                                          : '0.0',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      totalReviews > 0
                                          ? '($totalReviews đánh giá)'
                                          : '(Chưa có đánh giá)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Giá sản phẩm
                          Row(
                            children: [
                              Text(
                                '${widget.product.price.toStringAsFixed(0)}đ',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Số lượng còn lại
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.product.stockQuantity > 10
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 18,
                                  color: widget.product.stockQuantity > 10
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Còn ${widget.product.stockQuantity} sản phẩm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: widget.product.stockQuantity > 10
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Mô tả sản phẩm
                          const Text(
                            'Mô tả sản phẩm',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description ??
                            'Sản phẩm chất lượng cao, được trồng theo phương pháp hữu cơ.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Phần đánh giá nhanh (preview)
                          if (isLoadingReviews)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (recentReviews.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Đánh giá từ khách hàng',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: navigateToReviewPage,
                                        child: const Text('Xem tất cả', style: const TextStyle(color: Colors.green),),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...recentReviews.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final review = entry.value;
                                    return Column(
                                      children: [
                                        if (index > 0) const Divider(height: 20),
                                        _buildReviewPreview(review),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Đánh giá từ khách hàng',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: navigateToReviewPage,
                                        child: const Text('Viết đánh giá'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.rate_review_outlined,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Chưa có đánh giá nào',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // ← khi bàn phím bật
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // cụm tăng giảm số lượng
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // nút giảm
                      SizedBox(
                        width: 40,
                        height: 40, // ✅ đồng bộ chiều cao
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: decrementQuantity,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      // ô số lượng
                      SizedBox(
                        width: 50,
                        height: 40, // ✅ cao bằng nút
                        child: Center(
                          child: TextField(
                            controller: _quantityController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 16),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: (value) {
                              final newQuantity = int.tryParse(value) ?? quantity;
                              if (newQuantity > 0 && newQuantity <= widget.product.stockQuantity) {
                                setState(() => quantity = newQuantity);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Số lượng phải từ 1 đến ${widget.product.stockQuantity}")),
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      // nút tăng
                      SizedBox(
                        width: 40,
                        height: 40, // ✅ đồng bộ chiều cao
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: incrementQuantity,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // nút thêm giỏ hàng
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.product.stockQuantity > 0 ? addToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.product.stockQuantity > 0
                          ? "Thêm vào giỏ - ${(widget.product.price * quantity).toStringAsFixed(0)}đ"
                          : "Hết hàng",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewPreview(Review review) {
    String timeAgo = _formatTimeAgo(review.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              radius: 16,
              child: Text(
                review.userDisplayName.isNotEmpty  // ✅ Fixed here
                    ? review.userDisplayName[0].toUpperCase()
                    : 'A',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userDisplayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            review.comment!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}