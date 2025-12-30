import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:islami_app/data/model/schedule_model.dart';
import 'package:islami_app/data/model/sholat_reminder_model.dart';
import 'package:islami_app/data/model/weton_result_model.dart';
import 'package:islami_app/data/service/javanesse_calendar_service.dart';
import 'package:islami_app/data/service/local_notification_service.dart';
import 'package:islami_app/data/service/sholat_service.dart';
import 'package:islami_app/presentation/bloc/sholat/sholat_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class SholatSchedulePage extends StatelessWidget {
  const  SholatSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localNotificationService = LocalNotificationService();
    localNotificationService.initNotification();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jadwal Sholat',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: BlocProvider(
        create: (context) =>
            SholatBloc(SholatService())..add(GetCurrentLocationEvent()),
        child: SholatView(localNotificationService: localNotificationService),
      ),
    );
  }
}

class SholatView extends StatefulWidget {
  final LocalNotificationService localNotificationService;

  const SholatView({super.key, required this.localNotificationService});

  @override
  State<SholatView> createState() => _SholatViewState();
}

class _SholatViewState extends State<SholatView> {
  final SholatService _sholatService = SholatService();
  final String _currentDate = DateTime.now().toIso8601String().split('T')[0];

  final Map<String, bool> _prayerReminderToggles = {
    'Imsak': false,
    'Subuh': false,
    'Terbit': false,
    'Dhuha': false,
    'Dzuhur': false,
    'Ashar': false,
    'Maghrib': false,
    'Isya': false,
  };

  double? _latitude;
  double? _longitude;
  bool _compassPermission = false;
  WetonResultModel? _wetonResult;

  @override
  void initState() {
    super.initState();
    _fetchCompassPermission();
    initializeDateFormatting('id_ID', null).then((_) {
      if (mounted) {
        setState(() {
          _wetonResult = JavanesseCalendarService.hitungWeton(DateTime.now());
        });
      }
    });
  }

  String _getNextPrayerTime(PrayerSchedule schedule) {
    final now = DateTime.now();
    final times = {
      'Imsak': _parseTime(schedule.imsak, now),
      'Subuh': _parseTime(schedule.subuh, now),
      'Terbit': _parseTime(schedule.terbit, now),
      'Dhuha': _parseTime(schedule.dhuha, now),
      'Dzuhur': _parseTime(schedule.dzuhur, now),
      'Ashar': _parseTime(schedule.ashar, now),
      'Maghrib': _parseTime(schedule.maghrib, now),
      'Isya': _parseTime(schedule.isya, now),
    };

    final upcomingTimes = times.entries
        .where((entry) => entry.value.isAfter(now))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    if (upcomingTimes.isNotEmpty) {
      return '${upcomingTimes.first.key} (${upcomingTimes.first.value.hour}:${upcomingTimes.first.value.minute.toString().padLeft(2, '0')})';
    }
    return 'Tidak ada sholat mendatang hari ini';
  }

  DateTime _parseTime(String time, DateTime date) {
    final parts = time.split(':');
    return DateTime(date.year, date.month, date.day,
        int.tryParse(parts[0]) ?? 0, int.tryParse(parts[1]) ?? 0);
  }

  void _rescheduleNotifications(
      PrayerSchedule schedule, String cityName, Map<String, bool> reminders) {
    final now = DateTime.now();
    final prayerTimes = {
      'Imsak': schedule.imsak,
      'Subuh': schedule.subuh,
      'Terbit': schedule.terbit,
      'Dhuha': schedule.dhuha,
      'Dzuhur': schedule.dzuhur,
      'Ashar': schedule.ashar,
      'Maghrib': schedule.maghrib,
      'Isya': schedule.isya,
    };

    reminders.forEach((prayerName, isEnabled) {
      final prayerTimeStr = prayerTimes[prayerName];
      if (prayerTimeStr == null) return;

      final prayerTime = _parseTime(prayerTimeStr, now);
      final notificationId = '${prayerName}_${schedule.date}'.hashCode;
      widget.localNotificationService.cancelNotification(notificationId);

      if (isEnabled && prayerTime.isAfter(now)) {
        widget.localNotificationService.scheduleNotification(
          id: notificationId,
          title: 'Waktu Sholat $prayerName',
          body: 'Sudah waktunya untuk sholat $prayerName di $cityName!',
          year: prayerTime.year,
          month: prayerTime.month,
          day: prayerTime.day,
          hour: prayerTime.hour,
          minute: prayerTime.minute,
        );
      }
    });
  }

