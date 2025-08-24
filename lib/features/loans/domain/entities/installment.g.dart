// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InstallmentImpl _$$InstallmentImplFromJson(Map<String, dynamic> json) =>
    _$InstallmentImpl(
      numero: (json['numero'] as num).toInt(),
      fecha: DateTime.parse(json['fecha'] as String),
      saldoInicial: Decimal.fromJson(json['saldoInicial'] as String),
      interes: Decimal.fromJson(json['interes'] as String),
      amortizacion: Decimal.fromJson(json['amortizacion'] as String),
      pagoCuota: Decimal.fromJson(json['pagoCuota'] as String),
      seguro: Decimal.fromJson(json['seguro'] as String),
      totalMes: Decimal.fromJson(json['totalMes'] as String),
      saldoFinal: Decimal.fromJson(json['saldoFinal'] as String),
    );

Map<String, dynamic> _$$InstallmentImplToJson(_$InstallmentImpl instance) =>
    <String, dynamic>{
      'numero': instance.numero,
      'fecha': instance.fecha.toIso8601String(),
      'saldoInicial': instance.saldoInicial,
      'interes': instance.interes,
      'amortizacion': instance.amortizacion,
      'pagoCuota': instance.pagoCuota,
      'seguro': instance.seguro,
      'totalMes': instance.totalMes,
      'saldoFinal': instance.saldoFinal,
    };
