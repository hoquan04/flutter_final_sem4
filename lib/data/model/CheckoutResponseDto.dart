class CheckoutResponseDto {
  final bool success;
  final String message;
  final dynamic data; // có thể map sang Order nếu cần

  CheckoutResponseDto({
    required this.success,
    required this.message,
    this.data,
  });

  factory CheckoutResponseDto.fromJson(Map<String, dynamic> json) {
    return CheckoutResponseDto(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'], // nếu muốn parse Order thì thay kiểu ở đây
    );
  }
}
