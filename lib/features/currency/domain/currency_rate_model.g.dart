// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_rate_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyRateModelAdapter extends TypeAdapter<CurrencyRateModel> {
  @override
  final int typeId = 1;

  @override
  CurrencyRateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyRateModel(
      baseCurrency: fields[0] as String,
      rates: (fields[1] as Map).cast<String, double>(),
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyRateModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.baseCurrency)
      ..writeByte(1)
      ..write(obj.rates)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyRateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
