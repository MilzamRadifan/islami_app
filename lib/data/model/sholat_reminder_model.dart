import 'package:hive_flutter/hive_flutter.dart';

part 'sholat_reminder_model.g.dart';

@HiveType(typeId: 1)
class SholatReminderModel extends HiveObject {
  @HiveField(0)
  late String cityName;

  @HiveField(1)
  late Map<String, bool> prayerReminders;

  SholatReminderModel({
    required this.cityName,
    required this.prayerReminders,
  });
}
