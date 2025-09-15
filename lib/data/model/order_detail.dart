class OrderDetail {
  final int orderDetailId;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subTotal;
  final DateTime createdDate;

  OrderDetail({
    required this.orderDetailId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subTotal,
    required this.createdDate,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
    orderDetailId: json['orderDetailId'],
    orderId: json['orderId'],
    productId: json['productId'],
    quantity: json['quantity'],
    unitPrice: json['unitPrice']?.toDouble(),
    subTotal: json['subTotal']?.toDouble(),
    createdDate: DateTime.parse(json['createdDate']),
  );

  Map<String, dynamic> toJson() => {
    'orderDetailId': orderDetailId,
    'orderId': orderId,
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'subTotal': subTotal,
    'createdDate': createdDate.toIso8601String(),
  };
}
