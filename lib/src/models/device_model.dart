import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

typedef DeviceModel = DiscoveredDevice;
typedef DevList = List<DeviceModel>;

extension CatchpadConnection on ConnectionStateUpdate {
  bool get isConnected => connectionState == DeviceConnectionState.connected;
}

extension CpDiscoveredDevice on DiscoveredDevice {
  bool get isCPDevice => name.toLowerCase().contains('catchpad');

  int? get deviceNumber {
    final d = deviceNameId;
    if (d == null) return null;
    return int.tryParse(d);
  }

  String? get deviceNameId {
    List<String> sp;
    sp = name.split(' ');

    if (sp.length == 2) {
      return sp[0];
    }

    return null;
  }

  static Map<String, String?> devIdNameIdMap(Iterable<DeviceModel> devs) {
    return devs.fold(
      {},
      (Map<String, String?> map, DeviceModel dev) {
        map[dev.id] = dev.deviceNameId;
        return map;
      },
    );
  }
}
