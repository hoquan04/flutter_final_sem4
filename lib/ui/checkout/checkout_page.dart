import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/CartDto.dart';
import 'package:flutter_final_sem4/data/model/CheckoutRequestDto.dart';
import 'package:flutter_final_sem4/data/repository/CheckoutRepository.dart';
import 'package:flutter_final_sem4/data/service/api_constants.dart';
import 'package:flutter_final_sem4/ui/checkout/MapPickerPage.dart';
import 'package:flutter_final_sem4/ui/checkout/payment_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _selectedMethod = "CashOnDelivery";
  LatLng? _selectedLocation;
  final _repo = CheckoutRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Tự động load thông tin user từ SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('fullName');
    final email = prefs.getString('email');
    
    if (fullName != null && fullName.isNotEmpty) {
      _nameCtrl.text = fullName;
    }
    if (email != null && email.isNotEmpty) {
      _emailCtrl.text = email;
    }
  }

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
            "Lat: ${result.latitude}, Lng: ${result.longitude}";
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_nameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Vui lòng nhập đầy đủ thông tin giao hàng"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cartIds = widget.selectedItems.map((e) => e.cartId).toList();

      final dto = CheckoutRequestDto(
        userId: widget.selectedItems.first.userId,
        cartIds: cartIds,
        recipientName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
        address: _addressCtrl.text.trim(),
        city: "not city",
        postalCode: "10000",
        paymentMethod: _selectedMethod,
      );

      if (_selectedMethod == "CashOnDelivery") {
        final res = await _repo.checkout(dto);

        setState(() => _isLoading = false);

        if (res.success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("✅ ${res.message}"),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Đợi một chút để đảm bảo thông báo đã được tạo
            await Future.delayed(const Duration(milliseconds: 500));
            
            // Quay lại và báo thành công
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ ${res.message}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        setState(() => _isLoading = false);
        
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentPage(dto: dto, method: _selectedMethod),
          ),
        );
        
        // Nếu payment page trả về success
        if (result == true && mounted) {
          // Đợi một chút để đảm bảo thông báo đã được tạo
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Lỗi đặt hàng: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.selectedItems;
    final total =
        items.fold<double>(0, (sum, e) => sum + (e.price * e.quantity));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: const Color(0xFF00c97b),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const Text(
                "Thông tin giao hàng",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: _inputDeco("Họ và tên *"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _inputDeco("Số điện thoại *"),
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
                maxLines: 2,
                decoration: _inputDeco("Địa chỉ giao hàng *").copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map, color: Colors.green),
                    onPressed: _openMapPicker,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                items: [
                  "CashOnDelivery",
                  "CreditCard",
                  "Momo",
                  "BankTransfer"
                ].map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(
                      method == "CashOnDelivery"
                          ? "💵 Tiền mặt"
                          : method == "CreditCard"
                              ? "💳 Thẻ tín dụng"
                              : method == "Momo"
                                  ? "📱 Momo"
                                  : "🏦 Chuyển khoản",
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedMethod = value);
                },
                decoration: _inputDeco("Phương thức thanh toán"),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              const Text(
                "Sản phẩm đã chọn",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...items.map(
                (e) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: e.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              ApiConstants.sourceImage + (e.imageUrl ?? ""),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 50),
                            ),
                          )
                        : const Icon(Icons.image, size: 50),
                    title: Text(
                      e.productName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      "${e.price.toStringAsFixed(0)}đ x ${e.quantity}",
                    ),
                    trailing: Text(
                      "${(e.price * e.quantity).toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tổng cộng:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${total.toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00c97b),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Đặt hàng",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Đang xử lý đơn hàng..."),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }
}