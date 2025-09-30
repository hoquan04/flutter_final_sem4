// import 'package:flutter/material.dart';
// import 'package:flutter_final_sem4/ui/dashboard/dashboard_page.dart';
// import 'package:flutter_final_sem4/ui/home/home_page.dart';
// import 'package:flutter_final_sem4/ui/product_detail/TestProductDetailPage.dart';
// import 'package:flutter_final_sem4/ui/review/reviewPage.dart';



// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const TestProductDetailPage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/ui/auth/login_page.dart';
import 'package:flutter_final_sem4/ui/auth/register_page.dart';
import 'package:flutter_final_sem4/ui/dashboard/dashboard_page.dart';
import 'package:flutter_final_sem4/ui/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Shop Online",
      // Khi chạy app sẽ hiển thị login trước
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/home": (context) => const HomePage(),
        "/dashboard": (context) => GroceryDashBoardScreen(),
      },
    );
  }
}
