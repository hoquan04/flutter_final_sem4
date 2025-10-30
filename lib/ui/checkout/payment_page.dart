import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/CheckoutRequestDto.dart';
import 'package:flutter_final_sem4/data/repository/CheckoutRepository.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PaymentPage extends StatefulWidget {
  final CheckoutRequestDto dto;
  final String method;
  final String? paymentUrl; // 👈 thêm

  const PaymentPage({
    super.key,
    required this.dto,
    required this.method,
    this.paymentUrl,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    final url = widget.paymentUrl;

    if (widget.method == "VNPay" && url != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Thanh toán VNPay")),
        body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(url))
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (url) {
                  // 🟢 Thành công
                  if (url.contains("vnp_ResponseCode=00")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ Thanh toán VNPay thành công")),
                    );
                    Navigator.pop(context, true);
                  }

                  // 🔴 Hủy / lỗi
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

    // fallback cho COD (giữ nguyên)
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
