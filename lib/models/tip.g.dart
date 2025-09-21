// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipAdapter extends TypeAdapter<Tip> {
  @override
  final int typeId = 3;

  @override
  Tip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tip(
      id: fields[0] as String,
      tipperId: fields[1] as String,
      tipperName: fields[2] as String,
      tipperEmail: fields[3] as String?,
      creatorId: fields[4] as String,
      amount: fields[5] as double,
      currency: fields[6] as Currency,
      message: fields[7] as String?,
      status: fields[8] as TipStatus,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      paymentIntentId: fields[11] as String?,
      platformFee: fields[12] as double,
      creatorAmount: fields[13] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Tip obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tipperId)
      ..writeByte(2)
      ..write(obj.tipperName)
      ..writeByte(3)
      ..write(obj.tipperEmail)
      ..writeByte(4)
      ..write(obj.creatorId)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.currency)
      ..writeByte(7)
      ..write(obj.message)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.paymentIntentId)
      ..writeByte(12)
      ..write(obj.platformFee)
      ..writeByte(13)
      ..write(obj.creatorAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TipStatusAdapter extends TypeAdapter<TipStatus> {
  @override
  final int typeId = 1;

  @override
  TipStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipStatus.pending;
      case 1:
        return TipStatus.completed;
      case 2:
        return TipStatus.failed;
      case 3:
        return TipStatus.refunded;
      default:
        return TipStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, TipStatus obj) {
    switch (obj) {
      case TipStatus.pending:
        writer.writeByte(0);
        break;
      case TipStatus.completed:
        writer.writeByte(1);
        break;
      case TipStatus.failed:
        writer.writeByte(2);
        break;
      case TipStatus.refunded:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final int typeId = 2;

  @override
  Currency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Currency.usd;
      case 1:
        return Currency.etb;
      default:
        return Currency.usd;
    }
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    switch (obj) {
      case Currency.usd:
        writer.writeByte(0);
        break;
      case Currency.etb:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
