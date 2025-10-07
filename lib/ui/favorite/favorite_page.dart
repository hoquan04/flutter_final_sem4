import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/service/favorite_service.dart';
import 'package:flutter_final_sem4/ui/home/product_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<Product>> _futureFavorites;
  final FavoriteService _favoriteService = FavoriteService();

  int? _currentUserId; // 👈 dùng biến nullable

  @override
  void initState() {
    super.initState();
    _loadUserAndFavorites();
  }

  Future<void> _loadUserAndFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    if (userId == null || userId == 0) {
      setState(() {
        _currentUserId = null;
      });
      return;
    }

    setState(() {
      _currentUserId = userId;
      _futureFavorites = _favoriteService.getUserFavorites(userId);
    });
  }

  void _refreshFavorites() {
    if (_currentUserId != null) {
      setState(() {
        _futureFavorites = _favoriteService.getUserFavorites(_currentUserId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Sản phẩm yêu thích",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshFavorites,
                    icon: const Icon(Icons.refresh),
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nếu chưa đăng nhập
              if (_currentUserId == null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Vui lòng đăng nhập để xem danh sách yêu thích",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              // Danh sách yêu thích
              else
                Expanded(
                  child: FutureBuilder<List<Product>>(
                    future: _futureFavorites,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(
                                "Lỗi: ${snapshot.error}",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshFavorites,
                                child: const Text("Thử lại"),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text(
                                "Chưa có sản phẩm yêu thích",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Hãy thêm những sản phẩm bạn yêu thích!",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final products = snapshot.data!;
                        return RefreshIndicator(
                          onRefresh: () async {
                            _refreshFavorites();
                          },
                          child: GridView.builder(
                            physics:
                            const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                product: product,
                                onFavoriteChanged: _refreshFavorites,
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
