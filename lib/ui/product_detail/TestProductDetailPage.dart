import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/service/product_service.dart';
import 'package:flutter_final_sem4/ui/product_detail/product_detail.dart';

class TestProductDetailPage extends StatefulWidget {
  const TestProductDetailPage({Key? key}) : super(key: key);

  @override
  State<TestProductDetailPage> createState() => _TestProductDetailPageState();
}

class _TestProductDetailPageState extends State<TestProductDetailPage> {
  bool isLoading = true;
  Product? product;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Lấy tất cả sản phẩm
      final products = await ProductService().getAllProducts();
      
      // Tìm sản phẩm có productId = 3
      final foundProduct = products.firstWhere(
        (p) => p.productId == 4,
        orElse: () => throw Exception('Không tìm thấy sản phẩm có ID = 3'),
      );

      setState(() {
        product = foundProduct;
        print('📦 Product imageUrl: ${foundProduct.imageUrl}'); // Thêm dòng này
        isLoading = false;
      });

      // Tự động navigate sang ProductDetailPage
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: foundProduct),
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Product Detail'),
      ),
      body: Center(
        child: isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải sản phẩm ID = 3...'),
                ],
              )
            : errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: $errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadProduct,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : Container(),
      ),
    );
  }
}