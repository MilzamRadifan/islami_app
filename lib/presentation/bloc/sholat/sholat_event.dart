part of 'sholat_bloc.dart';

sealed class SholatEvent extends Equatable {
  const SholatEvent();

  @override
  List<Object> get props => [];
}

//* dapatkan koordinat pengguna saat ini
class GetCurrentLocationEvent extends SholatEvent {}

//* dapatkan alamat pengguna berdasarkan koordinat
class GetCityNameEvent extends SholatEvent {
  final double latitude;
  final double longitude;

  const GetCityNameEvent(this.latitude, this.longitude);

  @override
  List<Object> get props => [latitude, longitude];
}

//* dapatkan id lokasi
class FetchCityId extends SholatEvent {
  final String cityName;

  const FetchCityId(this.cityName);

  @override
  List<Object> get props => [cityName];
}

//* dapatkan waktu sholat berdasarkan lokasi pengguna
class FetchPrayerSchedule extends SholatEvent {
  final String cityName;
  final String cityId;
  final String date;

  const FetchPrayerSchedule(this.cityName, this.cityId, this.date);

  @override
  List<Object> get props => [cityName, cityId, date];
}
