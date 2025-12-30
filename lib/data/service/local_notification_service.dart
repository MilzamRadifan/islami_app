import 'package:islami_app/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  final _notificationService = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) {
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    final result = await _notificationService.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          navigatorKey.currentState
              ?.pushNamed('/local-notification', arguments: response.payload);
        }
      },
    );
    _isInitialized = result ?? false;
  }

  NotificationDetails prayerReminderNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'Prayer Reminder Notification',
        'Prayer Reminder Notification',
        channelDescription: 'Prayer Reminder Notification',
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: true,
        sound: RawResourceAndroidNotificationSound('adzan'),
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    int id = 1,
    String? title,
    String? body,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      year,
      month,
      day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    await _notificationService.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      prayerReminderNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    _notificationService.cancel(id);
  }
}
