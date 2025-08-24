import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:decimal/decimal.dart';
import 'insurance_config.dart';
import 'early_repayment.dart';

part 'loan.freezed.dart';
part 'loan.g.dart';

@freezed
@HiveType(typeId: 0)
class Loan with _$Loan {
  const factory Loan({
    @HiveField(0) required String id,
    @HiveField(1) required String titulo,
    @HiveField(2) required Decimal principal,
    @HiveField(3) required int plazoMeses,
    @HiveField(4) required Decimal tea,
    @HiveField(5) required DateTime fechaInicio,
    @HiveField(6) required InsuranceConfig seguroConfig,
    @HiveField(7) @Default([]) List<EarlyRepayment> earlyRepayments,
  }) = _Loan;

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);
}
