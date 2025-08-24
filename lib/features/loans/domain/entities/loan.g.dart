// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanAdapter extends TypeAdapter<Loan> {
  @override
  final int typeId = 0;

  @override
  Loan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Loan(
      id: fields[0] as String,
      titulo: fields[1] as String,
      principal: fields[2] as Decimal,
      plazoMeses: fields[3] as int,
      tea: fields[4] as Decimal,
      fechaInicio: fields[5] as DateTime,
      seguroConfig: fields[6] as InsuranceConfig,
      earlyRepayments: (fields[7] as List).cast<EarlyRepayment>(),
    );
  }

  @override
  void write(BinaryWriter writer, Loan obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titulo)
      ..writeByte(2)
      ..write(obj.principal)
      ..writeByte(3)
      ..write(obj.plazoMeses)
      ..writeByte(4)
      ..write(obj.tea)
      ..writeByte(5)
      ..write(obj.fechaInicio)
      ..writeByte(6)
      ..write(obj.seguroConfig)
      ..writeByte(7)
      ..write(obj.earlyRepayments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoanImpl _$$LoanImplFromJson(Map<String, dynamic> json) => _$LoanImpl(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      principal: Decimal.fromJson(json['principal'] as String),
      plazoMeses: (json['plazoMeses'] as num).toInt(),
      tea: Decimal.fromJson(json['tea'] as String),
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      seguroConfig: InsuranceConfig.fromJson(
          json['seguroConfig'] as Map<String, dynamic>),
      earlyRepayments: (json['earlyRepayments'] as List<dynamic>?)
              ?.map((e) => EarlyRepayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$LoanImplToJson(_$LoanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'principal': instance.principal,
      'plazoMeses': instance.plazoMeses,
      'tea': instance.tea,
      'fechaInicio': instance.fechaInicio.toIso8601String(),
      'seguroConfig': instance.seguroConfig,
      'earlyRepayments': instance.earlyRepayments,
    };
