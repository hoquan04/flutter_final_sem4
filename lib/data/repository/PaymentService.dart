import 'package:flutter_final_sem4/data/model/payment.dart';
import 'package:flutter_final_sem4/data/service/PaymentService.dart';


class PaymentRepository {
  final PaymentService _service = PaymentService();

  Future<void> fetchAndPrint() async {
    try {
      List<Payment> payments = await _service.getAllPayments();
      for (var p in payments) {
        print("${p.paymentId} - Order: ${p.orderId} - ${p.paymentMethod} - ${p.paymentStatus}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> createAndPrint() async {
    try {
      Payment newPay = await _service.createPayment(1, "Cash");
      print("Created checkout: ${newPay.paymentId} - ${newPay.paymentStatus}");
    } catch (e) {
      print("Error: $e");
    }
  }
}
