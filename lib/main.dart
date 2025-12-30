import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islami_app/data/model/sholat_reminder_model.dart';
import 'package:islami_app/data/service/local_notification_service.dart';
import 'package:islami_app/presentation/page/sholat_schedule_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService().initNotification();

  await Hive.initFlutter();
  Hive.registerAdapter(SholatReminderModelAdapter());
  await Hive.openBox<SholatReminderModel>('sholat_reminders');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      home: const SholatSchedulePage(),
    );
  }
}
