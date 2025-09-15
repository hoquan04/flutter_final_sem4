enum OrderStatus { Pending, Confirmed, Shipping, Completed, Cancelled }

class Order {
  final int orderId;
  final int userId;
  final DateTime orderDate;
  final OrderStatus status;
  final double totalAmount;
  final int shippingId;

  Order({
    required this.orderId,
    required this.userId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.shippingId,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    orderId: json['orderId'],
    userId: json['userId'],
    orderDate: DateTime.parse(json['orderDate']),
    status: OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status']),
    totalAmount: json['totalAmount']?.toDouble(),
    shippingId: json['shippingId'],
  );

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'userId': userId,
    'orderDate': orderDate.toIso8601String(),
    'status': status.toString().split('.').last,
    'totalAmount': totalAmount,
    'shippingId': shippingId,
  };
}
