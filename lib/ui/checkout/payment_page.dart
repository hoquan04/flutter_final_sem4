import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/CheckoutRequestDto.dart';
import 'package:flutter_final_sem4/data/repository/CheckoutRepository.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final CheckoutRequestDto dto;
  final String method;

  const PaymentPage({super.key, required this.dto, required this.method});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _repo = CheckoutRepository();
  String? _paymentUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    final res = await _repo.checkout(widget.dto);

    if (res.success && res.data != null) {
      if (widget.method == "VNPay" && res.data["paymentUrl"] != null) {
        setState(() {
          _paymentUrl = res.data["paymentUrl"];
          _loading = false;
        });
      } else {
        // Trường hợp COD hoặc method khác
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Thanh toán ${widget.method} thành công")),
        );
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi: ${res.message ?? "Thanh toán thất bại"}")),
      );
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && widget.method == "VNPay") {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Nếu là VNPay → mở WebView
    if (widget.method == "VNPay" && _paymentUrl != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Thanh toán VNPay")),
        body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(_paymentUrl!))
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (url) {
                  // 🟢 Nếu callback thành công
                  if (url.contains("vnp_ResponseCode=00")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ Thanh toán VNPay thành công")),
                    );
                    Navigator.pop(context, true);
                  }

                  // 🔴 Nếu user cancel hoặc lỗi
                  else if (url.contains("vnp_ResponseCode=24") ||
                      url.contains("vnp_ResponseCode=99")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("❌ Thanh toán bị hủy hoặc thất bại")),
                    );
                    Navigator.pop(context, false);
                  }
                },
              ),

            ),
        ),
      );
    }

    // Nếu là COD hoặc method khác → chỉ cần xác nhận
    return Scaffold(
      appBar: AppBar(title: Text("Thanh toán ${widget.method}")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Xác nhận thanh toán ${widget.method}"),
        ),
      ),
    );
  }
}
