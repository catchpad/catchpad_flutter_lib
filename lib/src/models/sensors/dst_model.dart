import 'dart:convert';

import '../../utils/big_guy.dart';

class DistanceModel {
  final int? commandTime, actionTime;
  final int? distance;

  int? get responseTime => BigGuy.responseTime(actionTime, commandTime);

  const DistanceModel({
    required this.commandTime,
    required this.actionTime,
    required this.distance,
  });

  factory DistanceModel.fromBytes(List<int> bytes) {
    final s = utf8.decode(bytes);
    final sp = s.split('/');

    return DistanceModel(
      commandTime: int.tryParse(sp[0]),
      actionTime: int.tryParse(sp[1]),
      distance: int.tryParse(sp[2]),
    );
  }

  @override
  String toString() {
    return 'DstModel{commandTime: $commandTime, actionTime: $actionTime, distance: $distance, responseTime: $responseTime}';
  }
}
