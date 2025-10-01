class OrderDetail {
  final int orderDetailId;
  final int orderId;
  final int productId;
  final String? productName;   // ✅ Thêm
  final String? imageUrl;      // ✅ Thêm
  final int quantity;
  final double unitPrice;
  final double subTotal;
  final DateTime createdDate;

  // Thông tin Order
  final DateTime? orderDate;   // ✅ Thêm
  final String? status;        // ✅ API trả Enum nhưng parse string

  // Thông tin Shipping
  final String? customerName;  // ✅ Thêm
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? postalCode;
  final double? shippingFee;

  // Payment
  final String? paymentStatus; // ✅ thêm

  OrderDetail({
    required this.orderDetailId,
    required this.orderId,
    required this.productId,
    this.productName,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subTotal,
    required this.createdDate,
    this.orderDate,
    this.status,
    this.customerName,
    this.email,
    this.phoneNumber,
    this.address,
    this.city,
    this.postalCode,
    this.shippingFee,
    this.paymentStatus,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
    orderDetailId: json['orderDetailId'],
    orderId: json['orderId'],
    productId: json['productId'],
    productName: json['productName'],
    imageUrl: json['imageUrl'],
    quantity: json['quantity'],
    unitPrice: (json['unitPrice'] as num).toDouble(),
    subTotal: (json['subTotal'] as num).toDouble(),
    createdDate: DateTime.parse(json['createdDate']),
    orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : null,
    status: json['status']?.toString(),
    customerName: json['customerName'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    address: json['address'],
    city: json['city'],
    postalCode: json['postalCode'],
    shippingFee: json['shippingFee']?.toDouble(),
    paymentStatus: json['paymentStatus']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'orderDetailId': orderDetailId,
    'orderId': orderId,
    'productId': productId,
    'productName': productName,
    'imageUrl': imageUrl,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'subTotal': subTotal,
    'createdDate': createdDate.toIso8601String(),
    'orderDate': orderDate?.toIso8601String(),
    'status': status,
    'customerName': customerName,
    'email': email,
    'phoneNumber': phoneNumber,
    'address': address,
    'city': city,
    'postalCode': postalCode,
    'shippingFee': shippingFee,
    'paymentStatus': paymentStatus,
  };
}
