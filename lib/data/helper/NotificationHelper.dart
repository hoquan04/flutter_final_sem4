import 'package:flutter_final_sem4/data/repository/notification_repo.dart';

/// Helper class để tạo các loại thông báo phổ biến
class NotificationHelper {
  static final NotificationRepository _repo = NotificationRepository();

  /// Thông báo đơn hàng mới
  static Future<bool> notifyNewOrder({
    required int userId,
    required int orderId,
    required String orderCode,
  }) async {
    return await _repo.createNotification(
      userId: userId,
      title: "🛍️ Đơn hàng mới #$orderCode",
      message: "Đơn hàng của bạn đã được tạo thành công. "
          "Chúng tôi sẽ xử lý trong thời gian sớm nhất.",
      type: "Order",
      orderId: orderId,
    );
  }

  /// Thông báo xác nhận đơn hàng
  static Future<bool> notifyOrderConfirmed({
    required int userId,
    required int orderId,
    required String orderCode,
  }) async {
    return await _repo.createNotification(
      userId: userId,
      title: "✅ Đơn hàng #$orderCode đã được xác nhận",
      message: "Đơn hàng của bạn đã được xác nhận và đang được chuẩn bị.",
      type: "Order",
      orderId: orderId,
    );
  }

  /// Thông báo đang giao hàng
  static Future<bool> notifyOrderShipping({
    required int userId,
    required int orderId,
    required String orderCode,
  }) async {
    return await _repo.createNotification(
      userId: userId,
      title: "🚚 Đơn hàng #$orderCode đang được giao",
      message: "Đơn hàng của bạn đang trên đường giao đến. "
          "Vui lòng để ý điện thoại.",
      type: "Shipping",
      orderId: orderId,
    );
  }

  /// Thông báo giao hàng thành công
  static Future<bool> notifyOrderCompleted({
    required int userId,
    required int orderId,
    required String orderCode,
  }) async {
    return await _repo.createNotification(
      userId: userId,
      title: "🎉 Đơn hàng #$orderCode đã giao thành công",
      message: "Đơn hàng của bạn đã được giao thành công. "
          "Cảm ơn bạn đã mua hàng!",
      type: "Order",
      orderId: orderId,
    );
  }

  /// Thông báo đơn hàng bị hủy
  static Future<bool> notifyOrderCancelled({
    required int userId,
    required int orderId,
    required String orderCode,
    String? reason,
  }) async {
    String message = "Đơn hàng #$orderCode đã bị hủy.";
    if (reason != null && reason.isNotEmpty) {
      message += " Lý do: $reason";
    }

    return await _repo.createNotification(
      userId: userId,
      title: "❌ Đơn hàng #$orderCode đã bị hủy",
      message: message,
      type: "Order",
      orderId: orderId,
    );
  }

  /// Thông báo thanh toán thành công
  static Future<bool> notifyPaymentSuccess({
    required int userId,
    required int orderId,
    required String paymentMethod,
    required double amount,
  }) async {
    String message = paymentMethod == "Cash"
        ? "Bạn sẽ thanh toán ${_formatCurrency(amount)} khi nhận hàng."
        : "Đơn hàng của bạn đã được thanh toán thành công với số tiền ${_formatCurrency(amount)}.";

    return await _repo.createNotification(
      userId: userId,
      title: "💳 Thông tin thanh toán",
      message: message,
      type: "Payment",
      orderId: orderId,
    );
  }

  /// Thông báo khuyến mãi
  static Future<bool> notifyPromotion({
    required int userId,
    required String title,
    required String message,
  }) async {
    return await _repo.createNotification(
      userId: userId,
      title: "🎁 $title",
      message: message,
      type: "Promotion",
    );
  }

  /// Thông báo hệ thống
  static Future<bool> notifySystem({
    required int userId,
    required String title,
    required String message,
  }) async {
    return await _repo.createNotification(
      userId: userId,
      title: title,
      message: message,
      type: "System",
    );
  }

  /// Format tiền tệ
  static String _formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}đ";
  }
}