import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/CartDto.dart';
import 'package:flutter_final_sem4/data/model/CheckoutRequestDto.dart';
import 'package:flutter_final_sem4/data/repository/CheckoutRepository.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:flutter_final_sem4/ui/checkout/MapPickerPage.dart';
import 'package:flutter_final_sem4/ui/checkout/payment_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartDto> selectedItems;
  const CheckoutPage({super.key, required this.selectedItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _selectedMethod = "CashOnDelivery"; // mặc định
  LatLng? _selectedLocation;
  final _repo = CheckoutRepository();

  // ✅ Input decoration có viền xanh lá cây
  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green),
      ),
    );
  }

  // ✅ Chọn vị trí trên bản đồ
  Future<void> _openMapPicker() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _addressCtrl.text =
        "Lat: ${result.latitude}, Lng: ${result.longitude}"; // demo
      });
    }
  }

  // ✅ Gọi API checkout
  Future<void> _submitOrder() async {
    if (_nameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng nhập đầy đủ thông tin giao hàng")),
      );
      return;
    }

    try {
      final cartIds = widget.selectedItems.map((e) => e.cartId).toList();

      final dto = CheckoutRequestDto(
        userId: widget.selectedItems.first.userId,
        cartIds: cartIds,
        recipientName: _nameCtrl.text,
        phoneNumber: _phoneCtrl.text,
        email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : null,
        address: _addressCtrl.text,
        city: "not city",
        postalCode: "10000",
        paymentMethod: _selectedMethod,
      );

      if (_selectedMethod == "CashOnDelivery") {
        final res = await _repo.checkout(dto);

        if (res.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ ${res.message}")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ ${res.message}")),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(dto: dto, method: _selectedMethod),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Lỗi đặt hàng: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.selectedItems;
    final total =
    items.fold<double>(0, (sum, e) => sum + (e.price * e.quantity));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Checkout")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          TextField(controller: _nameCtrl, decoration: _inputDeco("Họ và tên")),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: _inputDeco("Số điện thoại"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDeco("Email (không bắt buộc)"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressCtrl,
            decoration: _inputDeco("Địa chỉ giao hàng").copyWith(
              suffixIcon: IconButton(
                icon: const Icon(Icons.map, color: Colors.green),
                onPressed: _openMapPicker,
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedMethod,
            items: ["CashOnDelivery", "CreditCard", "Momo", "BankTransfer"]
                .map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(
                  method == "CashOnDelivery"
                      ? "Tiền mặt"
                      : method == "CreditCard"
                      ? "Thẻ tín dụng"
                      : method == "Momo"
                      ? "Momo"
                      : "Chuyển khoản",
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedMethod = value);
            },
            decoration: _inputDeco("Phương thức thanh toán"),
          ),
          const SizedBox(height: 20),
          const Divider(),
          ...items.map(
                (e) => ListTile(
              leading: e.imageUrl != null
                  ? Image.network(
                ApiConstants.sourceImage + (e.imageUrl ?? ""),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image),
              title: Text(e.productName),
              subtitle: Text("${e.price}đ x ${e.quantity}"),
              trailing:
              Text("${(e.price * e.quantity).toStringAsFixed(0)}đ"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tổng: ${total.toStringAsFixed(0)}đ",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00c97b)),
                child: const Text("Đặt hàng"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
