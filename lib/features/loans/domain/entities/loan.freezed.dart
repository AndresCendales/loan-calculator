// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Loan _$LoanFromJson(Map<String, dynamic> json) {
  return _Loan.fromJson(json);
}

/// @nodoc
mixin _$Loan {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get titulo => throw _privateConstructorUsedError;
  @HiveField(2)
  Decimal get principal => throw _privateConstructorUsedError;
  @HiveField(3)
  int get plazoMeses => throw _privateConstructorUsedError;
  @HiveField(4)
  Decimal get tea => throw _privateConstructorUsedError;
  @HiveField(5)
  DateTime get fechaInicio => throw _privateConstructorUsedError;
  @HiveField(6)
  InsuranceConfig get seguroConfig => throw _privateConstructorUsedError;
  @HiveField(7)
  List<EarlyRepayment> get earlyRepayments =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LoanCopyWith<Loan> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanCopyWith<$Res> {
  factory $LoanCopyWith(Loan value, $Res Function(Loan) then) =
      _$LoanCopyWithImpl<$Res, Loan>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String titulo,
      @HiveField(2) Decimal principal,
      @HiveField(3) int plazoMeses,
      @HiveField(4) Decimal tea,
      @HiveField(5) DateTime fechaInicio,
      @HiveField(6) InsuranceConfig seguroConfig,
      @HiveField(7) List<EarlyRepayment> earlyRepayments});

  $InsuranceConfigCopyWith<$Res> get seguroConfig;
}

