import 'dart:math' as math;

import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';

class BatteryModel {
  final double? voltage;
  final bool isCharging;
  final bool isCompleted;

  BatteryModel({
    required this.voltage,
    required this.isCharging,
    required this.isCompleted,
  });

  int get percentage => voltageToPercentage(voltage);

  static BatteryModel? fromBytes(List<int> bytes) {
    final st = String.fromCharCodes(bytes);

    final sp = st.split('/');

    if (sp.length != 3) {
      return null;
    }

    return BatteryModel(
      isCompleted: BigGuy.intToBool(int.tryParse(sp[0]) ?? 0),
      isCharging: BigGuy.intToBool(int.tryParse(sp[1]) ?? 0),
      voltage: double.tryParse(sp[2]),
    );
  }

  @override
  String toString() {
    return [
      'Voltage: ' + (voltage ?? 'null').toString(),
      'Percentage: ' '%' + percentage.toString(),
      'Is Charging: ' + (isCharging ? 'true' : 'false'),
      'Is Completed: ' + (isCompleted ? 'true' : 'false'),
    ].join('\n');
  }

  double closestNumMin(double vol) {
    return closestNums(vol)[0];
  }

  double closestNumMax(double vol) {
    return closestNums(vol)[1];
  }

  List<double> closestNums(double vol) {
    final keys = voltagePercentageMap.keys.toList();

    final max = keys.reduce((value, element) => math.max(value, element)) + .0;
    final min = keys.reduce((value, element) => math.min(value, element)) + .0;
    double b = max, s = min;

    if (vol > max) {
      b = s = max;
    } else if (vol < min) {
      b = s = min;
    } else {
      for (var i = 0; i < keys.length; i++) {
        final a = keys[i] + .0;

        if (a >= vol && a < b) {
          b = a;
        }

        if (a <= vol && a > s) {
          s = a;
        }
      }
    }

    return [s, b];
  }

  int voltageToPercentage(double? vol) {
    if (vol == null) {
      return 0;
    }

    final key = closestNumMax(vol);

    return voltagePercentageMap[key]!;
  }

  static const Map<int, int> voltagePercentageMap = {
    4200: 100,
    4100: 92,
    4000: 78,
    3900: 61,
    3800: 43,
    3700: 14,
    3600: 3,
    3500: 1,
    3400: 0,
    3300: 0,
    3200: 0,
  };
}
