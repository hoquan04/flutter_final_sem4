import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Giả lập dữ liệu giỏ hàng
  List<Map<String, dynamic>> cartItems = [
    {"name": "Táo Mỹ", "price": 30000, "quantity": 2, "image": "assets/images/grocery/grocery_ic_fruit.png"},
    {"name": "Cà rốt", "price": 15000, "quantity": 1, "image": "assets/images/grocery/grocery_ic_vegetables.png"},
    {"name": "Thịt bò", "price": 120000, "quantity": 1, "image": "assets/images/grocery/grocery_ic_meat.png"},
  ];

  // Hàm tính tổng tiền
  int getTotalAmount() {
    int total = 0;
    // for (var item in cartItems) {
    //   total += item["price"] * item["quantity"];
    // }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                var item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Image.asset(item["image"], width: 40, height: 40),
                    title: Text(item["name"]),
                    subtitle: Text("Giá: ${item["price"]} đ"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (item["quantity"] > 1) {
                                item["quantity"]--;
                              }
                            });
                          },
                        ),
                        Text("${item["quantity"]}"),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              item["quantity"]++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Tổng tiền + nút thanh toán
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tổng: ${getTotalAmount()} đ",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: xử lý thanh toán
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Thanh toán"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
