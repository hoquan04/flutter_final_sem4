import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/product.dart';
import 'package:flutter_final_sem4/data/service/test_service.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _TestProductPageState();
}

class _TestProductPageState extends State<HomePage> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = testproductService().getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách sản phẩm")),
      body: FutureBuilder<List<Product>>(
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
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return Card(
                  child: ListTile(
                      leading: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                          ? Image.network(
                        p.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.image),


                    title: Text(p.name),
                    subtitle: Text("${p.price} đ"),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
