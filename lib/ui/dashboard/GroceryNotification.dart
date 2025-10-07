import 'package:flutter/material.dart';
import 'package:flutter_final_sem4/data/model/Nofication.dart' as model;
import 'package:flutter_final_sem4/data/repository/notification_repo.dart';
import 'package:flutter_final_sem4/utils/GroceryColors.dart';
import 'package:flutter_final_sem4/utils/AppWidget.dart';
import 'package:flutter_final_sem4/utils/GroceryConstant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class GroceryNotification extends StatefulWidget {
  static String tag = '/GroceryNotification';

  const GroceryNotification({Key? key}) : super(key: key);

  @override
  _GroceryNotificationState createState() => _GroceryNotificationState();
}

class _GroceryNotificationState extends State<GroceryNotification> {
  final NotificationRepository _notificationRepo = NotificationRepository();
  List<model.Notification> notifications = [];
  int unreadCount = 0;
  bool isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    if (userId != null) {
      await _loadNotifications();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadNotifications() async {
    if (userId == null) return;

    setState(() => isLoading = true);

    final data = await _notificationRepo.getNotificationsByUserId(userId!);
    final count = await _notificationRepo.getUnreadCount(userId!);

    setState(() {
      notifications = data;
      unreadCount = count;
      isLoading = false;
    });
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    final success = await _notificationRepo.markAsRead(notificationId);
    if (success) {
      setState(() {
        notifications[index] = model.Notification(
          notificationId: notifications[index].notificationId,
          userId: notifications[index].userId,
          title: notifications[index].title,
          message: notifications[index].message,
          type: notifications[index].type,
          orderId: notifications[index].orderId,
          isRead: true,
          createdAt: notifications[index].createdAt,
          readAt: DateTime.now(),
        );
        if (unreadCount > 0) unreadCount--;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    if (userId == null) return;

    final success = await _notificationRepo.markAllAsRead(userId!);
    if (success) {
      setState(() {
        notifications = notifications.map((n) => model.Notification(
          notificationId: n.notificationId,
          userId: n.userId,
          title: n.title,
          message: n.message,
          type: n.type,
          orderId: n.orderId,
          isRead: true,
          createdAt: n.createdAt,
          readAt: DateTime.now(),
        )).toList();
        unreadCount = 0;
      });
      toast('Đã đánh dấu tất cả là đã đọc');
    }
  }

  Future<void> _deleteNotification(int notificationId, int index) async {
    final success = await _notificationRepo.deleteNotification(notificationId);
    if (success) {
      setState(() {
        if (!notifications[index].isRead && unreadCount > 0) {
          unreadCount--;
        }
        notifications.removeAt(index);
      });
      toast('Đã xóa thông báo');
    }
  }

  Future<void> _deleteAllNotifications() async {
    if (userId == null) return;

    final confirm = await showConfirmDialog(
      context,
      'Bạn có chắc chắn muốn xóa tất cả thông báo?',
      positiveText: 'Xóa',
      negativeText: 'Hủy',
    );

    if (confirm ?? false) {
      final success = await _notificationRepo.deleteAllNotifications(userId!);
      if (success) {
        setState(() {
          notifications.clear();
          unreadCount = 0;
        });
        toast('Đã xóa tất cả thông báo');
      }
    }
  }

  IconData _getNotificationIcon(model.NotificationType type) {
    switch (type) {
      case model.NotificationType.Order:
        return Icons.shopping_bag;
      case model.NotificationType.Payment:
        return Icons.payment;
      case model.NotificationType.Shipping:
        return Icons.local_shipping;
      case model.NotificationType.Promotion:
        return Icons.local_offer;
      case model.NotificationType.System:
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(model.NotificationType type) {
    switch (type) {
      case model.NotificationType.Order:
        return Colors.blue;
      case model.NotificationType.Payment:
        return Colors.green;
      case model.NotificationType.Shipping:
        return Colors.orange;
      case model.NotificationType.Promotion:
        return Colors.red;
      case model.NotificationType.System:
      default:
        return grocery_colorPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grocery_app_background,
      appBar: AppBar(
        backgroundColor: grocery_colorPrimary,
        title: text(
          'Thông báo',
          textColor: grocery_color_white,
          fontFamily: fontBold,
          fontSize: textSizeLargeMedium,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: grocery_color_white),
          onPressed: () => finish(context),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: text(
                'Đọc tất cả',
                textColor: grocery_color_white,
                fontSize: textSizeSMedium,
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: grocery_color_white),
            onSelected: (value) {
              if (value == 'delete_all') {
                _deleteAllNotifications();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Xóa tất cả'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userId == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      text(
                        'Vui lòng đăng nhập để xem thông báo',
                        fontSize: textSizeMedium,
                        textColor: Colors.grey,
                      ),
                    ],
                  ),
                )
              : notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          text(
                            'Chưa có thông báo nào',
                            fontSize: textSizeMedium,
                            textColor: Colors.grey,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          final isUnread = !notification.isRead;

                          return Dismissible(
                            key: Key(notification.notificationId.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _deleteNotification(
                                notification.notificationId,
                                index,
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 0,
                              ),
                              elevation: isUnread ? 2 : 0,
                              color: isUnread
                                  ? grocery_colorPrimary_light.withOpacity(0.3)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                onTap: () {
                                  if (isUnread) {
                                    _markAsRead(
                                      notification.notificationId,
                                      index,
                                    );
                                  }
                                },
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _getNotificationColor(
                                      notification.type,
                                    ).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getNotificationIcon(notification.type),
                                    color: _getNotificationColor(
                                      notification.type,
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: text(
                                        notification.title,
                                        fontFamily: isUnread
                                            ? fontBold
                                            : fontRegular,
                                        fontSize: textSizeMedium,
                                        maxLine: 1,
                                        
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: grocery_colorPrimary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    text(
                                      notification.message,
                                      fontSize: textSizeSMedium,
                                      textColor: Colors.grey[700],
                                      maxLine: 2,
                                      
                                    ),
                                    SizedBox(height: 4),
                                    text(
                                      timeago.format(
                                        notification.createdAt,
                                        locale: 'vi',
                                      ),
                                      fontSize: textSizeSmall,
                                      textColor: Colors.grey,
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _deleteNotification(
                                      notification.notificationId,
                                      index,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}