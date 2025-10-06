import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/CheckoutRequestDto.dart';
import 'package:flutter_final_sem4/data/repository/CheckoutRepository.dart';

class PaymentPage extends StatefulWidget {
  final CheckoutRequestDto dto;
  final String method;

  const PaymentPage({super.key, required this.dto, required this.method});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _repo = CheckoutRepository();
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      // Giả lập xử lý thanh toán
      await Future.delayed(const Duration(seconds: 2));

      // Gọi API checkout
      final res = await _repo.checkout(widget.dto);

      setState(() => _isProcessing = false);

      if (res.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Thanh toán ${widget.method} & đặt hàng thành công"),
              backgroundColor: Colors.green,
            ),
          );
          
          // Đợi một chút để đảm bảo thông báo đã được tạo
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Trả về true để báo thành công
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Lỗi: ${res.message}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Lỗi xử lý thanh toán: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getPaymentIcon() {
    switch (widget.method) {
      case "CreditCard":
        return "💳";
      case "Momo":
        return "📱";
      case "BankTransfer":
        return "🏦";
      default:
        return "💰";
    }
  }

  String _getPaymentTitle() {
    switch (widget.method) {
      case "CreditCard":
        return "Thẻ tín dụng";
      case "Momo":
        return "Ví Momo";
      case "BankTransfer":
        return "Chuyển khoản ngân hàng";
      default:
        return widget.method;
    }
  }

  Widget _buildPaymentInfo() {
    switch (widget.method) {
      case "CreditCard":
        return Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: "Số thẻ",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "MM/YY",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "CVV",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        );
      case "Momo":
        return Column(
          children: [
            const Icon(Icons.phone_android, size: 80, color: Colors.pink),
            const SizedBox(height: 16),
            const Text(
              "Quét mã QR hoặc nhập số điện thoại Momo",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: "Số điện thoại Momo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        );
      case "BankTransfer":
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin chuyển khoản:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow("Ngân hàng:", "Vietcombank"),
                  _buildInfoRow("Số tài khoản:", "1234567890"),
                  _buildInfoRow("Chủ tài khoản:", "NHOM 1"),
                  _buildInfoRow("Nội dung:", "DH${DateTime.now().millisecondsSinceEpoch}"),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_getPaymentIcon()} ${_getPaymentTitle()}"),
        backgroundColor: const Color(0xFF00c97b),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Chi tiết thanh toán",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPaymentInfo(),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow("Người nhận:", widget.dto.recipientName),
                              _buildInfoRow("Số điện thoại:", widget.dto.phoneNumber),
                              _buildInfoRow("Địa chỉ:", widget.dto.address),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00c97b),
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Xác nhận thanh toán ${_getPaymentTitle()}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Đang xử lý thanh toán..."),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}