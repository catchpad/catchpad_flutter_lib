import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'pad_manager.dart';

typedef DeviceModel = DiscoveredDevice;
typedef DevList = List<DeviceModel>;

extension CatchpadConnection on ConnectionStateUpdate {
  bool get isConnected => connectionState == DeviceConnectionState.connected;
}

extension CpDiscoveredDevice on DiscoveredDevice {
  bool get isCPDevice => isV2Running || name.toLowerCase().contains('catchpad');
  bool get isV2 {
    return isV2Running;
    // return name.toLowerCase().contains('cphw02');
  }

  bool get isV1 => !isV2;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static DeviceModel fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      manufacturerData: Uint8List.fromList([]),
      rssi: 0,
      serviceData: const {},
      serviceUuids: const [],
    );
  }
}
