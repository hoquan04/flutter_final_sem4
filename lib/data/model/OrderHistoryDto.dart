import 'order.dart';
import 'order_detail.dart';
import 'payment.dart';
import 'shipping.dart';

class OrderHistoryDto {
  final Order order;
  final Shipping? shipping;
  final List<OrderDetail> orderDetails;
  final List<Payment> payments;

  OrderHistoryDto({
    required this.order,
    this.shipping,
    required this.orderDetails,
    required this.payments,
  });

  factory OrderHistoryDto.fromJson(Map<String, dynamic> json) => OrderHistoryDto(
    order: Order.fromJson(json), // đọc trực tiếp gốc
    shipping: json['shipping'] != null ? Shipping.fromJson(json['shipping']) : null,
    orderDetails: (json['orderDetails'] as List<dynamic>?)
        ?.map((e) => OrderDetail.fromJson(e))
        .toList() ?? [],
    payments: (json['payments'] as List<dynamic>?)
        ?.map((e) => Payment.fromJson(e))
        .toList() ?? [],
  );

}
