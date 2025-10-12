import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/repository/shipper_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShipperRegisterPage extends StatefulWidget {
  const ShipperRegisterPage({super.key});

  @override
  State<ShipperRegisterPage> createState() => _ShipperRegisterPageState();
}

class _ShipperRegisterPageState extends State<ShipperRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final repo = ShipperRepository();

  int? userId;
  bool _loading = false;

  File? _frontImage;
  File? _backImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("userId");
    debugPrint("👤 Current logged-in userId = $userId");
    setState(() {});
  }

  Future<void> _pickImage(bool isFront) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(picked.path);
        } else {
          _backImage = File(picked.path);
        }
      });
    }
  }

  Future<void> _register() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Không tìm thấy UserId, vui lòng đăng nhập lại!")),
      );
      return;
    }
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Vui lòng chọn đủ 2 ảnh CCCD!")),
      );
      return;
    }

    setState(() => _loading = true);
    final success = await repo.registerAsShipperWithFiles(
      userId!,
      _frontImage!,
      _backImage!,
    );
    setState(() => _loading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Gửi yêu cầu đăng ký Shipper thành công!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Gửi yêu cầu thất bại!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng ký Shipper"),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📋 Thông tin đăng ký Shipper",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Vui lòng chọn ảnh CCCD (mặt trước và mặt sau). Admin sẽ xét duyệt trước khi tài khoản của bạn trở thành Shipper chính thức.",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // 🪪 Mặt trước
              _buildImagePicker(
                title: "Ảnh CCCD - Mặt trước",
                file: _frontImage,
                onPick: () => _pickImage(true),
              ),
              const SizedBox(height: 20),

              // 🪪 Mặt sau
              _buildImagePicker(
                title: "Ảnh CCCD - Mặt sau",
                file: _backImage,
                onPick: () => _pickImage(false),
              ),
              const SizedBox(height: 40),

              // Nút gửi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text(
                    _loading
                        ? "Đang gửi yêu cầu..."
                        : "Gửi yêu cầu đăng ký",
                    style:
                    const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _loading ? null : _register,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required String title,
    required File? file,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400, width: 1.5),
              color: Colors.grey.shade100,
            ),
            child: file == null
                ? const Center(
                child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey))
                : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(file, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }
}
