import 'package:catchpad_flutter_lib/src/models/trace/sec_time_byte_model.dart';
import 'package:flutter/foundation.dart';

class ByteTraceModel {
  /// [ByteTraceModel] id create for cloud firestore
  final String? byteTraceModelId;

  /// Game id for this trace
  final String? gameId;

  /// Game name for this trace
  final String? gameName;

  /// Define the current device brand to analyze the device
  final String? deviceBrand;

  /// All SecTimeByte list of this trace
  final List<SecTimeByte> secTimeList;

  /// Created time of this trace
  final String? createdTime;

  /// Total byte of this trace
  final int? totalByte;

  /// Charge value of the device when this trace created
  final int? chargeValue;

  /// Charge values of pads when this trace created
  final Map<String, int> padChargeValues;

  /// Per Second Byte of this trace
  final double? psb;

  ByteTraceModel({
    this.byteTraceModelId,
    this.gameId,
    this.gameName,
    this.deviceBrand,
    List<SecTimeByte>? secTimeList,
    this.createdTime,
    this.totalByte,
    this.chargeValue,
    Map<String, int>? padChargeValues,
    this.psb,
  })  : secTimeList = secTimeList ?? [],
        padChargeValues = padChargeValues ?? {};

  // Override the equality operator to compare instances
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ByteTraceModel &&
          runtimeType == other.runtimeType &&
          byteTraceModelId == other.byteTraceModelId &&
          gameId == other.gameId &&
          gameName == other.gameName &&
          deviceBrand == other.deviceBrand &&
          listEquals(secTimeList, other.secTimeList) &&
          createdTime == other.createdTime &&
          totalByte == other.totalByte &&
          chargeValue == other.chargeValue &&
          mapEquals(padChargeValues, other.padChargeValues) &&
          psb == other.psb;

  // Override hashCode for equality checks
  @override
  int get hashCode =>
      byteTraceModelId.hashCode ^
      gameId.hashCode ^
      gameName.hashCode ^
      deviceBrand.hashCode ^
      secTimeList.hashCode ^
      createdTime.hashCode ^
      totalByte.hashCode ^
      chargeValue.hashCode ^
      padChargeValues.hashCode ^
      psb.hashCode;

  // Convert to JSON format
  Map<String, dynamic> toJson() {
    return {
      'byteTraceModelId': byteTraceModelId,
      'gameId': gameId,
      'gameName': gameName,
      'deviceBrand': deviceBrand,
      'secTimeList': secTimeList.map((item) => item.toJson()).toList(),
      'createdTime': createdTime,
      'totalByte': totalByte,
      'chargeValue': chargeValue,
      'padChargeValues': padChargeValues,
      'psb': psb,
    };
  }

  // Create an instance from JSON data
  factory ByteTraceModel.fromJson(Map<String, dynamic> json) {
    return ByteTraceModel(
      byteTraceModelId: json['byteTraceModelId'],
      gameId: json['gameId'],
      gameName: json['gameName'],
      deviceBrand: json['deviceBrand'],
      secTimeList: (json['secTimeList'] as List)
          .map((item) => SecTimeByte.fromJson(item))
          .toList(),
      createdTime: json['createdTime'],
      totalByte: json['totalByte'],
      chargeValue: json['chargeValue'],
      padChargeValues: Map<String, int>.from(json['padChargeValues']),
      psb: json['psb'],
    );
  }
}
