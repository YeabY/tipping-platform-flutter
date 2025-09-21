// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 6;

  @override
  Payment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payment(
      id: fields[0] as String,
      userId: fields[1] as String,
      method: fields[2] as PaymentMethod,
      status: fields[3] as PaymentStatus,
      amount: fields[4] as double,
      currency: fields[5] as String,
      stripePaymentIntentId: fields[6] as String?,
      paypalOrderId: fields[7] as String?,
      transactionId: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      failureReason: fields[11] as String?,
      metadata: (fields[12] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.method)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.stripePaymentIntentId)
      ..writeByte(7)
      ..write(obj.paypalOrderId)
      ..writeByte(8)
      ..write(obj.transactionId)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.failureReason)
      ..writeByte(12)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 4;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.creditCard;
      case 1:
        return PaymentMethod.debitCard;
      case 2:
        return PaymentMethod.bankTransfer;
      case 3:
        return PaymentMethod.mobileMoney;
      case 4:
        return PaymentMethod.paypal;
      default:
        return PaymentMethod.creditCard;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.creditCard:
        writer.writeByte(0);
        break;
      case PaymentMethod.debitCard:
        writer.writeByte(1);
        break;
      case PaymentMethod.bankTransfer:
        writer.writeByte(2);
        break;
      case PaymentMethod.mobileMoney:
        writer.writeByte(3);
        break;
      case PaymentMethod.paypal:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentStatusAdapter extends TypeAdapter<PaymentStatus> {
  @override
  final int typeId = 5;

  @override
  PaymentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentStatus.pending;
      case 1:
        return PaymentStatus.processing;
      case 2:
        return PaymentStatus.completed;
      case 3:
        return PaymentStatus.failed;
      case 4:
        return PaymentStatus.cancelled;
      case 5:
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentStatus obj) {
    switch (obj) {
      case PaymentStatus.pending:
        writer.writeByte(0);
        break;
      case PaymentStatus.processing:
        writer.writeByte(1);
        break;
      case PaymentStatus.completed:
        writer.writeByte(2);
        break;
      case PaymentStatus.failed:
        writer.writeByte(3);
        break;
      case PaymentStatus.cancelled:
        writer.writeByte(4);
        break;
      case PaymentStatus.refunded:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
