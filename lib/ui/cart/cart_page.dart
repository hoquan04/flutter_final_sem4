import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/CartDto.dart';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/repository/CartRepository.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:flutter_final_sem4/ui/checkout/checkout_page.dart';
import 'package:flutter_final_sem4/ui/product_detail/product_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  static String tag = '/CartPage';
  final VoidCallback? onOrderCompleted; // ✅ callback khi đặt hàng xong

  const CartPage({super.key, this.onOrderCompleted});


  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartRepository _repo = CartRepository();
  Future<List<CartDto>> _cartFuture = Future.value([]);
  final _controllers = <int, TextEditingController>{};
  Set<int> _selectedItems = {};
  int? userId;
  bool _isEditMode = false; // ✅ trạng thái sửa

  Widget _buildQuantityField(CartDto item) {
    _controllers[item.cartId] ??=
        TextEditingController(text: item.quantity.toString());

    return SizedBox(
      width: 40,
      height: 28,
      child: TextField(
        controller: _controllers[item.cartId],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onSubmitted: (value) async {
          final newQuantity = int.tryParse(value) ?? item.quantity;
          if (newQuantity > 0 && newQuantity != item.quantity) {
            await _repo.updateQuantity(item.cartId, newQuantity);
            _loadCart();
          }
        },
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _loadUserAndCart();
  }

  Future<void> _loadUserAndCart() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("userId");
    });
    if (userId != null) {
      setState(() {
        _cartFuture = _repo.getCartByUser(userId!);
      });
    }
  }

  void _loadCart() {
    if (userId != null) {
      setState(() {
        _cartFuture = _repo.getCartByUser(userId!).then((items) {
          // cập nhật lại controllers cho từng item
          for (var item in items) {
            if (_controllers.containsKey(item.cartId)) {
              _controllers[item.cartId]!.text = item.quantity.toString();
            } else {
              _controllers[item.cartId] =
                  TextEditingController(text: item.quantity.toString());
            }
          }
          return items;
        });
      });
    }
  }


  Future<void> _increaseQuantity(CartDto item) async {
    await _repo.updateQuantity(item.cartId, item.quantity + 1);
    _loadCart();
  }

  Future<void> _decreaseQuantity(CartDto item) async {
    if (item.quantity > 1) {
      await _repo.updateQuantity(item.cartId, item.quantity - 1);
      _loadCart();
    }
  }

  Future<void> _removeSelectedItems() async {
    if (_selectedItems.isEmpty) return;
    await _repo.removeItems(_selectedItems.toList());
    setState(() => _selectedItems.clear());
    _loadCart();
  }

  Future<double> _getTotalPrice(List<CartDto> items) async {
    return items
        .where((item) => _selectedItems.contains(item.cartId))
        .fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: FutureBuilder<List<CartDto>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          int count = snapshot.hasData ? snapshot.data!.length : 0;
          return Row(
            children: [
              const Icon(Icons.shopping_cart, color: Color(0xFF00c97b)),
              const SizedBox(width: 8),
              Text("Giỏ hàng ($count)", style: const TextStyle(color: Colors.black)),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _isEditMode = !_isEditMode;
            });
          },
          child: Text(
            _isEditMode ? "Xong" : "Sửa",
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        )
      ],
    ),


    body: FutureBuilder<List<CartDto>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cartItems = snapshot.data!;
          if (cartItems.isEmpty) return const Center(child: Text("Giỏ hàng trống"));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return InkWell(
                      onTap: () {
                        // ⚡ CartDto bây giờ có đủ thông tin
                        final product = Product(
                          productId: item.productId,
                          categoryId: 0, // vẫn để mặc định vì CartDto chưa có categoryId
                          name: item.productName,
                          description: item.description,   // ✅ lấy từ CartDto
                          price: item.price,
                          stockQuantity: item.stockQuantity, // ✅ lấy từ CartDto
                          imageUrl: item.imageUrl,
                          createdAt: item.createdAt, // ✅ lấy từ CartDto (đã parse DateTime trong fromJson)
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(product: product),
                          ),
                        );
                      },

                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _selectedItems.contains(item.cartId),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedItems.add(item.cartId);
                                  } else {
                                    _selectedItems.remove(item.cartId);
                                  }
                                });
                              },
                            ),
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.network(
                                ApiConstants.sourceImage + (item.imageUrl ?? ""),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ✅ Tên sản phẩm
                                  Text(
                                    item.productName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),

                                  // ✅ Giá + nút tăng giảm
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${item.price}đ",
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Thành tiền: ${(item.price * item.quantity).toStringAsFixed(0)}đ",
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          _quantityButton(
                                            icon: Icons.remove,
                                            onTap: () => _decreaseQuantity(item),
                                          ),
                                          SizedBox(
                                            width: 40,
                                            height: 28,
                                            child: _buildQuantityField(item),
                                          ),
                                          _quantityButton(
                                            icon: Icons.add,
                                            onTap: () => _increaseQuantity(item),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                  },
                ),
              ),

              // ✅ Footer: chế độ Đặt hàng hoặc Xóa
              // ✅ Footer: chế độ Đặt hàng hoặc Xóa
              FutureBuilder<double>(
                future: _getTotalPrice(cartItems),
                builder: (context, snapshot) {
                  final totalPrice = snapshot.data ?? 0;
                  bool isAllSelected =
                      _selectedItems.length == cartItems.length && cartItems.isNotEmpty;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        // Checkbox chọn tất cả
                        Checkbox(
                          value: isAllSelected,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedItems = cartItems.map((e) => e.cartId).toSet();
                              } else {
                                _selectedItems.clear();
                              }
                            });
                          },
                        ),
                        const Text("Tất cả"),

                        const Spacer(),

                        // ✅ Tổng tiền + Nút hành động nằm cùng 1 cụm bên phải
                        Row(
                          children: [
                            if (!_isEditMode)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Text(
                                  "Tổng: ${totalPrice.toStringAsFixed(0)}đ",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),

                            // Nút hành động
                            if (_isEditMode)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: _removeSelectedItems,
                                child: const Text("Xóa"),
                              )
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00c97b),
                                ),
                                onPressed: () {
                                  final selected = cartItems
                                      .where((item) => _selectedItems.contains(item.cartId))
                                      .toList();
                                  if (selected.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("⚠️ Vui lòng chọn sản phẩm")),
                                    );
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckoutPage(selectedItems: selected),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      _loadCart(); // ✅ Làm mới giỏ hàng sau khi đặt hàng

                                    }
                                  });

                                },
                                child: Text("Mua hàng (${_selectedItems.length})"),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );

                },
              ),


            ],
          );
        },
      ),
    );

  }
}


Widget _quantityButton({required IconData icon, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Icon(icon, size: 16, color: Colors.black87),
    ),
  );
}
