class ApiConstants {
  // 👉 Nếu chạy trên emulator Android thì đổi localhost thành 10.0.2.2
  static const String domain = "10.0.2.2:7245";
  // static const String domain = "172.16.0.110:7245"; // cho device thật cùng WiFi

  // Base URL
  static String baseUrl = "http://$domain/api";

  // API endpoints
  static String productUrl = "$baseUrl/product";
  static String categoryUrl = "$baseUrl/category";
  static String orderUrl = "$baseUrl/order";
  static String brandUrl = "$baseUrl/brand";
  static String authUrl = "$baseUrl/auth"; // thêm cho rõ ràng
}