  final double meccaLat = 21.4225;
  final double meccaLon = 39.8262;

  double _calculateQiblaDirection(double userLat, double userLon) {
    const double rad = math.pi / 180;
    final double lat1 = userLat * rad;
    final double lon1 = userLon * rad;
    final double lat2 = meccaLat * rad;
    final double lon2 = meccaLon * rad;
    final double dLon = lon2 - lon1;
    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    double bearing = math.atan2(y, x) / rad;
    if (bearing < 0) bearing += 360;
    return bearing;
  }

  void _fetchCompassPermission() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _compassPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  Future<void> _showCompassDialog(BuildContext context) async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Lokasi tidak ditemukan. Harap perbarui lokasi Anda terlebih dahulu.'),
        ),
      );
      return;
    }
    if (_compassPermission) {
      final double qiblaDirection =
          _calculateQiblaDirection(_latitude!, _longitude!);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Arah Kiblat'),
            content: SizedBox(
              width: 250,
              height: 250,
              child: StreamBuilder<CompassEvent>(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error reading heading: ${snapshot.error}');
                  }
                  double? direction = snapshot.data?.heading;
                  if (direction == null) {
                    return const Center(
                      child: Text("Perangkat tidak memiliki sensor kompas!"),
                    );
                  }
                  return Center(
                    child: Transform.rotate(
                      angle:
                          ((direction - qiblaDirection) * (math.pi / 180) * -1),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 200,
                        color: Colors.teal,
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          );
        },
      );
    } else {
      final status = await Permission.location.request();
      if (mounted) {
        setState(() {
          _compassPermission = (status == PermissionStatus.granted);
        });
        if (_compassPermission) {
          _showCompassDialog(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Izin lokasi ditolak. Buka pengaturan untuk mengizinkan.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(color: Colors.teal),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<SholatBloc, SholatState>(
                builder: (context, state) {
                  String cityName = 'Mencari lokasi...';
                  String nextPrayer = '';
                  if (state is SholatCityNameLoaded) {
                    cityName = state.cityName;
                  } else if (state is SholatCityLoaded) {
                    cityName = state.cityName;
                  } else if (state is SholatScheduleLoaded) {
                    cityName = state.cityName;
                    nextPrayer = _getNextPrayerTime(state.schedule);
                  } else if (state is SholatFailed) {
                    cityName = 'Gagal memuat lokasi';
                  }
                  return Column(
                    children: [
                      Text(
                        '📍$cityName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nextPrayer.isEmpty
                            ? 'Memuat jadwal...'
                            : 'Sholat berikutnya: $nextPrayer',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<SholatBloc>().add(GetCurrentLocationEvent());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Memperbarui lokasi...')),
                      );
                    },
                    icon: const Icon(Icons.gps_fixed, color: Colors.teal),
                    label: const Text(
                      'Update Lokasi',
                      style: TextStyle(color: Colors.teal),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showCompassDialog(context);
                    },
                    icon: const Icon(Icons.compass_calibration_sharp,
                        color: Colors.teal),
                    label: const Text(
                      'Arah Kiblat',
                      style: TextStyle(color: Colors.teal),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: BlocBuilder<SholatBloc, SholatState>(
                    builder: (context, state) {
                      String hijriDate = 'Memuat tanggal Hijriah...';
                      String day = '';
                      if (state is SholatScheduleLoaded) {
                        hijriDate = state.hijriDate;
                        day = state.day;
                      } else if (state is SholatFailed &&
                          state.message.contains('Hijriah')) {
                        hijriDate = state.message;
                      }
                      final String formattedGregorianDate =
                          DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                              .format(DateTime.now());
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            formattedGregorianDate,
                            style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state is SholatFailed &&
                                    state.message.contains('Hijriah')
                                ? hijriDate
                                : '$day, $hijriDate',
                            style: TextStyle(
                              color: state is SholatFailed &&
                                      state.message.contains('Hijriah')
                                  ? Colors.redAccent
                                  : Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (_wetonResult != null)
                            Text(
                              '${_wetonResult!.weton}, ${_wetonResult!.tanggalJawa}',
                              style: const TextStyle(color: Colors.teal),
                              textAlign: TextAlign.center,
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocConsumer<SholatBloc, SholatState>(
              listener: (context, state) {
                if (state is SholatLocationLoaded) {
                  setState(() {
                    _latitude = state.position.latitude;
                    _longitude = state.position.longitude;
                  });
                } else if (state is SholatCityLoaded) {
                  context.read<SholatBloc>().add(FetchPrayerSchedule(
                      state.cityName, state.cityId, _currentDate));
                } else if (state is SholatScheduleLoaded) {
                  setState(() {
                    if (state.prayerReminders.isNotEmpty) {
                      _prayerReminderToggles.clear();
                      _prayerReminderToggles.addAll(state.prayerReminders);
                    } else {
                      _prayerReminderToggles.updateAll((key, value) => false);
                    }
                  });
                  _rescheduleNotifications(
                      state.schedule, state.cityName, _prayerReminderToggles);
                } else if (state is SholatFailed &&
                    !state.message.contains('Hijriah')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is SholatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SholatLocationLoaded) {
                  return const Center(
                    child: Text(
                      'Mendapatkan lokasi pengguna...',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (state is SholatCityNameLoaded) {
                  return Center(
                    child: Text(
                      'Kota ditemukan: ${state.cityName}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (state is SholatCityLoaded) {
                  return Center(
                    child: Text(
                      'Kota ditemukan: ${state.cityName}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (state is SholatScheduleLoaded) {
                  return ListView(
                    children: [
                      _buildPrayerCard(Icons.nightlight, 'Imsak',
                          state.schedule.imsak, state.schedule, state.cityName),
                      _buildPrayerCard(Icons.nights_stay, 'Subuh',
                          state.schedule.subuh, state.schedule, state.cityName),
                      _buildPrayerCard(
                          Icons.wb_twighlight,
                          'Terbit',
                          state.schedule.terbit,
                          state.schedule,
                          state.cityName),
                      _buildPrayerCard(Icons.wb_twilight, 'Dhuha',
                          state.schedule.dhuha, state.schedule, state.cityName),
                      _buildPrayerCard(
                          Icons.sunny,
                          'Dzuhur',
                          state.schedule.dzuhur,
                          state.schedule,
                          state.cityName),
                      _buildPrayerCard(Icons.sunny_snowing, 'Ashar',
                          state.schedule.ashar, state.schedule, state.cityName),
                      _buildPrayerCard(
                          Icons.wb_twilight,
                          'Maghrib',
                          state.schedule.maghrib,
                          state.schedule,
                          state.cityName),
                      _buildPrayerCard(Icons.bedtime, 'Isya',
                          state.schedule.isya, state.schedule, state.cityName),
                    ],
                  );
                } else if (state is SholatFailed) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Mencari jadwal sholat untuk lokasi Anda...',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerCard(IconData leading, String prayerName, String time,
      PrayerSchedule schedule, String cityName) {
    final isToggled = _prayerReminderToggles[prayerName] ?? false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(leading, color: Colors.teal),
        title: Text(
          prayerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          time,
          style: const TextStyle(fontSize: 16, color: Colors.teal),
        ),
        trailing: Switch(
          value: isToggled,
          activeColor: Colors.teal,
          onChanged: (value) {
            setState(() {
              _prayerReminderToggles[prayerName] = value;
            });

            final reminderData = SholatReminderModel(
              cityName: cityName,
              prayerReminders: _prayerReminderToggles,
            );
            _sholatService.saveOrUpdateReminder(reminderData);

            _rescheduleNotifications(
                schedule, cityName, _prayerReminderToggles);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Pengingat $prayerName ${value ? "diaktifkan" : "dinonaktifkan"}')),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
