import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

typedef DeviceModel = DiscoveredDevice;
typedef DevList = List<DeviceModel>;

extension CatchpadConnection on ConnectionStateUpdate {
  bool get isConnected => connectionState == DeviceConnectionState.connected;
}

extension CpDiscoveredDevice on DiscoveredDevice {
  bool get isCPDevice => name.toLowerCase().contains('catchpad');

  bool get isV1PresentationDevice {
    final range = [25, 26, 27, 28, 29];

    final any = range.any(
      (i) {
        return name.startsWith('$i');
      },
    );

    return any;
  }

  bool get isV2PresentationDevice {
    final range = [35, 36, 37, 38, 39];

    final any = range.any(
      (i) {
        return name.startsWith('$i');
      },
    );

    return any;
  }

  String get deviceListingName {
    if (isV1PresentationDevice) {
      return 'Catchpad Prototip';
    } else if (isV2PresentationDevice) {
      return 'Catchpad';
    } else if (isCPDevice) {
      return 'Catchpad';
    } else {
      return 'Unknown';
    }
  }

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
