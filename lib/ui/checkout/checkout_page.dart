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
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _selectedMethod = "CashOnDelivery"; // mặc định
  LatLng? _selectedLocation;
  final _repo = CheckoutRepository();

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

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return; // ❌ Nếu form chưa hợp lệ thì dừng lại
    }

    try {
      final cartIds = widget.selectedItems.map((e) => e.cartId).toList();

      final dto = CheckoutRequestDto(
        userId: widget.selectedItems.first.userId,
        cartIds: cartIds,
        recipientName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text.trim() : null,
        address: _addressCtrl.text.trim(),
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
      } else if (_selectedMethod == "VNPay") {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(dto: dto, method: _selectedMethod),
          ),
        );

        if (result == true) {
          Navigator.pop(context, true); // ✅ báo CheckoutPage cũng hoàn tất
        }

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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            // Họ và tên
            TextFormField(
              controller: _nameCtrl,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDeco("Họ và tên"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "⚠️ Vui lòng nhập họ và tên";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Số điện thoại
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDeco("Số điện thoại"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "⚠️ Vui lòng nhập số điện thoại";
                }
                if (!RegExp(r'^(0|\+84)\d{9,10}$').hasMatch(value)) {
                  return "⚠️ Số điện thoại không hợp lệ";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Email (không bắt buộc)
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDeco("Email (không bắt buộc)"),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "⚠️ Email không hợp lệ";
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Địa chỉ
            TextFormField(
              controller: _addressCtrl,
              decoration: _inputDeco("Địa chỉ giao hàng").copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map, color: Colors.green),
                  onPressed: _openMapPicker,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "⚠️ Vui lòng nhập địa chỉ";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Phương thức thanh toán
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: ["CashOnDelivery", "VNPay"].map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method == "CashOnDelivery" ? "Tiền mặt" : "VNPay"),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedMethod = value);
              },
              decoration: _inputDeco("Phương thức thanh toán"),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // Danh sách sản phẩm
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
                trailing: Text("${(e.price * e.quantity).toStringAsFixed(0)}đ"),
              ),
            ),

            // Tổng tiền + nút đặt hàng
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
                    backgroundColor: const Color(0xFF00c97b),
                  ),
                  child: const Text("Đặt hàng"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
