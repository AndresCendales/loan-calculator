// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'early_repayment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EarlyRepaymentAdapter extends TypeAdapter<EarlyRepayment> {
  @override
  final int typeId = 4;

  @override
  EarlyRepayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EarlyRepayment(
      id: fields[0] as String,
      fecha: fields[1] as DateTime,
      monto: fields[2] as Decimal,
      tipo: fields[3] as EarlyType,
    );
  }

  @override
  void write(BinaryWriter writer, EarlyRepayment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fecha)
      ..writeByte(2)
      ..write(obj.monto)
      ..writeByte(3)
      ..write(obj.tipo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EarlyRepaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EarlyTypeAdapter extends TypeAdapter<EarlyType> {
  @override
  final int typeId = 3;

  @override
  EarlyType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EarlyType.reducePayment;
      case 1:
        return EarlyType.reduceTerm;
      default:
        return EarlyType.reducePayment;
    }
  }

  @override
  void write(BinaryWriter writer, EarlyType obj) {
    switch (obj) {
      case EarlyType.reducePayment:
        writer.writeByte(0);
        break;
      case EarlyType.reduceTerm:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EarlyTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EarlyRepaymentImpl _$$EarlyRepaymentImplFromJson(Map<String, dynamic> json) =>
    _$EarlyRepaymentImpl(
      id: json['id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      monto: Decimal.fromJson(json['monto'] as String),
      tipo: $enumDecode(_$EarlyTypeEnumMap, json['tipo']),
    );

Map<String, dynamic> _$$EarlyRepaymentImplToJson(
        _$EarlyRepaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fecha': instance.fecha.toIso8601String(),
      'monto': instance.monto,
      'tipo': _$EarlyTypeEnumMap[instance.tipo]!,
    };

const _$EarlyTypeEnumMap = {
  EarlyType.reducePayment: 'reducePayment',
  EarlyType.reduceTerm: 'reduceTerm',
};
