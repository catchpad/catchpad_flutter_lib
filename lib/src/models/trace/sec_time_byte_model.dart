import 'package:equatable/equatable.dart';

class SecTimeByte with EquatableMixin {

  /// [SecTimeByte] id create for cloud firestore
  String? secTimeByteId;

  /// Start second of this module
  int? startSec;

  /// End second of this module
  int? endSec;

  /// Total byte of this module
  int? totalByte;

  /// Created time of this module
  String? createdTime;

  SecTimeByte({
    required this.secTimeByteId,
    required this.startSec,
    required this.endSec,
    required this.totalByte,
    required this.createdTime,
  });

  @override
  List<Object?> get props =>
      [secTimeByteId, startSec, endSec, totalByte, createdTime];

  SecTimeByte copyWith({
    String? secTimeByteId,
    int? startSec,
    int? endSec,
    int? totalByte,
    String? createdTime,
  }) {
    return SecTimeByte(
      secTimeByteId: secTimeByteId ?? this.secTimeByteId,
      startSec: startSec ?? this.startSec,
      endSec: endSec ?? this.endSec,
      totalByte: totalByte ?? this.totalByte,
      createdTime: createdTime ?? this.createdTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'secTimeByteId': secTimeByteId,
      'startSec': startSec,
      'endSec': endSec,
      'totalByte': totalByte,
      'createdTime': createdTime,
    };
  }

  factory SecTimeByte.fromJson(Map<String, dynamic> json) {
    return SecTimeByte(
      secTimeByteId: json['secTimeByteId'] as String?,
      startSec: json['startSec'] as int?,
      endSec: json['endSec'] as int?,
      totalByte: json['totalByte'] as int?,
      createdTime: json['createdTime'] as String?,
    );
  }
}
