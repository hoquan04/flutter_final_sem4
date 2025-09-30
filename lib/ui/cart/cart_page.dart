import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/CartDto.dart';
import 'package:flutter_final_sem4/data/repository/CartRepository.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:flutter_final_sem4/ui/checkout/checkout_page.dart';

class CartPage extends StatefulWidget {
  static String tag = '/CartPage';

  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartRepository _repo = CartRepository();
  late Future<List<CartDto>> _cartFuture;

  // TODO: thay userId = user đăng nhập thật (ví dụ lấy từ JWT hoặc local storage)
  final int userId = 1;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    setState(() {
      _cartFuture = _repo.getCartByUser(userId);
    });
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

  Future<void> _removeItem(CartDto item) async {
    await _repo.removeItem(item.cartId);
    _loadCart();
  }

  Future<double> _getTotalPrice(List<CartDto> items) async {
    return items.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // bỏ bóng đổ
        title: Row(
          children: const [
            Icon(
              Icons.shopping_cart,
              color: Color(0xFF00c97b), // màu custom
            ),
            SizedBox(width: 8),
            Text(
              "Giỏ hàng",
              style: TextStyle(
                color: Colors.black,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),


      body: FutureBuilder<List<CartDto>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data!;
          if (cartItems.isEmpty) {
            return const Center(child: Text("Giỏ hàng trống"));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    final itemTotal = item.price * item.quantity;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                                ? Image.network(
                              ApiConstants.sourceImage + item.imageUrl!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            )
                                : const Icon(Icons.image, size: 60),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(
                                    "${item.price}đ x ${item.quantity}",
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.remove, size: 20, color: Colors.grey),
                                      onPressed: () => _decreaseQuantity(item),
                                    ),
                                    SizedBox(
                                      height: 24,
                                      width: 32,
                                      child: TextField(
                                        controller: TextEditingController(text: item.quantity.toString()),
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 14),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onSubmitted: (value) async {
                                          final newQuantity = int.tryParse(value) ?? item.quantity;
                                          if (newQuantity > 0) {
                                            await _repo.updateQuantity(item.cartId, newQuantity);
                                            _loadCart();
                                          }
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.add, size: 20, color: Colors.grey),
                                      onPressed: () => _increaseQuantity(item),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 12),
                                Text(
                                  "${(item.price * item.quantity).toStringAsFixed(0)}đ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.grey),
                                  onPressed: () => _removeItem(item),
                                ),
                              ],
                            ),


                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Tổng cộng
              FutureBuilder<double>(
                future: _getTotalPrice(cartItems),
                builder: (context, snapshot) {
                  final totalPrice = snapshot.data ?? 0;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tổng cộng:",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              "${totalPrice.toStringAsFixed(0)}đ",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00c97b), // thay Colors.green
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CheckoutPage()),
                              );
                            },
                            child: const Text("Đặt hàng", style: TextStyle(fontSize: 16)),
                          ),

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
