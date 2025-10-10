import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/repository/notification_repo.dart';
import 'package:flutter_final_sem4/data/service/shipper_service.dart';
import 'package:flutter_final_sem4/ui/cart/cart_page.dart';
import 'package:flutter_final_sem4/ui/dashboard/GroceryGotQuestion.dart';
import 'package:flutter_final_sem4/ui/dashboard/GroceryNotification.dart';
import 'package:flutter_final_sem4/ui/dashboard/grocerySearch.dart';
import 'package:flutter_final_sem4/ui/dashboard/order_history_page.dart';
import 'package:flutter_final_sem4/ui/dashboard/GrocerySaveCart.dart';
import 'package:flutter_final_sem4/ui/dashboard/GroceryStoreLocator.dart';
import 'package:flutter_final_sem4/ui/dashboard/GroceryTermCondition.dart';
import 'package:flutter_final_sem4/ui/dashboard/GroceryTrackOrder.dart';
import 'package:flutter_final_sem4/ui/home/home_page.dart';
import 'package:flutter_final_sem4/ui/profile/profile_page.dart';
import 'package:flutter_final_sem4/ui/favorite/favorite_page.dart';
import 'package:flutter_final_sem4/ui/shipper/shipper_orders_page.dart';
import 'package:flutter_final_sem4/ui/shipper/shipper_register_page.dart';
import 'package:flutter_final_sem4/utils/AppWidget.dart';
import 'package:flutter_final_sem4/utils/GeoceryStrings.dart';
import 'package:flutter_final_sem4/utils/GroceryColors.dart';
import 'package:flutter_final_sem4/utils/GroceryConstant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:async';
class GroceryDashBoardScreen extends StatefulWidget {
  static String tag = '/GroceryDashBoardScreen';

  const GroceryDashBoardScreen({super.key});

  @override
  _GroceryDashBoardScreenState createState() => _GroceryDashBoardScreenState();
}

