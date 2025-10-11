import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_final_sem4/data/repository/auth_repo.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  bool isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Regex email khá “an toàn” trong app
  final _emailRe = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');

  InputDecoration _inputStyle(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  Future<void> _submit() async {
    // Validate tất cả field trước khi gọi API
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng sửa lỗi ở các trường được bôi đỏ")),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await AuthRepository().register(
      firstName: firstNameCtrl.text.trim(),
      lastName:  lastNameCtrl.text.trim(),
      email:     emailCtrl.text.trim(),
      // Chỉ lấy số cho chắc
      phone:     phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
      address:   addressCtrl.text.trim(),
      password:  passwordCtrl.text.trim(),
      confirmPassword: confirmPasswordCtrl.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đăng ký thành công")),
      );
      if (mounted) Navigator.pushReplacementNamed(context, "/login");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Đăng ký thất bại, kiểm tra lại thông tin")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Đăng ký"), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Tạo tài khoản mới",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // First name
              TextFormField(
                controller: firstNameCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: _inputStyle("First Name", Icons.person),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Bắt buộc" : null,
              ),
              const SizedBox(height: 15),

              // Last name
              TextFormField(
                controller: lastNameCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: _inputStyle("Last Name", Icons.person_outline),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Bắt buộc" : null,
              ),
              const SizedBox(height: 15),

              // Email
              TextFormField(
                controller: emailCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: _inputStyle("Email", Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final value = v?.trim() ?? "";
                  if (value.isEmpty) return "Bắt buộc";
                  if (!_emailRe.hasMatch(value)) return "Email không đúng định dạng";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Phone (chỉ 10 số)
              TextFormField(
                controller: phoneCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: _inputStyle("Số điện thoại (10 số)", Icons.phone),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  final digits = (v ?? "").replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.isEmpty) return "Bắt buộc";
                  if (!RegExp(r'^\d{10}$').hasMatch(digits)) return "Số điện thoại phải gồm đúng 10 chữ số";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Address
              TextFormField(
                controller: addressCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: _inputStyle("Địa chỉ", Icons.location_on),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Bắt buộc" : null,
              ),
              const SizedBox(height: 15),

              // Password
              TextFormField(
                controller: passwordCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: _obscurePass,
                decoration: _inputStyle(
                  "Mật khẩu (>= 6 ký tự)",
                  Icons.lock,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (v) {
                  final value = v?.trim() ?? "";
                  if (value.isEmpty) return "Bắt buộc";
                  if (value.length < 6) return "Tối thiểu 6 ký tự";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Confirm password
              TextFormField(
                controller: confirmPasswordCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: _obscureConfirm,
                decoration: _inputStyle(
                  "Xác nhận mật khẩu",
                  Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (v) {
                  if ((v ?? "").trim().isEmpty) return "Bắt buộc";
                  if (v!.trim() != passwordCtrl.text.trim()) return "Mật khẩu không khớp";
                  return null;
                },
              ),

              const SizedBox(height: 25),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text("Đăng ký", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
                child: const Text("Đã có tài khoản? Đăng nhập",
                    style: TextStyle(color: Colors.green, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
