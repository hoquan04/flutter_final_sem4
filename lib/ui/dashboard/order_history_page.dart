import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/OrderHistoryDto.dart';
import 'package:flutter_final_sem4/data/repository/OrderRepository.dart';
import 'package:flutter_final_sem4/ui/dashboard/history_orderdetail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_final_sem4/data/model/order.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  final OrderRepository _repo = OrderRepository();
  late Future<List<OrderHistoryDto>> _ordersFuture;
  int? _userId;
  late TabController _tabController;

  final List<OrderStatus> _statuses = OrderStatus.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");
    setState(() {
      _userId = userId;
      if (_userId != null) {
        _ordersFuture = _repo.getOrdersByUser(_userId!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử đơn hàng"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _statuses
              .map((s) => Tab(text: s.toString().split('.').last))
              .toList(),
        ),
      ),
      body: FutureBuilder<List<OrderHistoryDto>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: _statuses.map((status) {
              final filtered = orders
                  .where((o) => o.order.status == status)
                  .toList();

              if (filtered.isEmpty) {
                return const Center(child: Text("Không có đơn hàng"));
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final order = filtered[index].order;
                  final shipping = filtered[index].shipping;

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text("Đơn #${order.orderId} - ${order.status.toString().split('.').last}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ngày đặt: ${order.orderDate.toLocal()}"),
                          Text("Tổng tiền: ${order.totalAmount.toStringAsFixed(0)}đ"),
                          if (shipping != null) Text("Địa chỉ: ${shipping.address}"),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailPage(orderHistory: filtered[index]),
                          ),
                        );
                      },

                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
