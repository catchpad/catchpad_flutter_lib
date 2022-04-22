import '../../catchpad_flutter_lib.dart';
import 'package:flutter/foundation.dart';

class ActivatedSensorsModel {
  final bool tap;
  final bool gravity;
  final bool distance;

  ActivatedSensorsModel({
    required this.tap,
    required this.gravity,
    required this.distance,
  });

  factory ActivatedSensorsModel.fromString(String s) {
    final sp = s.split(subSeperator);

    return ActivatedSensorsModel(
      tap: BigGuy.numStringToBool(sp[0]),
      gravity: BigGuy.numStringToBool(sp[1]),
      distance: BigGuy.numStringToBool(sp[2]),
    );
  }
}

@immutable
class PadState {
  final String padId;
  final String name;

  final SidesColorsModel color;
  final bool isCommand;

  final int? battery;
  final int? threshold;
  final int? timerStart;

  final ActivatedSensorsModel activatedSensors;

  PadState({
    required this.padId,
    required this.name,
    this.isCommand = false,
    SidesColorsModel? color,
    required this.battery,
    required this.threshold,
    required this.timerStart,
    required this.activatedSensors,
  }) : color = color ?? SidesColorsModel.off();

  // padId / name / isComamnd / color / battery / threshold /
  // timerStart / responseTime / activatedSensors
  factory PadState.fromString(String s) {
    final sp = s.split(defaultSeperator);

    return PadState(
      padId: sp[0],
      name: sp[1],
      isCommand: BigGuy.numStringToBool(sp[2]),
      color: SidesColorsModel.fromString(sp.sublist(3, 7).join('/')),
      battery: int.tryParse(sp[7]),
      threshold: int.tryParse(sp[8]),
      timerStart: int.tryParse(sp[9]),
      activatedSensors: ActivatedSensorsModel.fromString(sp[10]),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PadState &&
          runtimeType == other.runtimeType &&
          padId == other.padId;

  @override
  int get hashCode => padId.hashCode;

  @override
  toString() =>
      'PadState(padId: $padId, name: $name, color: $color, battery: $battery, threshold: $threshold, timerStart: $timerStart)';
}
