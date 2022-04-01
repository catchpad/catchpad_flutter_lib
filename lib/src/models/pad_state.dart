import 'dart:ui';

import 'package:flutter/foundation.dart';

@immutable
class PadState {
  final String padId;
  final String name;

  final Color? color;

  final int? battery;
  final int? threshold;
  final int? timerStart;
  final int? responseTime;

  const PadState({
    required this.padId,
    required this.name,
    required this.color,
    required this.battery,
    required this.threshold,
    required this.timerStart,
    required this.responseTime,
  });

  // padId/name/color/battery/threshold/timerStart/responseTime
  factory PadState.fromString(String s) {
    final sp = s.split('/');

    Color? clr;
    final clst = sp[2];
    if (clst.toString() != null.toString()) {
      final sp = clst.split(',');
      final red = int.parse(sp[0]),
          green = int.parse(sp[1]),
          blue = int.parse(sp[2]);

      clr = Color.fromARGB(255, red, green, blue);
    }

    return PadState(
      padId: sp[0],
      name: sp[1],
      color: clr,
      battery: int.tryParse(sp[3]),
      threshold: int.tryParse(sp[4]),
      timerStart: int.tryParse(sp[5]),
      responseTime: int.tryParse(sp[6]),
    );
  }

  // TODO: implement equals
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
      'PadState(padId: $padId, name: $name, color: $color, battery: $battery, threshold: $threshold, timerStart: $timerStart, responseTime: $responseTime)';
}
