import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class GroceryTermCondition extends StatefulWidget {
  static String tag = '/GroceryTermCondition';

  const GroceryTermCondition({super.key});

  @override
  _GroceryTermConditionState createState() => _GroceryTermConditionState();
}

class _GroceryTermConditionState extends State<GroceryTermCondition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Điều khoản & Điều kiện',
            style: boldTextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => finish(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Giới thiệu',
                style: boldTextStyle(size: 16, color: Colors.black87)),
            8.height,
            Text(
              'Chào mừng bạn đến với ứng dụng mua sắm Grocery App. '
                  'Bằng việc sử dụng ứng dụng này, bạn đồng ý tuân thủ các điều khoản và điều kiện được nêu dưới đây.',
              style: secondaryTextStyle(size: 15, color: Colors.black54, height: 1.5),
            ),
            20.height,

            Text('2. Sử dụng ứng dụng',
                style: boldTextStyle(size: 16, color: Colors.black87)),
            8.height,
            Text(
              'Người dùng cần đảm bảo rằng mọi thông tin cung cấp khi đăng ký hoặc mua hàng là chính xác. '
                  'Ứng dụng chỉ được sử dụng cho mục đích cá nhân, không thương mại. '
                  'Mọi hành vi gian lận, giả mạo hoặc lạm dụng sẽ bị xử lý theo quy định.',
              style: secondaryTextStyle(size: 15, color: Colors.black54, height: 1.5),
            ),
            20.height,

            Text('3. Quyền sở hữu nội dung',
                style: boldTextStyle(size: 16, color: Colors.black87)),
            8.height,
            Text(
              'Tất cả hình ảnh, biểu tượng, văn bản và nội dung khác trên ứng dụng '
                  'đều thuộc quyền sở hữu của Grocery App hoặc các đối tác được cấp phép. '
                  'Nghiêm cấm sao chép, chỉnh sửa hoặc phân phối mà không có sự đồng ý bằng văn bản.',
              style: secondaryTextStyle(size: 15, color: Colors.black54, height: 1.5),
            ),
            20.height,

            Text('4. Chính sách bảo mật',
                style: boldTextStyle(size: 16, color: Colors.black87)),
            8.height,
            Text(
              'Chúng tôi cam kết bảo mật thông tin cá nhân của bạn. '
                  'Thông tin thu thập chỉ được sử dụng để xử lý đơn hàng, cải thiện dịch vụ '
                  'và không chia sẻ cho bên thứ ba trừ khi có yêu cầu pháp lý.',
              style: secondaryTextStyle(size: 15, color: Colors.black54, height: 1.5),
            ),
            20.height,

            Text('5. Thanh toán và hoàn tiền',
                style: boldTextStyle(size: 16, color: Colors.black87)),
            8.height,
            Text(
              'Chúng tôi hỗ trợ nhiều hình thức thanh toán an toàn như COD, ví Momo và VNPay. '
                  'Trường hợp phát sinh lỗi giao dịch hoặc cần hoàn tiền, vui lòng liên hệ bộ phận hỗ trợ để được xử lý trong vòng 3–5 ngày làm việc.',
              style: secondaryTextStyle(size: 15, color: Colors.black54, height: 1.5),
            ),
            20.height,

            Text('6. Thay đổi điều khoản',
                style: boldTextStyle(size: 16, color: Colors.black87)),
            8.height,
            Text(
              'Chúng tôi có quyền chỉnh sửa, cập nhật điều khoản mà không cần thông báo trước. '
                  'Phiên bản cập nhật sẽ được hiển thị tại trang này, và có hiệu lực ngay khi công bố.',
              style: secondaryTextStyle(size: 15, color: Colors.black54, height: 1.5),
            ),
            20.height,

            Text('7. Liên hệ hỗ trợ',
                style: boldTextStyle(size: 16, color: Colors.black87)),
            8.height,
            Text(
              'Nếu bạn có bất kỳ thắc mắc nào liên quan đến các điều khoản hoặc dịch vụ của chúng tôi, '
                  'vui lòng liên hệ qua email: support@shop.com hoặc hotline 1900 1234 (8h–17h).',
              style: secondaryTextStyle(size: 15, color: Colors.black54, height: 1.5),
            ),
            40.height,

            Center(
              child: Text(
                'Cảm ơn bạn đã tin tưởng và sử dụng dịch vụ của Grocery App 💚',
                style: boldTextStyle(size: 14, color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ),
            16.height,
          ],
        ),
      ),
    );
  }
}
