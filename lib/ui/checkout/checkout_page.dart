import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/payment.dart';
import 'package:flutter_final_sem4/data/service/PaymentService.dart';


class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _orderIdController = TextEditingController();
  String _selectedMethod = "Cash"; // mặc định
  List<Payment> _payments = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _loading = true);
    try {
      final data = await _paymentService.getAllPayments();
      setState(() {
        _payments = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải payments: $e")),
      );
    }
    setState(() => _loading = false);
  }

  Future<void> _createPayment() async {
    if (_orderIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập OrderId")),
      );
      return;
    }

    final orderId = int.tryParse(_orderIdController.text);
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OrderId phải là số")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final newPayment = await _paymentService.createPayment(orderId, _selectedMethod);
      setState(() {
        _payments.insert(0, newPayment);
        _orderIdController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tạo payment thành công")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tạo payment: $e")),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Nhập OrderId
            TextField(
              controller: _orderIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Order ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Chọn phương thức
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: ["Cash", "CreditCard", "Paypal"].map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: "Phương thức thanh toán",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Nút tạo payment
            ElevatedButton.icon(
              onPressed: _loading ? null : _createPayment,
              icon: const Icon(Icons.payment),
              label: const Text("Tạo Payment"),
            ),
            const SizedBox(height: 20),

            // Hiển thị danh sách payment
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _payments.isEmpty
                  ? const Center(child: Text("Chưa có payment nào"))
                  : ListView.builder(
                itemCount: _payments.length,
                itemBuilder: (context, index) {
                  final p = _payments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text("Order #${p.orderId} - ${p.paymentMethod}"),
                      subtitle: Text(
                        "Trạng thái: ${p.paymentStatus}\nNgày: ${p.createdAt}",
                      ),
                      trailing: p.paidAt != null
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.hourglass_empty, color: Colors.orange),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
