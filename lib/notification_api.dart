import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

class NotificationApi{

  static final notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future notificationDetails() async{
    return NotificationDetails(
      android: AndroidNotificationDetails(
          'channel id',
          'channel name',
        importance: Importance.max,
      ),
      iOS: DarwinNotificationDetails (),
    );
  }

  static Future init({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android,iOS: iOS);
    await notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) async{
        onNotifications.add(payload as String?); //////////////////
      },
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,

    }) async =>
      notifications.show(
          id,
          title,
          body,
          (await notificationDetails) as NotificationDetails?, /////////////////
        payload: payload,
      );


}