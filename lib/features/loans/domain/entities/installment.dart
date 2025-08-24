import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:decimal/decimal.dart';

part 'installment.freezed.dart';
part 'installment.g.dart';

@freezed
class Installment with _$Installment {
  const factory Installment({
    required int numero,
    required DateTime fecha,
    required Decimal saldoInicial,
    required Decimal interes,
    required Decimal amortizacion,
    required Decimal pagoCuota,
    required Decimal seguro,
    required Decimal totalMes,
    required Decimal saldoFinal,
  }) = _Installment;

  factory Installment.fromJson(Map<String, dynamic> json) => 
      _$InstallmentFromJson(json);
}
