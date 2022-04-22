import 'dart:convert';

import '../../utils/big_guy.dart';
import '../../utils/pad_consts.dart';

class AcceleremetorTapModel {
  final int commandTime, actionTime;
  final int tapCounter;

  Duration? get responseTime => BigGuy.responseTime(actionTime, commandTime);

  const AcceleremetorTapModel({
    required this.commandTime,
    required this.actionTime,
    required this.tapCounter,
  });

  factory AcceleremetorTapModel.fromBytes(List<int> bytes) {
    // format: command_time/action_time/tap_counter
    final s = utf8.decode(bytes);
    final sp = s.split(defaultSeperator);

    return AcceleremetorTapModel(
      commandTime: int.parse(sp[0]),
      actionTime: int.parse(sp[1]),
      tapCounter: int.parse(sp[2]),
    );
  }

  String toParseString() {
    return [commandTime, actionTime, tapCounter].join(defaultSeperator);
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
      'tapCounter': tapCounter,
      'responseTime': responseTime,
    }.entries.map((e) => e.key + ': ' + e.value.toString()).join('\n');
  }
}
