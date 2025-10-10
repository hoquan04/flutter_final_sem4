class ShipperOrder {
  final int orderId;
  final String? customerName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final double totalAmount;
  final String status; // trạng thái tiếng Việt
  final String paymentStatus;

  ShipperOrder({
    required this.orderId,
    this.customerName,
    this.phoneNumber,
    this.email,
    this.address,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
  });

  factory ShipperOrder.fromJson(Map<String, dynamic> json) {
    // 🪙 Xử lý trạng thái thanh toán
    String paymentStatus = 'Chưa thanh toán';
    final ps = json['paymentStatus']?.toString().toLowerCase();
    if (ps != null) {
      if (ps.contains('paid')) paymentStatus = 'Đã thanh toán';
      else if (ps.contains('pending')) paymentStatus = 'Chờ thanh toán';
      else if (ps.contains('failed')) paymentStatus = 'Thanh toán lỗi';
    }

    // 🚚 Xử lý trạng thái đơn hàng (dịch sang tiếng Việt)
    String status = json['status']?.toString().toLowerCase() ?? '';
    switch (status) {
      case 'pending':
        status = 'Chờ xác nhận';
        break;
      case 'confirmed':
        status = 'Đã xác nhận';
        break;
      case 'shipping':
        status = 'Đang giao hàng';
        break;
      case 'completed':
        status = 'Hoàn tất';
        break;
      case 'cancelled':
      case 'canceled':
        status = 'Đã hủy';
        break;
      default:
        status = 'Không xác định';
    }

    return ShipperOrder(
      orderId: json['orderId'] ?? 0,
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: status,
      paymentStatus: paymentStatus,
    );
  }
}
