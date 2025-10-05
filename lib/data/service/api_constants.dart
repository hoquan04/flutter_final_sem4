class ApiConstants {
  // 👉 Nếu chạy trên emulator Android thì đổi localhost thành 10.0.2.2
  //đây là cổng chạy gọi đến api phải là 10.0.2.2 chứ ko được gọi là localhost
  static const String domain = "10.0.2.2:7245";
  // static const String domain = "10.0.2.2:7245"; // cho Android Emulator
  // static const String domain = "172.16.0.110:7245"; // cho device thật cùng WiFi

  // Base URL
  static String baseUrl = "http://$domain/api";

  // Đường dẫn ảnh
  static String sourceImage = "http://$domain";

  // API endpoints
  static String productUrl = "$baseUrl/product";
  static String categoryUrl = "$baseUrl/category";
  static String orderUrl = "$baseUrl/order";
  static String brandUrl = "$baseUrl/brand";

  static String authUrl = "$baseUrl/auth";
  static String paymentUrl = "$baseUrl/payment";
  static String cartUrl = "$baseUrl/cart";
  static String checkoutUrl = "$baseUrl/checkout";

  static String reviewUrl = "$baseUrl/review";
  static String notificationUrl = "$baseUrl/notification";

}


