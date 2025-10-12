import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class GroceryGotQuestionScreen extends StatefulWidget {
  static String tag = '/GroceryGotQuestionScreen';

  const GroceryGotQuestionScreen({super.key});

  @override
  _GroceryGotQuestionScreenState createState() =>
      _GroceryGotQuestionScreenState();
}

class _GroceryGotQuestionScreenState extends State<GroceryGotQuestionScreen> {
  final List<Map<String, String>> faqs = [
    {
      'question': '1. Làm thế nào để đặt hàng?',
      'answer':
      'Bạn có thể chọn sản phẩm, thêm vào giỏ hàng và bấm "Thanh toán". Sau đó nhập thông tin người nhận và chọn phương thức thanh toán phù hợp.'
    },
    {
      'question': '2. Tôi có thể hủy đơn hàng không?',
      'answer':
      'Bạn chỉ có thể hủy đơn hàng khi đơn chưa được xác nhận. Vui lòng liên hệ bộ phận hỗ trợ để được giúp đỡ.'
    },
    {
      'question': '3. Tôi có thể thanh toán bằng phương thức nào?',
      'answer':
      'Chúng tôi hỗ trợ thanh toán khi nhận hàng (COD), ví Momo, và cổng thanh toán VNPay.'
    },
    {
      'question': '4. Bao lâu thì tôi nhận được hàng?',
      'answer':
      'Thông thường 2–5 ngày làm việc tùy khu vực. Các đơn nội thành sẽ giao nhanh hơn.'
    },
    {
      'question': '5. Liên hệ hỗ trợ bằng cách nào?',
      'answer':
      'Bạn có thể gửi email đến support@shop.com hoặc gọi hotline 1900 1234 trong giờ hành chính.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Câu hỏi thường gặp',
            style: boldTextStyle(color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => finish(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 1,
            child: ExpansionTile(
              iconColor: Colors.green,
              collapsedIconColor: Colors.grey,
              title: Text(
                faq['question']!,
                style: boldTextStyle(size: 16, color: Colors.black87),
              ),
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    faq['answer']!,
                    style: secondaryTextStyle(color: Colors.black54, size: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
