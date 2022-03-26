class BatteryModel {
  final String chargeLevel;
  final bool isCharging;

  const BatteryModel({
    required this.chargeLevel,
    required this.isCharging,
  });

  factory BatteryModel.parse(List<int> bytes) {
    // the bytes are ascii chars, seperated by '/'
    final par = String.fromCharCodes(bytes);

    final ls = par.split('/');

    // TODO: figure out what the first letter 'L' or 'S' means
    // for some reason S has 2 items, L has 3

    final chargeLevel = ls[1];
    final isCharging = ls[2] == '1';

    return BatteryModel(
      chargeLevel: chargeLevel,
      isCharging: isCharging,
    );
  }

  @override
  String toString() {
    return 'BatteryModel{chargeLevel: $chargeLevel, isCharging: $isCharging}';
  }
}
