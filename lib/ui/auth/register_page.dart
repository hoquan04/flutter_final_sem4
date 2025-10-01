import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/repository/auth_repo.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    final firstName = firstNameCtrl.text.trim();
    final lastName = lastNameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final address = addressCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    final confirmPassword = confirmPasswordCtrl.text.trim();

    if ([firstName, lastName, email, phone, address, password, confirmPassword]
        .any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await AuthRepository().register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      address: address,
      password: password,
      confirmPassword: confirmPassword,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đăng ký thành công")),
      );
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Đăng ký thất bại, thử lại sau")),
      );
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đăng ký"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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

            TextField(controller: firstNameCtrl, decoration: _inputStyle("First Name", Icons.person)),
            const SizedBox(height: 15),
            TextField(controller: lastNameCtrl, decoration: _inputStyle("Last Name", Icons.person_outline)),
            const SizedBox(height: 15),
            TextField(controller: emailCtrl, decoration: _inputStyle("Email", Icons.email)),
            const SizedBox(height: 15),
            TextField(controller: phoneCtrl, decoration: _inputStyle("Số điện thoại", Icons.phone)),
            const SizedBox(height: 15),
            TextField(controller: addressCtrl, decoration: _inputStyle("Địa chỉ", Icons.location_on)),
            const SizedBox(height: 15),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: _inputStyle("Mật khẩu", Icons.lock),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmPasswordCtrl,
              obscureText: true,
              decoration: _inputStyle("Xác nhận mật khẩu", Icons.lock_outline),
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
              onPressed: register,
              child: const Text("Đăng ký", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
              child: const Text(
                "Đã có tài khoản? Đăng nhập",
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
