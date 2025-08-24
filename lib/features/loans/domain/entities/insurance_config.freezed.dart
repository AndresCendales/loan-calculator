// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insurance_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InsuranceConfig _$InsuranceConfigFromJson(Map<String, dynamic> json) {
  return _InsuranceConfig.fromJson(json);
}

/// @nodoc
mixin _$InsuranceConfig {
  @HiveField(0)
  InsuranceMode get mode => throw _privateConstructorUsedError;
  @HiveField(1)
  Decimal? get flatAmountPerMonth => throw _privateConstructorUsedError;
  @HiveField(2)
  Decimal? get monthlyPercentOfBalance => throw _privateConstructorUsedError;
  @HiveField(3)
  Map<int, Decimal> get perInstallmentOverrides =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InsuranceConfigCopyWith<InsuranceConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsuranceConfigCopyWith<$Res> {
  factory $InsuranceConfigCopyWith(
          InsuranceConfig value, $Res Function(InsuranceConfig) then) =
      _$InsuranceConfigCopyWithImpl<$Res, InsuranceConfig>;
  @useResult
  $Res call(
      {@HiveField(0) InsuranceMode mode,
      @HiveField(1) Decimal? flatAmountPerMonth,
      @HiveField(2) Decimal? monthlyPercentOfBalance,
      @HiveField(3) Map<int, Decimal> perInstallmentOverrides});
}

/// @nodoc
class _$InsuranceConfigCopyWithImpl<$Res, $Val extends InsuranceConfig>
    implements $InsuranceConfigCopyWith<$Res> {
  _$InsuranceConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? flatAmountPerMonth = freezed,
    Object? monthlyPercentOfBalance = freezed,
    Object? perInstallmentOverrides = null,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as InsuranceMode,
      flatAmountPerMonth: freezed == flatAmountPerMonth
          ? _value.flatAmountPerMonth
          : flatAmountPerMonth // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      monthlyPercentOfBalance: freezed == monthlyPercentOfBalance
          ? _value.monthlyPercentOfBalance
          : monthlyPercentOfBalance // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      perInstallmentOverrides: null == perInstallmentOverrides
          ? _value.perInstallmentOverrides
          : perInstallmentOverrides // ignore: cast_nullable_to_non_nullable
              as Map<int, Decimal>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InsuranceConfigImplCopyWith<$Res>
    implements $InsuranceConfigCopyWith<$Res> {
  factory _$$InsuranceConfigImplCopyWith(_$InsuranceConfigImpl value,
          $Res Function(_$InsuranceConfigImpl) then) =
      __$$InsuranceConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) InsuranceMode mode,
      @HiveField(1) Decimal? flatAmountPerMonth,
      @HiveField(2) Decimal? monthlyPercentOfBalance,
      @HiveField(3) Map<int, Decimal> perInstallmentOverrides});
}

/// @nodoc
class __$$InsuranceConfigImplCopyWithImpl<$Res>
    extends _$InsuranceConfigCopyWithImpl<$Res, _$InsuranceConfigImpl>
    implements _$$InsuranceConfigImplCopyWith<$Res> {
  __$$InsuranceConfigImplCopyWithImpl(
      _$InsuranceConfigImpl _value, $Res Function(_$InsuranceConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? flatAmountPerMonth = freezed,
    Object? monthlyPercentOfBalance = freezed,
    Object? perInstallmentOverrides = null,
  }) {
    return _then(_$InsuranceConfigImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as InsuranceMode,
      flatAmountPerMonth: freezed == flatAmountPerMonth
          ? _value.flatAmountPerMonth
          : flatAmountPerMonth // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      monthlyPercentOfBalance: freezed == monthlyPercentOfBalance
          ? _value.monthlyPercentOfBalance
          : monthlyPercentOfBalance // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      perInstallmentOverrides: null == perInstallmentOverrides
          ? _value._perInstallmentOverrides
          : perInstallmentOverrides // ignore: cast_nullable_to_non_nullable
              as Map<int, Decimal>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InsuranceConfigImpl implements _InsuranceConfig {
  const _$InsuranceConfigImpl(
      {@HiveField(0) required this.mode,
      @HiveField(1) this.flatAmountPerMonth,
      @HiveField(2) this.monthlyPercentOfBalance,
      @HiveField(3) final Map<int, Decimal> perInstallmentOverrides = const {}})
      : _perInstallmentOverrides = perInstallmentOverrides;

  factory _$InsuranceConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsuranceConfigImplFromJson(json);

  @override
  @HiveField(0)
  final InsuranceMode mode;
  @override
  @HiveField(1)
  final Decimal? flatAmountPerMonth;
  @override
  @HiveField(2)
  final Decimal? monthlyPercentOfBalance;
  final Map<int, Decimal> _perInstallmentOverrides;
  @override
  @JsonKey()
  @HiveField(3)
  Map<int, Decimal> get perInstallmentOverrides {
    if (_perInstallmentOverrides is EqualUnmodifiableMapView)
      return _perInstallmentOverrides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_perInstallmentOverrides);
  }

  @override
  String toString() {
    return 'InsuranceConfig(mode: $mode, flatAmountPerMonth: $flatAmountPerMonth, monthlyPercentOfBalance: $monthlyPercentOfBalance, perInstallmentOverrides: $perInstallmentOverrides)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsuranceConfigImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.flatAmountPerMonth, flatAmountPerMonth) ||
                other.flatAmountPerMonth == flatAmountPerMonth) &&
            (identical(
                    other.monthlyPercentOfBalance, monthlyPercentOfBalance) ||
                other.monthlyPercentOfBalance == monthlyPercentOfBalance) &&
            const DeepCollectionEquality().equals(
                other._perInstallmentOverrides, _perInstallmentOverrides));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      mode,
      flatAmountPerMonth,
      monthlyPercentOfBalance,
      const DeepCollectionEquality().hash(_perInstallmentOverrides));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InsuranceConfigImplCopyWith<_$InsuranceConfigImpl> get copyWith =>
      __$$InsuranceConfigImplCopyWithImpl<_$InsuranceConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InsuranceConfigImplToJson(
      this,
    );
  }
}

abstract class _InsuranceConfig implements InsuranceConfig {
  const factory _InsuranceConfig(
          {@HiveField(0) required final InsuranceMode mode,
          @HiveField(1) final Decimal? flatAmountPerMonth,
          @HiveField(2) final Decimal? monthlyPercentOfBalance,
          @HiveField(3) final Map<int, Decimal> perInstallmentOverrides}) =
      _$InsuranceConfigImpl;

  factory _InsuranceConfig.fromJson(Map<String, dynamic> json) =
      _$InsuranceConfigImpl.fromJson;

  @override
  @HiveField(0)
  InsuranceMode get mode;
  @override
  @HiveField(1)
  Decimal? get flatAmountPerMonth;
  @override
  @HiveField(2)
  Decimal? get monthlyPercentOfBalance;
  @override
  @HiveField(3)
  Map<int, Decimal> get perInstallmentOverrides;
  @override
  @JsonKey(ignore: true)
  _$$InsuranceConfigImplCopyWith<_$InsuranceConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
