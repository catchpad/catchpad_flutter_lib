import 'dart:convert';

import '../../utils/big_guy.dart';
import '../../utils/pad_consts.dart';

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
    // format: command_time/action_time/distance
    final s = utf8.decode(bytes);
    final sp = s.split(defaultSeperator);

    // TODO: there is a problem in deactivate,
    // so we're recieving data from other sensors
    int parse(String s) {
      return (double.tryParse(s) ?? 0.0).toInt();
    }

    return DistanceModel(
      commandTime: parse(sp[0]),
      actionTime: parse(sp[1]),
      distance: parse(sp[2]),
    );
  }

  String toParseString() {
    return [commandTime, actionTime, distance].join(defaultSeperator);
  }

  List<int> toBytes() {
    final st = toParseString();
    return utf8.encode(st);
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
