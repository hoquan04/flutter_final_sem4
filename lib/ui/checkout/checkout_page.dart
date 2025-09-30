import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/ui/checkout/MapPickerPage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _selectedMethod = "Cash"; // mặc định

  // Lưu tọa độ khi chọn trên map
  LatLng? _selectedLocation;

  // Mở màn hình chọn map
  Future<void> _openMapPicker() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapPickerPage(),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _addressCtrl.text =
        "Lat: ${result.latitude}, Lng: ${result.longitude}"; // demo, sau có thể reverse geocoding
      });
    }
  }

  void _submitOrder() {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    // TODO: Gửi API place-order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đặt hàng thành công cho ${_nameCtrl.text}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Họ và tên",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email (không bắt buộc)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _addressCtrl,
              decoration: InputDecoration(
                labelText: "Địa chỉ giao hàng",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _openMapPicker,
                ),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: ["Cash", "CreditCard", "Paypal"].map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedMethod = value);
              },
              decoration: const InputDecoration(
                labelText: "Phương thức thanh toán",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitOrder,
                child: const Text("Đặt hàng"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
