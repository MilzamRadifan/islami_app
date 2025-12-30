
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:islami_app/data/model/schedule_model.dart';
import 'package:islami_app/data/service/sholat_service.dart';

part 'sholat_event.dart';
part 'sholat_state.dart';

class SholatBloc extends Bloc<SholatEvent, SholatState> {
  final SholatService sholatService;

  SholatBloc(this.sholatService) : super(SholatInitial()) {
    //* dapatkan koordinat pengguna saat ini
    on<GetCurrentLocationEvent>((event, emit) async {
      emit(SholatLoading());
      try {
        final position = await sholatService.getCurrentLocation();
        emit(SholatLocationLoaded(position));
        add(GetCityNameEvent(position.latitude, position.longitude));
      } catch (e) {
        emit(SholatFailed(e.toString()));
      }
    });

    //* dapatkan alamat pengguna berdasarkan koordinat
    on<GetCityNameEvent>((event, emit) async {
      emit(SholatLoading());
      try {
        final cityInfo = await sholatService.getCityNameAndIdFromCoordinates(
          event.latitude,
          event.longitude,
        );
        if (cityInfo['cityName'] != null && cityInfo['cityId'] != null) {
          emit(SholatCityLoaded(
            cityInfo['cityId']!,
            cityInfo['cityName']!,
          ));
        } else {
          emit(const SholatFailed('Jadwal sholat tidak ditemukan'));
        }
      } catch (e) {
        emit(SholatFailed(e.toString()));
      }
    });

    //* dapatkan id lokasi
    on<FetchCityId>((event, emit) async {
      emit(SholatLoading());
      try {
        final response = await sholatService.getCityId(event.cityName);
        if (response.status && response.data.isNotEmpty) {
          emit(SholatCityLoaded(event.cityName, response.data[0].id));
        } else {
          emit(const SholatFailed('Kota tidak ditemukan'));
        }
      } catch (e) {
        emit(SholatFailed(e.toString()));
      }
    });

    //* dapatkan waktu sholat berdasarkan lokasi pengguna
    on<FetchPrayerSchedule>((event, emit) async {
      emit(SholatLoading());
      try {
        final schedule = await sholatService.getPrayerSchedule(
          event.cityId,
          event.date,
        );

        final hijrDate = await sholatService.getHijriDate(event.date);

        final reminders = await sholatService.getRemindersForLocation(
            event.cityName);

        if (schedule.status && hijrDate.status) {
          emit(SholatScheduleLoaded(
            cityName: event.cityName,
            schedule: schedule.data.jadwal,
            hijriDate: hijrDate.data.hijriDate,
            gregorianDate: hijrDate.data.gregorianDate,
            day: hijrDate.data.day,
            prayerReminders: reminders, // Masukkan data pengingat ke dalam state
          ));
        } else {
          emit(const SholatFailed('Jadwal sholat tidak ditemukan'));
        }
      } catch (e) {
        emit(SholatFailed(e.toString()));
      }
    });
  }
}
