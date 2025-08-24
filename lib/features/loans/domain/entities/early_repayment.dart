import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:decimal/decimal.dart';

part 'early_repayment.freezed.dart';
part 'early_repayment.g.dart';

@HiveType(typeId: 3)
enum EarlyType {
  @HiveField(0)
  reducePayment,
  @HiveField(1)
  reduceTerm,
}

@freezed
@HiveType(typeId: 4)
class EarlyRepayment with _$EarlyRepayment {
  const factory EarlyRepayment({
    @HiveField(0) required String id,
    @HiveField(1) required DateTime fecha,
    @HiveField(2) required Decimal monto,
    @HiveField(3) required EarlyType tipo,
  }) = _EarlyRepayment;

  factory EarlyRepayment.fromJson(Map<String, dynamic> json) => 
      _$EarlyRepaymentFromJson(json);
}
