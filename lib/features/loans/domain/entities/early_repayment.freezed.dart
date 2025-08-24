// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'early_repayment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EarlyRepayment _$EarlyRepaymentFromJson(Map<String, dynamic> json) {
  return _EarlyRepayment.fromJson(json);
}

/// @nodoc
mixin _$EarlyRepayment {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  DateTime get fecha => throw _privateConstructorUsedError;
  @HiveField(2)
  Decimal get monto => throw _privateConstructorUsedError;
  @HiveField(3)
  EarlyType get tipo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EarlyRepaymentCopyWith<EarlyRepayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EarlyRepaymentCopyWith<$Res> {
  factory $EarlyRepaymentCopyWith(
          EarlyRepayment value, $Res Function(EarlyRepayment) then) =
      _$EarlyRepaymentCopyWithImpl<$Res, EarlyRepayment>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) DateTime fecha,
      @HiveField(2) Decimal monto,
      @HiveField(3) EarlyType tipo});
}

/// @nodoc
class _$EarlyRepaymentCopyWithImpl<$Res, $Val extends EarlyRepayment>
    implements $EarlyRepaymentCopyWith<$Res> {
  _$EarlyRepaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fecha = null,
    Object? monto = null,
    Object? tipo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fecha: null == fecha
          ? _value.fecha
          : fecha // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monto: null == monto
          ? _value.monto
          : monto // ignore: cast_nullable_to_non_nullable
              as Decimal,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as EarlyType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EarlyRepaymentImplCopyWith<$Res>
    implements $EarlyRepaymentCopyWith<$Res> {
  factory _$$EarlyRepaymentImplCopyWith(_$EarlyRepaymentImpl value,
          $Res Function(_$EarlyRepaymentImpl) then) =
      __$$EarlyRepaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) DateTime fecha,
      @HiveField(2) Decimal monto,
      @HiveField(3) EarlyType tipo});
}

/// @nodoc
class __$$EarlyRepaymentImplCopyWithImpl<$Res>
    extends _$EarlyRepaymentCopyWithImpl<$Res, _$EarlyRepaymentImpl>
    implements _$$EarlyRepaymentImplCopyWith<$Res> {
  __$$EarlyRepaymentImplCopyWithImpl(
      _$EarlyRepaymentImpl _value, $Res Function(_$EarlyRepaymentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fecha = null,
    Object? monto = null,
    Object? tipo = null,
  }) {
    return _then(_$EarlyRepaymentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fecha: null == fecha
          ? _value.fecha
          : fecha // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monto: null == monto
          ? _value.monto
          : monto // ignore: cast_nullable_to_non_nullable
              as Decimal,
      tipo: null == tipo
          ? _value.tipo
          : tipo // ignore: cast_nullable_to_non_nullable
              as EarlyType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EarlyRepaymentImpl implements _EarlyRepayment {
  const _$EarlyRepaymentImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.fecha,
      @HiveField(2) required this.monto,
      @HiveField(3) required this.tipo});

  factory _$EarlyRepaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$EarlyRepaymentImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final DateTime fecha;
  @override
  @HiveField(2)
  final Decimal monto;
  @override
  @HiveField(3)
  final EarlyType tipo;

  @override
  String toString() {
    return 'EarlyRepayment(id: $id, fecha: $fecha, monto: $monto, tipo: $tipo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EarlyRepaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fecha, fecha) || other.fecha == fecha) &&
            (identical(other.monto, monto) || other.monto == monto) &&
            (identical(other.tipo, tipo) || other.tipo == tipo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, fecha, monto, tipo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EarlyRepaymentImplCopyWith<_$EarlyRepaymentImpl> get copyWith =>
      __$$EarlyRepaymentImplCopyWithImpl<_$EarlyRepaymentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EarlyRepaymentImplToJson(
      this,
    );
  }
}

abstract class _EarlyRepayment implements EarlyRepayment {
  const factory _EarlyRepayment(
      {@HiveField(0) required final String id,
      @HiveField(1) required final DateTime fecha,
      @HiveField(2) required final Decimal monto,
      @HiveField(3) required final EarlyType tipo}) = _$EarlyRepaymentImpl;

  factory _EarlyRepayment.fromJson(Map<String, dynamic> json) =
      _$EarlyRepaymentImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  DateTime get fecha;
  @override
  @HiveField(2)
  Decimal get monto;
  @override
  @HiveField(3)
  EarlyType get tipo;
  @override
  @JsonKey(ignore: true)
  _$$EarlyRepaymentImplCopyWith<_$EarlyRepaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
