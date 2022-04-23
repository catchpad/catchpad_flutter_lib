import 'dart:convert';

import 'dart:math';

import '../../utils/pad_consts.dart';

class AcceleremetorGravityModel {
  final double x, y, z, temperature;

  const AcceleremetorGravityModel({
    required this.x,
    required this.y,
    required this.z,
    required this.temperature,
  });

  factory AcceleremetorGravityModel.fromBytes(List<int> bytes) {
    // format: x / y / z / temperature
    final s = utf8.decode(bytes);
    final sp = s.split(defaultSeperator);

    return AcceleremetorGravityModel(
      x: double.parse(sp[0]),
      y: double.parse(sp[1]),
      z: double.parse(sp[2]),
      temperature: double.parse(sp[3]),
    );
  }

  String toParseString() {
    return [x, y, z, temperature].join(defaultSeperator);
  }

  List<int> toBytes() {
    final st = toParseString();
    return utf8.encode(st);
  }

  double get roll {
    return atan2(y, z) * 57.3;
  }

  double get pitch {
    return atan2((-1 * x), sqrt(y * y + z * z)) * 57.3;
  }

  @override
  String toString() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'temperature': temperature,
      'roll': roll,
      'pitch': pitch,
    }.entries.map((e) => e.key + ': ' + e.value.toString()).join('\n');
  }
}
