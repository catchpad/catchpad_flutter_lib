import 'dart:convert';

class AcceleremetorGravityModel {
  final int x, y, z, temperature;

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
      x: int.parse(sp[0]),
      y: int.parse(sp[1]),
      z: int.parse(sp[2]),
      temperature: int.parse(sp[3]),
    );
  }

  @override
  String toString() {
    return 'AcceleremetorGravityModel{x: $x, y: $y, z: $z, temperature: $temperature}';
  }
}
