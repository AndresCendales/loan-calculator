// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Schedule _$ScheduleFromJson(Map<String, dynamic> json) {
  return _Schedule.fromJson(json);
}

/// @nodoc
mixin _$Schedule {
  String get loanId => throw _privateConstructorUsedError;
  List<Installment> get installments => throw _privateConstructorUsedError;
  Decimal get cuota => throw _privateConstructorUsedError;
  DateTime get ultimaActualizacion => throw _privateConstructorUsedError;
  int get recalculos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScheduleCopyWith<Schedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleCopyWith<$Res> {
  factory $ScheduleCopyWith(Schedule value, $Res Function(Schedule) then) =
      _$ScheduleCopyWithImpl<$Res, Schedule>;
  @useResult
  $Res call(
      {String loanId,
      List<Installment> installments,
      Decimal cuota,
      DateTime ultimaActualizacion,
      int recalculos});
}

/// @nodoc
class _$ScheduleCopyWithImpl<$Res, $Val extends Schedule>
    implements $ScheduleCopyWith<$Res> {
  _$ScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loanId = null,
    Object? installments = null,
    Object? cuota = null,
    Object? ultimaActualizacion = null,
    Object? recalculos = null,
  }) {
    return _then(_value.copyWith(
      loanId: null == loanId
          ? _value.loanId
          : loanId // ignore: cast_nullable_to_non_nullable
              as String,
      installments: null == installments
          ? _value.installments
          : installments // ignore: cast_nullable_to_non_nullable
              as List<Installment>,
      cuota: null == cuota
          ? _value.cuota
          : cuota // ignore: cast_nullable_to_non_nullable
              as Decimal,
      ultimaActualizacion: null == ultimaActualizacion
          ? _value.ultimaActualizacion
          : ultimaActualizacion // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recalculos: null == recalculos
          ? _value.recalculos
          : recalculos // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleImplCopyWith<$Res>
    implements $ScheduleCopyWith<$Res> {
  factory _$$ScheduleImplCopyWith(
          _$ScheduleImpl value, $Res Function(_$ScheduleImpl) then) =
      __$$ScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String loanId,
      List<Installment> installments,
      Decimal cuota,
      DateTime ultimaActualizacion,
      int recalculos});
}

/// @nodoc
class __$$ScheduleImplCopyWithImpl<$Res>
    extends _$ScheduleCopyWithImpl<$Res, _$ScheduleImpl>
    implements _$$ScheduleImplCopyWith<$Res> {
  __$$ScheduleImplCopyWithImpl(
      _$ScheduleImpl _value, $Res Function(_$ScheduleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loanId = null,
    Object? installments = null,
    Object? cuota = null,
    Object? ultimaActualizacion = null,
    Object? recalculos = null,
  }) {
    return _then(_$ScheduleImpl(
      loanId: null == loanId
          ? _value.loanId
          : loanId // ignore: cast_nullable_to_non_nullable
              as String,
      installments: null == installments
          ? _value._installments
          : installments // ignore: cast_nullable_to_non_nullable
              as List<Installment>,
      cuota: null == cuota
          ? _value.cuota
          : cuota // ignore: cast_nullable_to_non_nullable
              as Decimal,
      ultimaActualizacion: null == ultimaActualizacion
          ? _value.ultimaActualizacion
          : ultimaActualizacion // ignore: cast_nullable_to_non_nullable
              as DateTime,
      recalculos: null == recalculos
          ? _value.recalculos
          : recalculos // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleImpl implements _Schedule {
  const _$ScheduleImpl(
      {required this.loanId,
      required final List<Installment> installments,
      required this.cuota,
      required this.ultimaActualizacion,
      this.recalculos = 0})
      : _installments = installments;

  factory _$ScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleImplFromJson(json);

  @override
  final String loanId;
  final List<Installment> _installments;
  @override
  List<Installment> get installments {
    if (_installments is EqualUnmodifiableListView) return _installments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_installments);
  }

  @override
  final Decimal cuota;
  @override
  final DateTime ultimaActualizacion;
  @override
  @JsonKey()
  final int recalculos;

  @override
  String toString() {
    return 'Schedule(loanId: $loanId, installments: $installments, cuota: $cuota, ultimaActualizacion: $ultimaActualizacion, recalculos: $recalculos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleImpl &&
            (identical(other.loanId, loanId) || other.loanId == loanId) &&
            const DeepCollectionEquality()
                .equals(other._installments, _installments) &&
            (identical(other.cuota, cuota) || other.cuota == cuota) &&
            (identical(other.ultimaActualizacion, ultimaActualizacion) ||
                other.ultimaActualizacion == ultimaActualizacion) &&
            (identical(other.recalculos, recalculos) ||
                other.recalculos == recalculos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      loanId,
      const DeepCollectionEquality().hash(_installments),
      cuota,
      ultimaActualizacion,
      recalculos);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleImplCopyWith<_$ScheduleImpl> get copyWith =>
      __$$ScheduleImplCopyWithImpl<_$ScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleImplToJson(
      this,
    );
  }
}

abstract class _Schedule implements Schedule {
  const factory _Schedule(
      {required final String loanId,
      required final List<Installment> installments,
      required final Decimal cuota,
      required final DateTime ultimaActualizacion,
      final int recalculos}) = _$ScheduleImpl;

  factory _Schedule.fromJson(Map<String, dynamic> json) =
      _$ScheduleImpl.fromJson;

  @override
  String get loanId;
  @override
  List<Installment> get installments;
  @override
  Decimal get cuota;
  @override
  DateTime get ultimaActualizacion;
  @override
  int get recalculos;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleImplCopyWith<_$ScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
