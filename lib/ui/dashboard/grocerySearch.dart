import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/service/product_service.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:flutter_final_sem4/ui/product_detail/product_detail.dart';
import 'package:flutter_final_sem4/utils/GroceryColors.dart';
import 'package:flutter_final_sem4/utils/GroceryConstant.dart';
import 'package:flutter_final_sem4/utils/AppWidget.dart';
import 'package:nb_utils/nb_utils.dart';


class GrocerySearch extends StatefulWidget {
  static String tag = '/GrocerySearch';

  const GrocerySearch({super.key});

  @override
  _GrocerySearchState createState() => _GrocerySearchState();
}

class _GrocerySearchState extends State<GrocerySearch> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productService.getAllProducts();
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      toast('Lỗi khi tải sản phẩm: $e');
    }
  }

  void _searchProducts(String query) {
    setState(() {
      _hasSearched = true;
      if (query.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = _allProducts.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
              (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grocery_app_background,
      appBar: AppBar(
        backgroundColor: grocery_colorPrimary,
        title: text(
          "Tìm kiếm sản phẩm",
          textColor: grocery_color_white,
          fontFamily: fontBold,
          fontSize: textSizeLargeMedium,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: grocery_color_white),
          onPressed: () => finish(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(spacing_standard),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: Icon(Icons.search, color: grocery_colorPrimary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: grocery_light_gray_color),
                        onPressed: () {
                          _searchController.clear();
                          _searchProducts('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: grocery_app_background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                _searchProducts(value);
              },
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: grocery_colorPrimary,
                    ),
                  )
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched || _searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: grocery_light_gray_color,
            ),
            SizedBox(height: spacing_standard),
            text(
              'Nhập từ khóa để tìm kiếm',
              textColor: grocery_light_gray_color,
              fontSize: textSizeMedium,
            ),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: grocery_light_gray_color,
            ),
            SizedBox(height: spacing_standard),
            text(
              'Không tìm thấy sản phẩm',
              textColor: grocery_light_gray_color,
              fontSize: textSizeMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(spacing_standard),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductItem(_filteredProducts[index]);
      },
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      margin: EdgeInsets.only(bottom: spacing_standard),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // chuyển sang trang chi tiết sản phẩm
          ProductDetailPage(product: product).launch(context);
          // toast('Chi tiết sản phẩm: ${product.name}');
        },
        child: Padding(
          padding: EdgeInsets.all(spacing_standard),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: grocery_app_background,
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '${ApiConstants.sourceImage}${product.imageUrl}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: grocery_light_gray_color,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.image,
                        size: 40,
                        color: grocery_light_gray_color,
                      ),
              ),
              SizedBox(width: spacing_standard),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text(
                      product.name,
                      fontSize: textSizeMedium,
                      fontFamily: fontMedium,
                      maxLine: 2,
                    ),
                    SizedBox(height: 4),
                    if (product.description != null && product.description!.isNotEmpty)
                      text(
                        product.description!,
                        fontSize: textSizeSmall,
                        textColor: grocery_light_gray_color,
                        maxLine: 2,
                      ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        text(
                          '\$${product.price.toStringAsFixed(2)}',
                          fontSize: textSizeMedium,
                          fontFamily: fontBold,
                          textColor: grocery_colorPrimary,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.stockQuantity > 0
                                ? grocery_colorPrimary_light
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: text(
                            product.stockQuantity > 0
                                ? 'Còn hàng: ${product.stockQuantity}'
                                : 'Hết hàng',
                            fontSize: textSizeSmall,
                            textColor: product.stockQuantity > 0
                                ? grocery_colorPrimary
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}