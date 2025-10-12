import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/repository/CartRepository.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:flutter_final_sem4/data/service/favorite_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_final_sem4/ui/product_detail/product_detail.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onFavoriteChanged;

  const ProductCard({Key? key, required this.product, this.onFavoriteChanged})
    : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("userId");
      if (userId != null) {
        final isFavorite = await _favoriteService.checkFavoriteStatus(
          userId,
          widget.product.productId,
        );
        if (mounted) {
          setState(() {
            _isFavorite = isFavorite;
          });
        }
      }
    } catch (e) {
      print('Error checking favorite status: $e'); // Debug log
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng đăng nhập trước")),
      );
      return;
    }

    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      final success = await _favoriteService.toggleFavorite(
        userId,
        widget.product.productId,
      );

      if (success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite
                  ? "💝 Đã thêm vào yêu thích"
                  : "💔 Đã xóa khỏi yêu thích",
            ),
          ),
        );

        // Callback to refresh favorite page if needed
        widget.onFavoriteChanged?.call();
      }
    } catch (e) {
      print('Error toggling favorite: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Có lỗi xảy ra: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Xử lý đường dẫn ảnh: nếu là /uploads/... thì tự động thêm host từ ApiConstants
    String imageUrl = widget.product.imageUrl ?? "";
    if (imageUrl.isNotEmpty && !imageUrl.startsWith("http")) {
      imageUrl = "http://${ApiConstants.domain}" + imageUrl;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to product detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: widget.product),
            ),
          );
        },

        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120, // Chiều cao cố định cho mọi ảnh
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                clipBehavior: Clip.hardEdge,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // Phóng ảnh để đầy khung, cắt đều
                  width: double.infinity,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                )
                    : const Icon(
                  Icons.image,
                  size: 48,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${widget.product.price.toStringAsFixed(0)}đ",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Favorite button
                  GestureDetector(
                    onTap: _toggleFavorite,
                    child: _isLoadingFavorite
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt("userId");

                      if (userId == null) {

                        _showOverlayToast(context, "⚠️ Vui lòng đăng nhập trước", Colors.orange);

                        return;
                      }

                      final repo = CartRepository();
                      final success = await repo.addToCart(
                        userId,
                        widget.product.productId,
                        1,
                      );

                      if (success) {
                        _showOverlayToast(
                          context,
                          "🛒 Đã thêm ${widget.product.name} vào giỏ hàng",

                          Colors.green,
                        );
                      } else {
                        _showOverlayToast(
                          context,
                          "❌ Thêm giỏ hàng thất bại",
                          Colors.redAccent,
                        );
                      }

                    },

                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


void _showOverlayToast(BuildContext context, String message, Color color) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.42,
      left: MediaQuery.of(context).size.width * 0.18,
      right: MediaQuery.of(context).size.width * 0.18,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95), // ⚪ nền trắng sáng mờ như shopping
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration:
                        TextDecoration.none, // 🚫 bỏ gạch chân hoàn toàn
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(milliseconds: 1500), () {
    overlayEntry.remove();
  });
}

