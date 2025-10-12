enum PaymentMethod { CashOnDelivery, CreditCard, Momo, BankTransfer }
enum PaymentStatus { Pending, Paid, Failed }

class Payment {
  final int paymentId;
  final int orderId;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime? paidAt;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    paymentId: json['paymentId'],
    orderId: json['orderId'],
    paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.toString().split('.').last == json['paymentMethod']),
    paymentStatus: PaymentStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['paymentStatus']),
    createdAt: DateTime.parse(json['createdAt']),
    paidAt:
    json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
  );

  Map<String, dynamic> toJson() => {
    'paymentId': paymentId,
    'orderId': orderId,
    'paymentMethod': paymentMethod.toString().split('.').last,
    'paymentStatus': paymentStatus.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
    'paidAt': paidAt?.toIso8601String(),
  };
}
