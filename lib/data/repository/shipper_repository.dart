import 'package:flutter_final_sem4/data/model/ShipperOrder.dart';
import 'package:flutter_final_sem4/data/service/shipper_service.dart';
import 'dart:io';

class ShipperRepository {
  final ShipperService _service = ShipperService();

  /// 🪪 Gửi yêu cầu đăng ký shipper
  Future<bool> registerAsShipperWithFiles(
      int userId, File frontFile, File backFile) async {
    try {
      final result = await _service.registerShipperWithFiles(userId, frontFile, backFile);
      print("✅ ${result['message'] ?? 'Đăng ký thành công'}");
      return true;
    } catch (e) {
      print("❌ Lỗi khi đăng ký Shipper: $e");
      return false;
    }
  }


  /// 📦 Lấy danh sách đơn có thể nhận
  Future<List<ShipperOrder>> getAvailableOrders() async {
    try {
      final orders = await _service.getAvailableOrders();
      print("📦 Có ${orders.length} đơn hàng có thể nhận");
      return orders;
    } catch (e) {
      print("❌ Lỗi khi tải đơn khả dụng: $e");
      return [];
    }
  }

  /// 🚚 Lấy danh sách đơn hàng của shipper
  Future<List<ShipperOrder>> getMyOrders(int shipperId) async {
    try {
      final orders = await _service.getMyOrders(shipperId);
      print("🚚 Shipper có ${orders.length} đơn của mình");
      return orders;
    } catch (e) {
      print("❌ Lỗi khi tải đơn của shipper: $e");
      return [];
    }
  }

  /// 📬 Nhận đơn hàng
  Future<void> assignOrder(int orderId, int shipperId) async {
    try {
      await _service.assignOrder(orderId, shipperId);
      print("✅ Nhận đơn #$orderId thành công!");
    } catch (e) {
      print("❌ Lỗi khi nhận đơn hàng: $e");
    }
  }

  /// ✅ Hoàn tất giao hàng
  Future<void> completeOrder(int orderId, int shipperId) async {
    try {
      final result = await _service.completeOrder(orderId);
      print("✅ ${result['message'] ?? 'Hoàn tất đơn hàng thành công'}");
    } catch (e) {
      print("❌ Lỗi khi hoàn tất đơn hàng: $e");
    }
  }

}
