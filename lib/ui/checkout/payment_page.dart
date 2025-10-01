import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/CheckoutRequestDto.dart';
import 'package:flutter_final_sem4/data/repository/CheckoutRepository.dart';


class PaymentPage extends StatelessWidget {
  final CheckoutRequestDto dto;
  final String method;
  final _repo = CheckoutRepository();

  PaymentPage({super.key, required this.dto, required this.method});

  Future<void> _processPayment(BuildContext context) async {
    // giả lập thanh toán thành công
    await Future.delayed(const Duration(seconds: 2));

    final res = await _repo.checkout(dto);
    if (res.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Thanh toán $method & đặt hàng thành công")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi: ${res.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thanh toán $method")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _processPayment(context),
          child: Text("Xác nhận thanh toán $method"),
        ),
      ),
    );
  }
}
