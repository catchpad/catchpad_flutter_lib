import '../../device_model.dart';

abstract class SensorEvent {
  final String deviceId;

  const SensorEvent(this.deviceId);

  bool equalsDevice(DeviceModel dev) => deviceId == dev.id;

  /// currently we don't have any rules of validity,
  /// so we just return true
  bool get isValid => true;

  String get deviceNameId => deviceId;
}
