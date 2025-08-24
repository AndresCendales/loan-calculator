// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insurance_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InsuranceConfigAdapter extends TypeAdapter<InsuranceConfig> {
  @override
  final int typeId = 2;

  @override
  InsuranceConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InsuranceConfig(
      mode: fields[0] as InsuranceMode,
      flatAmountPerMonth: fields[1] as Decimal?,
      monthlyPercentOfBalance: fields[2] as Decimal?,
      perInstallmentOverrides: (fields[3] as Map).cast<int, Decimal>(),
    );
  }

  @override
  void write(BinaryWriter writer, InsuranceConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.mode)
      ..writeByte(1)
      ..write(obj.flatAmountPerMonth)
      ..writeByte(2)
      ..write(obj.monthlyPercentOfBalance)
      ..writeByte(3)
      ..write(obj.perInstallmentOverrides);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsuranceConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsuranceModeAdapter extends TypeAdapter<InsuranceMode> {
  @override
  final int typeId = 1;

  @override
  InsuranceMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InsuranceMode.none;
      case 1:
        return InsuranceMode.flat;
      case 2:
        return InsuranceMode.percentOfBalance;
      default:
        return InsuranceMode.none;
    }
  }

  @override
  void write(BinaryWriter writer, InsuranceMode obj) {
    switch (obj) {
      case InsuranceMode.none:
        writer.writeByte(0);
        break;
      case InsuranceMode.flat:
        writer.writeByte(1);
        break;
      case InsuranceMode.percentOfBalance:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsuranceModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InsuranceConfigImpl _$$InsuranceConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$InsuranceConfigImpl(
      mode: $enumDecode(_$InsuranceModeEnumMap, json['mode']),
      flatAmountPerMonth: json['flatAmountPerMonth'] == null
          ? null
          : Decimal.fromJson(json['flatAmountPerMonth'] as String),
      monthlyPercentOfBalance: json['monthlyPercentOfBalance'] == null
          ? null
          : Decimal.fromJson(json['monthlyPercentOfBalance'] as String),
      perInstallmentOverrides:
          (json['perInstallmentOverrides'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(int.parse(k), Decimal.fromJson(e as String)),
              ) ??
              const {},
    );

Map<String, dynamic> _$$InsuranceConfigImplToJson(
        _$InsuranceConfigImpl instance) =>
    <String, dynamic>{
      'mode': _$InsuranceModeEnumMap[instance.mode]!,
      'flatAmountPerMonth': instance.flatAmountPerMonth,
      'monthlyPercentOfBalance': instance.monthlyPercentOfBalance,
      'perInstallmentOverrides': instance.perInstallmentOverrides
          .map((k, e) => MapEntry(k.toString(), e)),
    };

const _$InsuranceModeEnumMap = {
  InsuranceMode.none: 'none',
  InsuranceMode.flat: 'flat',
  InsuranceMode.percentOfBalance: 'percentOfBalance',
};
