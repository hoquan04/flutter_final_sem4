import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/model/category.dart';
import 'package:flutter_final_sem4/data/service/test_service.dart';
import 'package:flutter_final_sem4/data/service/category_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _TestProductPageState();
}

class _TestProductPageState extends State<HomePage> {
  late Future<List<Product>> _futureProducts;
  late Future<List<Category>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureProducts = testproductService().getAllProducts();
    _futureCategories = CategoryService().getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách mock data 5 sản phẩm
    final List<Product> mockProducts = [
      Product(
        productId: 1,
        categoryId: 1,
        name: "Táo Mỹ",
        price: 35000,
        imageUrl:
            "https://images.unsplash.com/photo-1502741338009-cac2772e18bc",
        stockQuantity: 20,
        createdAt: DateTime.now(),
      ),
      Product(
        productId: 2,
        categoryId: 2,
        name: "Chuối Việt Nam",
        price: 25000,
        imageUrl:
            "https://images.unsplash.com/photo-1465101046530-73398c7f28ca",
        stockQuantity: 15,
        createdAt: DateTime.now(),
      ),
      Product(
        productId: 3,
        categoryId: 3,
        name: "Cam Úc",
        price: 40000,
        imageUrl:
            "https://images.unsplash.com/photo-1519864600265-abb23847ef2c",
        stockQuantity: 10,
        createdAt: DateTime.now(),
      ),
      Product(
        productId: 4,
        categoryId: 4,
        name: "Dưa hấu",
        price: 30000,
        imageUrl:
            "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
        stockQuantity: 25,
        createdAt: DateTime.now(),
      ),
      Product(
        productId: 5,
        categoryId: 5,
        name: "Nho Mỹ",
        price: 55000,
        imageUrl:
            "https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=500&q=60",
        stockQuantity: 12,
        createdAt: DateTime.now(),
      ),
    ];

    // ...existing code...

    return Scaffold(
      // appBar: AppBar(title: const Text("Danh sách sản phẩm")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Danh mục sản phẩm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              FutureBuilder<List<Category>>(
                future: _futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Không có danh mục"));
                  } else {
                    final categories = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.2,
                          ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final c = categories[index];
                        return Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            c.name ?? "",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 4),
              const Text(
                "Sản phẩm nổi bật",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Product>>(
                future: _futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Không có sản phẩm"));
                  } else {
                    final products = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child:
                                          p.imageUrl != null &&
                                              p.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              p.imageUrl!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${p.price} đ",
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
                                      const Icon(
                                        Icons.favorite_border,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 12),
                                      const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
