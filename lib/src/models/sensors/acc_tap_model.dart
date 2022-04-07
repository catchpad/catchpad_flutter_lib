import 'dart:convert';

class AcceleremetorTapModel {
  final int? commandTime, actionTime;
  final int? tapCounter;

  int? get responseTime {
    if (actionTime == null || commandTime == null) {
      return null;
    }

    return actionTime! - commandTime!;
  }

  const AcceleremetorTapModel({
    required this.commandTime,
    required this.actionTime,
    required this.tapCounter,
  });

  factory AcceleremetorTapModel.fromBytes(List<int> bytes) {
    final s = utf8.decode(bytes);
    final sp = s.split('/');

    return AcceleremetorTapModel(
      commandTime: int.tryParse(sp[0]),
      actionTime: int.tryParse(sp[1]),
      tapCounter: int.tryParse(sp[2]),
    );
  }

  @override
  String toString() {
    return 'AcceleremetorTapModel{commandTime: $commandTime, actionTime: $actionTime, tapCounter: $tapCounter, responseTime: $responseTime}';
  }
}