class _GroceryDashBoardScreenState extends State<GroceryDashBoardScreen>
    with WidgetsBindingObserver {
  int? _userId;
  String? _role; // ✅ role giờ là chuỗi ("Customer", "Shipper", "Admin")
  Timer? _notificationTimer;
  int _unreadNotificationCount = 0;
  TabController? _tabController;
  final NotificationRepository _notificationRepo = NotificationRepository();

  List<String> listText = [];
  List<Widget> listClick = [];

  final List<IconData> listImage = [
    Icons.insert_drive_file,
    Icons.location_on,
    Icons.shopping_cart,
    Icons.store,
    Icons.help,
    Icons.question_answer,
    Icons.delivery_dining,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserIdAndNotifications();
    // 🔁 Auto reload thông báo mỗi 15 giây
    _notificationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && _userId != null) {
        _loadUnreadCount();
      }
    });
  }

  Future<void> _loadUserIdAndNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    _role = prefs.getString('role'); // ✅ đúng, vì bạn đã lưu role dạng String
    // 👈 Lấy role lưu trong SharedPreferences
    debugPrint("👤 UserId = $_userId | Role = $_role");

    if (_userId != null) {
      _loadUnreadCount();
      setState(() {}); // cập nhật lại UI
    }
  }
  Future<void> reloadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    try {
      final shipperService = ShipperService(); // 👈 gọi API trực tiếp
      final newRole = await shipperService.fetchUserRole(userId);

      if (newRole != null) {
        await prefs.setString('role', newRole);
        setState(() {
          _role = newRole; // ✅ giờ _role tồn tại vì đang trong State class
        });
        debugPrint("🔁 Reload role từ API: $_role");
      }
    } catch (e) {
      debugPrint("❌ Lỗi reloadUserRole: $e");
    }
  }


  Future<void> _loadUnreadCount() async {
    if (_userId == null) return;
    final count = await _notificationRepo.getUnreadCount(_userId!);
    if (mounted) {
      setState(() => _unreadNotificationCount = count);
    }
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _tabController?.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
    }
  }

  void _onTabChanged() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      _loadUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    changeStatusColor(grocery_colorPrimary);

    // 🔄 Chưa load role thì hiển thị loading
    if (_role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🧩 Phân quyền giao diện menu
    if (_role == "Shipper") {
      // 🚚 Shipper
      listText = [
        grocery_orderHistory,
        grocery_trackOrders,
        grocery_lbl_save_cart,
        grocery_storeLocator,
        grocery_lbl_Terms_and_Condition,
        grocery_gotQuestion,
        "Đơn hàng giao hàng",
      ];

      listClick = [
        OrderHistoryPage(),
        GroceryTrackOrderScreen(),
        GrocerySaveCart(),
        GroceryStoreLocatorScreen(),
        GroceryTermCondition(),
        GroceryGotQuestionScreen(),
        const ShipperOrdersPage(),
      ];
    } else {
      // 👤 Customer
      listText = [
        grocery_orderHistory,
        grocery_trackOrders,
        grocery_lbl_save_cart,
        grocery_storeLocator,
        grocery_lbl_Terms_and_Condition,
        grocery_gotQuestion,
        "Đăng ký Shipper",
      ];

      listClick = [
        OrderHistoryPage(),
        GroceryTrackOrderScreen(),
        GrocerySaveCart(),
        GroceryStoreLocatorScreen(),
        GroceryTermCondition(),
        GroceryGotQuestionScreen(),
        const ShipperRegisterPage(),
      ];
    }

    // 🧭 Hàm build menu
    Widget mMenuOption(var icon, var value, Widget tag) {
      return SizedBox(
        height: 70,
        child: GestureDetector(
          onTap: () async {
            finish(context);
            // 🚀 Nếu tag là trang đăng ký shipper thì chờ kết quả và reload
            if (tag is ShipperRegisterPage) {
              final result = await tag.launch(context);
              if (result == true) {
                await reloadUserRole(); // ✅ cập nhật lại menu
              }
            } else {
              tag.launch(context);
            }
          },
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: boxDecoration(
                  radius: 25.0,
                  bgColor: grocery_colorPrimary_light,
                ),
                child: Icon(icon, color: grocery_colorPrimary).paddingAll(12),
              ).paddingOnly(
                top: spacing_control,
                left: spacing_standard,
                bottom: spacing_control,
              ),
              text(
                value,
                fontSize: textSizeLargeMedium,
                fontFamily: fontMedium,
              ).paddingOnly(left: spacing_standard, right: spacing_standard),
            ],
          ),
        ),
      );
    }


    // 📋 Drawer menu
    final menu = IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          transitionDuration: const Duration(milliseconds: 400),
          barrierLabel: "Menu",
          barrierColor: Colors.black.withOpacity(0.5),
          pageBuilder: (context, _, __) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  const SizedBox(height: 150),
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Icon(Icons.clear, color: grocery_light_gray_color)
                            .onTap(() {
                          finish(context);
                        }),
                        const SizedBox(width: spacing_large),
                        text(
                          "Cửa hàng nhóm 1",
                          textColor: grocery_Color_black,
                          fontFamily: fontBold,
                          fontSize: textSizeLargeMedium,
                        ),
                      ],
                    ).paddingAll(16),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: spacing_standard),
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: listText.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return mMenuOption(
                          listImage[index],
                          listText[index],
                          listClick[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          transitionBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ).drive(Tween<Offset>(
                begin: const Offset(0, -1.0),
                end: Offset.zero,
              )),
              child: child,
            );
          },
        );
      },
    );

    // 🧭 Layout chính
    return Scaffold(
      backgroundColor: grocery_app_background,
      body: SafeArea(
        child: DefaultTabController(
          length: _role == "Shipper" ? 5 : 4, // ✅ Shipper có 5 tab, còn lại 4 tab
          child: Builder(
            builder: (context) {
              if (_tabController == null) {
                _tabController = DefaultTabController.of(context);
                _tabController?.addListener(_onTabChanged);
              }

              return Scaffold(
                backgroundColor: grocery_app_background,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: grocery_colorPrimary,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          menu,
                          const SizedBox(width: spacing_large),
                          text(
                            "Cửa hàng",
                            textColor: grocery_color_white,
                            fontFamily: fontBold,
                            fontSize: textSizeLargeMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            child: const Icon(Icons.search),
                            onTap: () => GrocerySearch().launch(context),
                          ),
                          const SizedBox(width: spacing_standard_new),
                          GestureDetector(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.notifications),
                                if (_unreadNotificationCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                          minWidth: 16, minHeight: 16),
                                      child: Text(
                                        _unreadNotificationCount > 99
                                            ? '99+'
                                            : _unreadNotificationCount.toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () async {
                              await GroceryNotification().launch(context);
                              _loadUnreadCount();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  bottom: TabBar(
                    indicatorColor: grocery_color_white,
                    tabs: _role == "Shipper"
                        ? const [
                      Tab(icon: Icon(Icons.home)),
                      Tab(icon: Icon(Icons.shopping_basket)),
                      Tab(icon: Icon(Icons.favorite_border)),
                      Tab(icon: Icon(Icons.delivery_dining)), // chỉ shipper có
                      Tab(icon: Icon(Icons.person)),
                    ]
                        : const [
                      Tab(icon: Icon(Icons.home)),
                      Tab(icon: Icon(Icons.shopping_basket)),
                      Tab(icon: Icon(Icons.favorite_border)),
                      Tab(icon: Icon(Icons.person)), // không có tab shipper
                    ],
                  ),
                ),
                body: RefreshIndicator(
                  onRefresh: reloadUserRole,
                  child: _role == "Shipper"
                      ? TabBarView(
                    children: [
                      HomePage(),
                      const CartPage(), // ✅ hoạt động bình thường
                      FavoritePage(),
                      ShipperOrdersPage(),
                      ProfilePage(),
                    ],
                  )
                      : TabBarView(
                    children: [
                      HomePage(),
                      const CartPage(), // ✅ hiển thị đủ nút mua hàng
                      FavoritePage(),
                      ProfilePage(),
                    ],
                  ),
                ),


              );
            },
          ),
        ),
      ),
    );

  }
}
