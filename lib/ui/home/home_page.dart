import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/model/category.dart';
import 'package:flutter_final_sem4/data/service/product_service.dart';
import 'package:flutter_final_sem4/data/service/category_service.dart';
// Widget phụ đã tách riêng, chỉ import cần thiết
import 'package:flutter_final_sem4/ui/home/category_card.dart';
import 'package:flutter_final_sem4/ui/home/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _TestProductPageState();
}

class _TestProductPageState extends State<HomePage> {
  // Khai báo Future cho API
  late Future<List<Product>> _futureProducts;
  late Future<List<Product>> _futureFeaturedProducts;
  late Future<List<Category>> _futureCategories;
  int? _selectedCategoryId;
  Future<List<Product>>? _futureProductsByCategory;

  @override
  void initState() {
    super.initState();
    _futureProducts = ProductService().getAllProducts();
    _futureFeaturedProducts = ProductService().getFeaturedProducts(count: 4);
    _futureCategories = CategoryService().getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    // UI chính trang Home
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề sản phẩm nổi bật
              const Text(
                "Sản phẩm nổi bật",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Product>>(
                future: _futureFeaturedProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return SizedBox(
                      height: 180,
                      child: Center(child: Text("Lỗi: ${snapshot.error}")),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: Text("Không có sản phẩm nổi bật")),
                    );
                  } else {
                    final products = snapshot.data!;
                    return SizedBox(
                      height: 260,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final p = products[index];
                          return SizedBox(
                            width: 180,
                            child: ProductCard(product: p),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              // Tiêu đề danh mục
              const Text(
                "Danh mục sản phẩm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Grid danh mục sản phẩm
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
                    // Thêm item 'All' vào đầu danh sách
                    final categories = snapshot.data!;
                    final allItem = Category(categoryId: -1, name: "Tất cả");
                    final displayCategories = [allItem, ...categories];
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
                      itemCount: displayCategories.length,
                      itemBuilder: (context, index) {
                        final c = displayCategories[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (c.categoryId == -1) {
                                // Chọn 'All' -> reset filter
                                _selectedCategoryId = null;
                              } else {
                                _selectedCategoryId = c.categoryId;
                                _futureProductsByCategory = ProductService()
                                    .getProductsByCategory(c.categoryId);
                              }
                            });
                          },
                          child: CategoryCard(name: c.name),
                        );
                      },
                    );
                  }
                },
              ),
              // ...Xoá mục sản phẩm theo danh mục, chỉ giữ lại phần tất cả sản phẩm...
              // Danh sách tất cả sản phẩm (lọc theo category nếu đã chọn)
              const SizedBox(height: 16),
              Text(
                _selectedCategoryId == null
                    ? "Tất cả sản phẩm"
                    : "Sản phẩm của danh mục đã chọn",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
                FutureBuilder<List<Product>>(
                future: _selectedCategoryId == null
                    ? _futureProducts
                    : _futureProductsByCategory,
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
                            childAspectRatio: 0.6,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return ProductCard(product: p);
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
