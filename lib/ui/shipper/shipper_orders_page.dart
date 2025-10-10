import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/ShipperOrder.dart';
import 'package:flutter_final_sem4/data/repository/shipper_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShipperOrdersPage extends StatefulWidget {
  const ShipperOrdersPage({super.key});

  @override
  State<ShipperOrdersPage> createState() => _ShipperOrdersPageState();
}

class _ShipperOrdersPageState extends State<ShipperOrdersPage>
    with SingleTickerProviderStateMixin {
  final repo = ShipperRepository();
  int? shipperId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadShipperId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadShipperId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      shipperId = prefs.getInt("userId");
    });
  }

  Future<void> _assignOrder(int orderId) async {
    if (shipperId == null) return;
    await repo.assignOrder(orderId, shipperId!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Nhận đơn thành công!")),
    );
    setState(() {});
    _tabController.animateTo(1);
  }

  Future<void> _completeOrder(int orderId) async {
    if (shipperId == null) return;
    await repo.completeOrder(orderId, shipperId!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Đã hoàn tất đơn hàng!")),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (shipperId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý giao hàng"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Làm mới danh sách",
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🔄 Đã làm mới danh sách")),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Đơn có thể nhận"),
            Tab(text: "Đơn của tôi"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableOrders(),
          _buildMyOrders(),
        ],
      ),
    );
  }

  // 🧩 Đơn có thể nhận
  Widget _buildAvailableOrders() {
    return FutureBuilder<List<ShipperOrder>>(
      future: repo.getAvailableOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("❌ Lỗi: ${snapshot.error}"));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text("Không có đơn nào để nhận"));
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final o = orders[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(
                    "Đơn #${o.orderId} - ${o.customerName ?? 'Ẩn danh'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    """
📍 Địa chỉ: ${o.address}
📞 SĐT: ${o.phoneNumber ?? 'Không có'}
💰 Tổng: ${o.totalAmount.toStringAsFixed(0)}đ
""",
                    style: const TextStyle(height: 1.4),
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () => _assignOrder(o.orderId),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Nhận đơn"),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 🧩 Đơn của shipper
  Widget _buildMyOrders() {
    return FutureBuilder<List<ShipperOrder>>(
      future: repo.getMyOrders(shipperId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("❌ Lỗi: ${snapshot.error}"));
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(child: Text("Bạn chưa nhận đơn nào"));
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final o = orders[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(
                    "Đơn #${o.orderId} - ${o.customerName ?? 'Ẩn danh'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    """
📍 Địa chỉ: ${o.address}
📞 SĐT: ${o.phoneNumber ?? 'Không có'}
💳 Thanh toán: ${o.paymentStatus}
📦 Trạng thái: ${o.status}
""",
                    style: const TextStyle(height: 1.4),
                  ),
                  isThreeLine: true,
                  trailing: o.status == "Shipping"
                      ? ElevatedButton(
                    onPressed: () => _completeOrder(o.orderId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Hoàn tất"),
                  )
                      : const Text("Đã xong ✅"),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
