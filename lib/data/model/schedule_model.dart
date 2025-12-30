class PrayerScheduleResponse {
  final bool status;
  final PrayerScheduleRequest request;
  final PrayerScheduleData data;

  PrayerScheduleResponse({
    required this.status,
    required this.request,
    required this.data,
  });

  factory PrayerScheduleResponse.fromJson(Map<String, dynamic> json) {
    return PrayerScheduleResponse(
      status: json['status'] as bool,
      request: PrayerScheduleRequest.fromJson(json['request'] as Map<String, dynamic>),
      data: PrayerScheduleData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class PrayerScheduleRequest {
  final String path;

  PrayerScheduleRequest({
    required this.path,
  });

  factory PrayerScheduleRequest.fromJson(Map<String, dynamic> json) {
    return PrayerScheduleRequest(
      path: json['path'] as String,
    );
  }
}

class PrayerScheduleData {
  final String id;
  final String lokasi;
  final String daerah;
  final PrayerSchedule jadwal;

  PrayerScheduleData({
    required this.id,
    required this.lokasi,
    required this.daerah,
    required this.jadwal,
  });

  factory PrayerScheduleData.fromJson(Map<String, dynamic> json) {
    return PrayerScheduleData(
      id: json['id'].toString(),
      lokasi: json['lokasi'] as String,
      daerah: json['daerah'] as String,
      jadwal: PrayerSchedule.fromJson(json['jadwal'] as Map<String, dynamic>),
    );
  }
}

class PrayerSchedule {
  final String tanggal;
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String date;

  PrayerSchedule({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.date,
  });

  factory PrayerSchedule.fromJson(Map<String, dynamic> json) {
    return PrayerSchedule(
      tanggal: json['tanggal'] as String,
      imsak: json['imsak'] as String,
      subuh: json['subuh'] as String,
      terbit: json['terbit'] as String,
      dhuha: json['dhuha'] as String,
      dzuhur: json['dzuhur'] as String,
      ashar: json['ashar'] as String,
      maghrib: json['maghrib'] as String,
      isya: json['isya'] as String,
      date: json['date'] as String,
    );
  }
}
