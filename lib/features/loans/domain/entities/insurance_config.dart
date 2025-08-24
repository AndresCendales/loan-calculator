import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:decimal/decimal.dart';

part 'insurance_config.freezed.dart';
part 'insurance_config.g.dart';

@HiveType(typeId: 1)
enum InsuranceMode {
  @HiveField(0)
  none,
  @HiveField(1)
  flat,
  @HiveField(2)
  percentOfBalance,
}

@freezed
@HiveType(typeId: 2)
class InsuranceConfig with _$InsuranceConfig {
  const factory InsuranceConfig({
    @HiveField(0) required InsuranceMode mode,
    @HiveField(1) Decimal? flatAmountPerMonth,
    @HiveField(2) Decimal? monthlyPercentOfBalance,
    @HiveField(3) @Default({}) Map<int, Decimal> perInstallmentOverrides,
  }) = _InsuranceConfig;

  factory InsuranceConfig.fromJson(Map<String, dynamic> json) => 
      _$InsuranceConfigFromJson(json);
}
