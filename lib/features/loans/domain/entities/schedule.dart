import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:decimal/decimal.dart';
import 'installment.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    required String loanId,
    required List<Installment> installments,
    required Decimal cuota,
    required DateTime ultimaActualizacion,
    @Default(0) int recalculos,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) => 
      _$ScheduleFromJson(json);
}
