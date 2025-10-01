import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/OrderHistoryDto.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderHistoryDto orderHistory;

  const OrderDetailPage({Key? key, required this.orderHistory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final order = orderHistory.order;
    final shipping = orderHistory.shipping;
    final details = orderHistory.orderDetails ?? [];
    final payments = orderHistory.payments ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết đơn #${order.orderId}"),
        backgroundColor: Colors.green, // 🌿 xanh lá cây
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Text("📦 Trạng thái: ${order.status.toString().split('.').last}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("📅 Ngày đặt: ${order.orderDate.toLocal()}"),
            Text("💰 Tổng tiền: ${order.totalAmount.toStringAsFixed(0)}đ"),
            if (shipping != null) ...[
              const Divider(),
              const Text("🚚 Thông tin giao hàng",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Người nhận: ${shipping.recipientName ?? ''}"),
              Text("Địa chỉ: ${shipping.address}"),
              Text("Email: ${shipping.email ?? ''}"),
              Text("SĐT: ${shipping.phoneNumber ?? ''}"),
            ],
            if (details.isNotEmpty) ...[
              const Divider(),
              const Text("🛒 Sản phẩm",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...details.map((d) => ListTile(
                title: Text(d.productName ?? ''),
                subtitle: Text("SL: ${d.quantity} x ${d.unitPrice}đ"),
                trailing: Text("${d.subTotal}đ"),
              )),
            ],
            if (payments.isNotEmpty) ...[
              const Divider(),
              const Text("💳 Thanh toán",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...payments.map((p) => ListTile(
                title: Text("Phương thức: ${p.paymentMethod}"),
                subtitle: Text("Trạng thái: ${p.paymentStatus}"),
                trailing: Text("Ngày: ${p.createdAt.toLocal()}"),
              )),
            ]
          ],
        ),
      ),
    );
  }
}
