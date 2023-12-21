// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeatherDataAdapter extends TypeAdapter<WeatherData> {
  @override
  final int typeId = 0;

  @override
  WeatherData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherData()
      ..mainIcon = fields[0] as String?
      ..countryname = fields[1] as String?
      ..temperature = fields[2] as String?
      ..tempfeelslike = fields[3] as String?
      ..humidity = fields[4] as String?
      ..windSpeed = fields[5] as String?
      ..mainWeather = fields[6] as String?
      ..weatherDescription = fields[7] as String?
      ..pressure = fields[8] as String?
      ..sunrise = fields[9] as String?
      ..sunset = fields[10] as String?
      ..lastUpdated = fields[11] as String?
      ..lastUpdatedFull = fields[12] as String?
      ..windDeg = fields[13] as int?;
  }

  @override
  void write(BinaryWriter writer, WeatherData obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.mainIcon)
      ..writeByte(1)
      ..write(obj.countryname)
      ..writeByte(2)
      ..write(obj.temperature)
      ..writeByte(3)
      ..write(obj.tempfeelslike)
      ..writeByte(4)
      ..write(obj.humidity)
      ..writeByte(5)
      ..write(obj.windSpeed)
      ..writeByte(6)
      ..write(obj.mainWeather)
      ..writeByte(7)
      ..write(obj.weatherDescription)
      ..writeByte(8)
      ..write(obj.pressure)
      ..writeByte(9)
      ..write(obj.sunrise)
      ..writeByte(10)
      ..write(obj.sunset)
      ..writeByte(11)
      ..write(obj.lastUpdated)
      ..writeByte(12)
      ..write(obj.lastUpdatedFull)
      ..writeByte(13)
      ..write(obj.windDeg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
