part of 'sholat_bloc.dart';

sealed class SholatState extends Equatable {
  const SholatState();

  @override
  List<Object> get props => [];
}

final class SholatInitial extends SholatState {}

final class SholatLoading extends SholatState {}

final class SholatFailed extends SholatState {
  final String message;

  const SholatFailed(this.message);

  @override
  List<Object> get props => [message];
}

//* dapatkan koordinat pengguna saat ini
final class SholatLocationLoaded extends SholatState {
  final Position position;

  const SholatLocationLoaded(this.position);

  @override
  List<Object> get props => [position];
}

//* dapatkan alamat pengguna berdasarkan koordinat
final class SholatCityNameLoaded extends SholatState {
  final String cityName;

  const SholatCityNameLoaded(this.cityName);

  @override
  List<Object> get props => [cityName];
}

//* dapatkan id lokasi
final class SholatCityLoaded extends SholatState {
  final String cityName;
  final String cityId;

  const SholatCityLoaded(this.cityId, this.cityName);

  @override
  List<Object> get props => [cityId, cityName];
}

//* dapatkan waktu sholat berdasarkan lokasi pengguna
final class SholatScheduleLoaded extends SholatState {
  final String cityName;
  final PrayerSchedule schedule;
  final String hijriDate;
  final String gregorianDate;
  final String day;
  final Map<String, bool> prayerReminders;

  const SholatScheduleLoaded({
    required this.cityName,
    required this.schedule,
    required this.hijriDate,
    required this.gregorianDate,
    required this.day,
    required this.prayerReminders, 
  });

  @override
  List<Object> get props => [cityName, schedule, hijriDate, gregorianDate, day, prayerReminders];
}


