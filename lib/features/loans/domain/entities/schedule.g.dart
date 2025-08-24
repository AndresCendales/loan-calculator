// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleImpl _$$ScheduleImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleImpl(
      loanId: json['loanId'] as String,
      installments: (json['installments'] as List<dynamic>)
          .map((e) => Installment.fromJson(e as Map<String, dynamic>))
          .toList(),
      cuota: Decimal.fromJson(json['cuota'] as String),
      ultimaActualizacion:
          DateTime.parse(json['ultimaActualizacion'] as String),
      recalculos: (json['recalculos'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ScheduleImplToJson(_$ScheduleImpl instance) =>
    <String, dynamic>{
      'loanId': instance.loanId,
      'installments': instance.installments,
      'cuota': instance.cuota,
      'ultimaActualizacion': instance.ultimaActualizacion.toIso8601String(),
      'recalculos': instance.recalculos,
    };
