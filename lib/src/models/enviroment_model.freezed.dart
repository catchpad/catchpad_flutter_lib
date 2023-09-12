// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enviroment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$EnviromentModel {
  EnviromentType get enviromentType => throw _privateConstructorUsedError;
  String? get ip => throw _privateConstructorUsedError;
  String? get port => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $EnviromentModelCopyWith<EnviromentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnviromentModelCopyWith<$Res> {
  factory $EnviromentModelCopyWith(
          EnviromentModel value, $Res Function(EnviromentModel) then) =
      _$EnviromentModelCopyWithImpl<$Res, EnviromentModel>;
  @useResult
  $Res call({EnviromentType enviromentType, String? ip, String? port});
}

/// @nodoc
class _$EnviromentModelCopyWithImpl<$Res, $Val extends EnviromentModel>
    implements $EnviromentModelCopyWith<$Res> {
  _$EnviromentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enviromentType = null,
    Object? ip = freezed,
    Object? port = freezed,
  }) {
    return _then(_value.copyWith(
      enviromentType: null == enviromentType
          ? _value.enviromentType
          : enviromentType // ignore: cast_nullable_to_non_nullable
              as EnviromentType,
      ip: freezed == ip
          ? _value.ip
          : ip // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_EnviromentModelCopyWith<$Res>
    implements $EnviromentModelCopyWith<$Res> {
  factory _$$_EnviromentModelCopyWith(
          _$_EnviromentModel value, $Res Function(_$_EnviromentModel) then) =
      __$$_EnviromentModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({EnviromentType enviromentType, String? ip, String? port});
}

/// @nodoc
class __$$_EnviromentModelCopyWithImpl<$Res>
    extends _$EnviromentModelCopyWithImpl<$Res, _$_EnviromentModel>
    implements _$$_EnviromentModelCopyWith<$Res> {
  __$$_EnviromentModelCopyWithImpl(
      _$_EnviromentModel _value, $Res Function(_$_EnviromentModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enviromentType = null,
    Object? ip = freezed,
    Object? port = freezed,
  }) {
    return _then(_$_EnviromentModel(
      enviromentType: null == enviromentType
          ? _value.enviromentType
          : enviromentType // ignore: cast_nullable_to_non_nullable
              as EnviromentType,
      ip: freezed == ip
          ? _value.ip
          : ip // ignore: cast_nullable_to_non_nullable
              as String?,
      port: freezed == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_EnviromentModel extends _EnviromentModel {
  _$_EnviromentModel({required this.enviromentType, this.ip, this.port})
      : super._();

  @override
  final EnviromentType enviromentType;
  @override
  final String? ip;
  @override
  final String? port;

  @override
  String toString() {
    return 'EnviromentModel(enviromentType: $enviromentType, ip: $ip, port: $port)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EnviromentModel &&
            (identical(other.enviromentType, enviromentType) ||
                other.enviromentType == enviromentType) &&
            (identical(other.ip, ip) || other.ip == ip) &&
            (identical(other.port, port) || other.port == port));
  }

  @override
  int get hashCode => Object.hash(runtimeType, enviromentType, ip, port);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_EnviromentModelCopyWith<_$_EnviromentModel> get copyWith =>
      __$$_EnviromentModelCopyWithImpl<_$_EnviromentModel>(this, _$identity);
}

abstract class _EnviromentModel extends EnviromentModel {
  factory _EnviromentModel(
      {required final EnviromentType enviromentType,
      final String? ip,
      final String? port}) = _$_EnviromentModel;
  _EnviromentModel._() : super._();

  @override
  EnviromentType get enviromentType;
  @override
  String? get ip;
  @override
  String? get port;
  @override
  @JsonKey(ignore: true)
  _$$_EnviromentModelCopyWith<_$_EnviromentModel> get copyWith =>
      throw _privateConstructorUsedError;
}
