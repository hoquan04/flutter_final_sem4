class Shipping {
  final int shippingId;
  final String recipientName;
  final String phoneNumber;
  final String? email;
  final String address;
  final String? city;
  final String? postalCode;
  final double? shippingFee;
  final int? estimatedDays;

  Shipping({
    required this.shippingId,
    required this.recipientName,
    required this.phoneNumber,
    this.email,
    required this.address,
    this.city,
    this.postalCode,
    this.shippingFee,
    this.estimatedDays,
  });

  factory Shipping.fromJson(Map<String, dynamic> json) => Shipping(
    shippingId: json['shippingId'],
    recipientName: json['recipientName'] ?? '',
    phoneNumber: json['phoneNumber'] ?? '',
    email: json['email'],
    address: json['address'] ?? '',
    city: json['city'],
    postalCode: json['postalCode'],
    shippingFee: json['shippingFee']?.toDouble(),
    estimatedDays: json['estimatedDays'],
  );

  Map<String, dynamic> toJson() => {
    'shippingId': shippingId,
    'recipientName': recipientName,
    'phoneNumber': phoneNumber,
    'email': email,
    'address': address,
    'city': city,
    'postalCode': postalCode,
    'shippingFee': shippingFee,
    'estimatedDays': estimatedDays,
  };
}
