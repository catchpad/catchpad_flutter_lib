// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dst_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DstConfigModel _$DstConfigModelFromJson(Map<String, dynamic> json) {
  return _DstConfigModel.fromJson(json);
}

/// @nodoc
mixin _$DstConfigModel {
  ///  0-2000, mm
  int? get threshold => throw _privateConstructorUsedError;

  /// 0 - 99999 ms
  int? get timeout => throw _privateConstructorUsedError;

  ///
  int? get limitValue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DstConfigModelCopyWith<DstConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DstConfigModelCopyWith<$Res> {
  factory $DstConfigModelCopyWith(
          DstConfigModel value, $Res Function(DstConfigModel) then) =
      _$DstConfigModelCopyWithImpl<$Res, DstConfigModel>;
  @useResult
  $Res call({int? threshold, int? timeout, int? limitValue});
}

/// @nodoc
class _$DstConfigModelCopyWithImpl<$Res, $Val extends DstConfigModel>
    implements $DstConfigModelCopyWith<$Res> {
  _$DstConfigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? threshold = freezed,
    Object? timeout = freezed,
    Object? limitValue = freezed,
  }) {
    return _then(_value.copyWith(
      threshold: freezed == threshold
          ? _value.threshold
          : threshold // ignore: cast_nullable_to_non_nullable
              as int?,
      timeout: freezed == timeout
          ? _value.timeout
          : timeout // ignore: cast_nullable_to_non_nullable
              as int?,
      limitValue: freezed == limitValue
          ? _value.limitValue
          : limitValue // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_DstConfigModelCopyWith<$Res>
    implements $DstConfigModelCopyWith<$Res> {
  factory _$$_DstConfigModelCopyWith(
          _$_DstConfigModel value, $Res Function(_$_DstConfigModel) then) =
      __$$_DstConfigModelCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? threshold, int? timeout, int? limitValue});
}

/// @nodoc
class __$$_DstConfigModelCopyWithImpl<$Res>
    extends _$DstConfigModelCopyWithImpl<$Res, _$_DstConfigModel>
    implements _$$_DstConfigModelCopyWith<$Res> {
  __$$_DstConfigModelCopyWithImpl(
      _$_DstConfigModel _value, $Res Function(_$_DstConfigModel) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? threshold = freezed,
    Object? timeout = freezed,
    Object? limitValue = freezed,
  }) {
    return _then(_$_DstConfigModel(
      threshold: freezed == threshold
          ? _value.threshold
          : threshold // ignore: cast_nullable_to_non_nullable
              as int?,
      timeout: freezed == timeout
          ? _value.timeout
          : timeout // ignore: cast_nullable_to_non_nullable
              as int?,
      limitValue: freezed == limitValue
          ? _value.limitValue
          : limitValue // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DstConfigModel extends _DstConfigModel {
  const _$_DstConfigModel({this.threshold, this.timeout, this.limitValue = 6})
      : super._();

  factory _$_DstConfigModel.fromJson(Map<String, dynamic> json) =>
      _$$_DstConfigModelFromJson(json);

  ///  0-2000, mm
  @override
  final int? threshold;

  /// 0 - 99999 ms
  @override
  final int? timeout;

  ///
  @override
  @JsonKey()
  final int? limitValue;

  @override
  String toString() {
    return 'DstConfigModel(threshold: $threshold, timeout: $timeout, limitValue: $limitValue)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DstConfigModel &&
            (identical(other.threshold, threshold) ||
                other.threshold == threshold) &&
            (identical(other.timeout, timeout) || other.timeout == timeout) &&
            (identical(other.limitValue, limitValue) ||
                other.limitValue == limitValue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, threshold, timeout, limitValue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DstConfigModelCopyWith<_$_DstConfigModel> get copyWith =>
      __$$_DstConfigModelCopyWithImpl<_$_DstConfigModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DstConfigModelToJson(
      this,
    );
  }
}

abstract class _DstConfigModel extends DstConfigModel {
  const factory _DstConfigModel(
      {final int? threshold,
      final int? timeout,
      final int? limitValue}) = _$_DstConfigModel;
  const _DstConfigModel._() : super._();

  factory _DstConfigModel.fromJson(Map<String, dynamic> json) =
      _$_DstConfigModel.fromJson;

  @override

  ///  0-2000, mm
  int? get threshold;
  @override

  /// 0 - 99999 ms
  int? get timeout;
  @override

  ///
  int? get limitValue;
  @override
  @JsonKey(ignore: true)
  _$$_DstConfigModelCopyWith<_$_DstConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}