/// @nodoc
class _$LoanCopyWithImpl<$Res, $Val extends Loan>
    implements $LoanCopyWith<$Res> {
  _$LoanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titulo = null,
    Object? principal = null,
    Object? plazoMeses = null,
    Object? tea = null,
    Object? fechaInicio = null,
    Object? seguroConfig = null,
    Object? earlyRepayments = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      titulo: null == titulo
          ? _value.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      principal: null == principal
          ? _value.principal
          : principal // ignore: cast_nullable_to_non_nullable
              as Decimal,
      plazoMeses: null == plazoMeses
          ? _value.plazoMeses
          : plazoMeses // ignore: cast_nullable_to_non_nullable
              as int,
      tea: null == tea
          ? _value.tea
          : tea // ignore: cast_nullable_to_non_nullable
              as Decimal,
      fechaInicio: null == fechaInicio
          ? _value.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime,
      seguroConfig: null == seguroConfig
          ? _value.seguroConfig
          : seguroConfig // ignore: cast_nullable_to_non_nullable
              as InsuranceConfig,
      earlyRepayments: null == earlyRepayments
          ? _value.earlyRepayments
          : earlyRepayments // ignore: cast_nullable_to_non_nullable
              as List<EarlyRepayment>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $InsuranceConfigCopyWith<$Res> get seguroConfig {
    return $InsuranceConfigCopyWith<$Res>(_value.seguroConfig, (value) {
      return _then(_value.copyWith(seguroConfig: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoanImplCopyWith<$Res> implements $LoanCopyWith<$Res> {
  factory _$$LoanImplCopyWith(
          _$LoanImpl value, $Res Function(_$LoanImpl) then) =
      __$$LoanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String titulo,
      @HiveField(2) Decimal principal,
      @HiveField(3) int plazoMeses,
      @HiveField(4) Decimal tea,
      @HiveField(5) DateTime fechaInicio,
      @HiveField(6) InsuranceConfig seguroConfig,
      @HiveField(7) List<EarlyRepayment> earlyRepayments});

  @override
  $InsuranceConfigCopyWith<$Res> get seguroConfig;
}

/// @nodoc
class __$$LoanImplCopyWithImpl<$Res>
    extends _$LoanCopyWithImpl<$Res, _$LoanImpl>
    implements _$$LoanImplCopyWith<$Res> {
  __$$LoanImplCopyWithImpl(_$LoanImpl _value, $Res Function(_$LoanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titulo = null,
    Object? principal = null,
    Object? plazoMeses = null,
    Object? tea = null,
    Object? fechaInicio = null,
    Object? seguroConfig = null,
    Object? earlyRepayments = null,
  }) {
    return _then(_$LoanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      titulo: null == titulo
          ? _value.titulo
          : titulo // ignore: cast_nullable_to_non_nullable
              as String,
      principal: null == principal
          ? _value.principal
          : principal // ignore: cast_nullable_to_non_nullable
              as Decimal,
      plazoMeses: null == plazoMeses
          ? _value.plazoMeses
          : plazoMeses // ignore: cast_nullable_to_non_nullable
              as int,
      tea: null == tea
          ? _value.tea
          : tea // ignore: cast_nullable_to_non_nullable
              as Decimal,
      fechaInicio: null == fechaInicio
          ? _value.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime,
      seguroConfig: null == seguroConfig
          ? _value.seguroConfig
          : seguroConfig // ignore: cast_nullable_to_non_nullable
              as InsuranceConfig,
      earlyRepayments: null == earlyRepayments
          ? _value._earlyRepayments
          : earlyRepayments // ignore: cast_nullable_to_non_nullable
              as List<EarlyRepayment>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoanImpl implements _Loan {
  const _$LoanImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.titulo,
      @HiveField(2) required this.principal,
      @HiveField(3) required this.plazoMeses,
      @HiveField(4) required this.tea,
      @HiveField(5) required this.fechaInicio,
      @HiveField(6) required this.seguroConfig,
      @HiveField(7) final List<EarlyRepayment> earlyRepayments = const []})
      : _earlyRepayments = earlyRepayments;

  factory _$LoanImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoanImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String titulo;
  @override
  @HiveField(2)
  final Decimal principal;
  @override
  @HiveField(3)
  final int plazoMeses;
  @override
  @HiveField(4)
  final Decimal tea;
  @override
  @HiveField(5)
  final DateTime fechaInicio;
  @override
  @HiveField(6)
  final InsuranceConfig seguroConfig;
  final List<EarlyRepayment> _earlyRepayments;
  @override
  @JsonKey()
  @HiveField(7)
  List<EarlyRepayment> get earlyRepayments {
    if (_earlyRepayments is EqualUnmodifiableListView) return _earlyRepayments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_earlyRepayments);
  }

  @override
  String toString() {
    return 'Loan(id: $id, titulo: $titulo, principal: $principal, plazoMeses: $plazoMeses, tea: $tea, fechaInicio: $fechaInicio, seguroConfig: $seguroConfig, earlyRepayments: $earlyRepayments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titulo, titulo) || other.titulo == titulo) &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.plazoMeses, plazoMeses) ||
                other.plazoMeses == plazoMeses) &&
            (identical(other.tea, tea) || other.tea == tea) &&
            (identical(other.fechaInicio, fechaInicio) ||
                other.fechaInicio == fechaInicio) &&
            (identical(other.seguroConfig, seguroConfig) ||
                other.seguroConfig == seguroConfig) &&
            const DeepCollectionEquality()
                .equals(other._earlyRepayments, _earlyRepayments));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      titulo,
      principal,
      plazoMeses,
      tea,
      fechaInicio,
      seguroConfig,
      const DeepCollectionEquality().hash(_earlyRepayments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoanImplCopyWith<_$LoanImpl> get copyWith =>
      __$$LoanImplCopyWithImpl<_$LoanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoanImplToJson(
      this,
    );
  }
}

abstract class _Loan implements Loan {
  const factory _Loan(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String titulo,
      @HiveField(2) required final Decimal principal,
      @HiveField(3) required final int plazoMeses,
      @HiveField(4) required final Decimal tea,
      @HiveField(5) required final DateTime fechaInicio,
      @HiveField(6) required final InsuranceConfig seguroConfig,
      @HiveField(7) final List<EarlyRepayment> earlyRepayments}) = _$LoanImpl;

  factory _Loan.fromJson(Map<String, dynamic> json) = _$LoanImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get titulo;
  @override
  @HiveField(2)
  Decimal get principal;
  @override
  @HiveField(3)
  int get plazoMeses;
  @override
  @HiveField(4)
  Decimal get tea;
  @override
  @HiveField(5)
  DateTime get fechaInicio;
  @override
  @HiveField(6)
  InsuranceConfig get seguroConfig;
  @override
  @HiveField(7)
  List<EarlyRepayment> get earlyRepayments;
  @override
  @JsonKey(ignore: true)
  _$$LoanImplCopyWith<_$LoanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
