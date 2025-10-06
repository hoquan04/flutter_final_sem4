import 'package:flutter_final_sem4/data/model/CheckoutRequestDto.dart';
import 'package:flutter_final_sem4/data/model/CheckoutResponseDto.dart';
import 'package:flutter_final_sem4/data/service/CheckoutService.dart';
import 'package:flutter_final_sem4/data/repository/notification_repo.dart';

class CheckoutRepository {
  final CheckoutService _service = CheckoutService();
  final NotificationRepository _notificationRepo = NotificationRepository();

  Future<CheckoutResponseDto> checkout(CheckoutRequestDto dto) async {
    try {
      // 1. Thực hiện checkout
      final json = await _service.checkout(dto);
      final response = CheckoutResponseDto.fromJson(json);

      // 2. Nếu checkout thành công, tạo thông báo
      if (response.success && response.data != null) {
        // Lấy orderId từ response
        int? orderId;
        
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          orderId = data['orderId'];
        } else if (response.data is int) {
          orderId = response.data as int;
        }

        // Tạo thông báo đơn hàng mới
        await _notificationRepo.createNotification(
          userId: dto.userId,
          title: "Đơn hàng mới",
          message: "Đơn hàng của bạn đã được tạo thành công và đang chờ xử lý.",
          type: "Order",
          orderId: orderId,
        );

        // Tạo thông báo thanh toán
        String paymentTitle = "Thông tin thanh toán";
        String paymentMessage;
        
        switch (dto.paymentMethod) {
          case "CashOnDelivery":
            paymentMessage = "Bạn sẽ thanh toán bằng tiền mặt khi nhận hàng.";
            break;
          case "CreditCard":
            paymentMessage = "Thanh toán bằng thẻ tín dụng đã được xử lý.";
            break;
          case "Momo":
            paymentMessage = "Thanh toán qua Momo đã được xử lý.";
            break;
          case "BankTransfer":
            paymentMessage = "Vui lòng chuyển khoản theo thông tin đã gửi.";
            break;
          default:
            paymentMessage = "Phương thức thanh toán: ${dto.paymentMethod}";
        }

        await _notificationRepo.createNotification(
          userId: dto.userId,
          title: paymentTitle,
          message: paymentMessage,
          type: "Payment",
          orderId: orderId,
        );

        print("✅ Đã tạo thông báo sau khi checkout thành công");
      }

      return response;
    } catch (e) {
      print("❌ Checkout error: $e");
      rethrow;
    }
  }
}