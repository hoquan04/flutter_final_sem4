import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/images/grocery/Grocery_ic_User.png"),
            ),

            const SizedBox(height: 10),
            const Text(
              "Nguyễn Văn A",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "nguyenvana@example.com",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Danh sách tuỳ chọn
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Order History"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: chuyển sang OrderHistoryScreen
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Saved Addresses"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: chuyển sang trang địa chỉ
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: chuyển sang Settings
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: xử lý logout
              },
            ),
          ],
        ),
      ),
    );
  }
}
