// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatorAnalyticsAdapter extends TypeAdapter<CreatorAnalytics> {
  @override
  final int typeId = 7;

  @override
  CreatorAnalytics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatorAnalytics(
      creatorId: fields[0] as String,
      totalEarnings: fields[1] as double,
      totalTips: fields[2] as int,
      averageTipAmount: fields[3] as double,
      lastTipDate: fields[4] as DateTime,
      tipsByCurrency: (fields[5] as Map).cast<String, int>(),
      earningsByCurrency: (fields[6] as Map).cast<String, double>(),
      tipFrequency: (fields[7] as List).cast<TipFrequency>(),
      topTippers: (fields[8] as List).cast<TopTipper>(),
      generatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CreatorAnalytics obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.creatorId)
      ..writeByte(1)
      ..write(obj.totalEarnings)
      ..writeByte(2)
      ..write(obj.totalTips)
      ..writeByte(3)
      ..write(obj.averageTipAmount)
      ..writeByte(4)
      ..write(obj.lastTipDate)
      ..writeByte(5)
      ..write(obj.tipsByCurrency)
      ..writeByte(6)
      ..write(obj.earningsByCurrency)
      ..writeByte(7)
      ..write(obj.tipFrequency)
      ..writeByte(8)
      ..write(obj.topTippers)
      ..writeByte(9)
      ..write(obj.generatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatorAnalyticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TipFrequencyAdapter extends TypeAdapter<TipFrequency> {
  @override
  final int typeId = 8;

  @override
  TipFrequency read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TipFrequency(
      date: fields[0] as DateTime,
      tipCount: fields[1] as int,
      totalAmount: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TipFrequency obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.tipCount)
      ..writeByte(2)
      ..write(obj.totalAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TopTipperAdapter extends TypeAdapter<TopTipper> {
  @override
  final int typeId = 9;

  @override
  TopTipper read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopTipper(
      tipperName: fields[0] as String,
      tipCount: fields[1] as int,
      totalAmount: fields[2] as double,
      lastTipDate: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TopTipper obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.tipperName)
      ..writeByte(1)
      ..write(obj.tipCount)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.lastTipDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopTipperAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
