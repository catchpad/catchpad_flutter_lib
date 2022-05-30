import '../../device_model.dart';

abstract class SensorEvent {
  final String deviceId;

  const SensorEvent(this.deviceId);

  bool equalsDevice(DeviceModel dev) => deviceId == dev.id;

  bool get isValid;

  String get deviceNameId {
    final par = int.tryParse(deviceId);
    if (par != null) {
      return '$par';
    }

    var sp = deviceId.split('-');

    return sp[1];
  }
}
