class CheckoutRequestDto {
  final int userId;
  final List<int> cartIds;
  final String recipientName;
  final String phoneNumber;
  final String? email;
  final String address;
  final String? city;
  final String? postalCode;
  final String paymentMethod; // enum dạng string

  CheckoutRequestDto({
    required this.userId,
    required this.cartIds,
    required this.recipientName,
    required this.phoneNumber,
    this.email,
    required this.address,
    this.city,
    this.postalCode,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "cartIds": cartIds,
    "recipientName": recipientName,
    "phoneNumber": phoneNumber,
    "email": email,
    "address": address,
    "city": city,
    "postalCode": postalCode,
    "paymentMethod": paymentMethod, // phải match enum backend
  };
}
