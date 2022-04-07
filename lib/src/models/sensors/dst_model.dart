import 'dart:convert';

import '../../utils/big_guy.dart';

class DistanceModel {
  final int commandTime, actionTime;
  final int distance;

  Duration? get responseTime => BigGuy.responseTime(actionTime, commandTime);

  const DistanceModel({
    required this.commandTime,
    required this.actionTime,
    required this.distance,
  });

  factory DistanceModel.fromBytes(List<int> bytes) {
    final s = utf8.decode(bytes);
    final sp = s.split('/');

    return DistanceModel(
      commandTime: int.parse(sp[0]),
      actionTime: int.parse(sp[1]),
      distance: int.parse(sp[2]),
    );
  }

  @override
  String toString() {
    return {
      'commandTime': commandTime,
      'actionTime': actionTime,
      'distance': distance,
      'responseTime': responseTime,
    }.entries.map((e) => e.key + ': ' + e.value.toString()).join('\n');
  }
}
