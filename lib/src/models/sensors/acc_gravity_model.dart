import 'dart:convert';

class AcceleremetorGravityModel {
  final double x, y, z, temperature;

  const AcceleremetorGravityModel({
    required this.x,
    required this.y,
    required this.z,
    required this.temperature,
  });

  factory AcceleremetorGravityModel.fromBytes(List<int> bytes) {
    final s = utf8.decode(bytes);
    final sp = s.split('/');

    return AcceleremetorGravityModel(
      x: double.parse(sp[0]),
      y: double.parse(sp[1]),
      z: double.parse(sp[2]),
      temperature: double.parse(sp[3]),
    );
  }

  @override
  String toString() {
    return 'AcceleremetorGravityModel{x: $x, y: $y, z: $z, temperature: $temperature}';
  }
}
