// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sholat_reminder_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SholatReminderModelAdapter extends TypeAdapter<SholatReminderModel> {
  @override
  final int typeId = 1;

  @override
  SholatReminderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SholatReminderModel(
      cityName: fields[0] as String,
      prayerReminders: (fields[1] as Map).cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, SholatReminderModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cityName)
      ..writeByte(1)
      ..write(obj.prayerReminders);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SholatReminderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
