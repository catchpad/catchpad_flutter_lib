import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef DeviceModel = DiscoveredDevice;
typedef DevList = List<DeviceModel>;

extension CatchpadConnection on ConnectionStateUpdate {
  bool get isConnected => connectionState == DeviceConnectionState.connected;
}

extension CpDiscoveredDevice on DiscoveredDevice {
  /// Cihazın CatchPad olup olmadığını kontrol eder
  /// Desteklenen formatlar:
  /// - "X CatchPad" (örn: "1 CatchPad", "12 CatchPad")
  /// - Sadece rakam (örn: "1", "2", "8", "12") - 1-12 arası
  bool get isCPDevice {
    // Format 1: "catchpad" içeren isimler
    if (name.toLowerCase().contains('catchpad')) {
      return true;
    }
    // Format 2: Sadece rakam (1-12 arası)
    final trimmed = name.trim();
    final number = int.tryParse(trimmed);
    if (number != null && number >= 1 && number <= 12) {
      return true;
    }
    return false;
  }

  int? get deviceNumber {
    final d = deviceNameId;
    if (d == null) return null;
    return int.tryParse(d);
  }

  /// Cihaz isminden pad numarasını çıkarır
  /// Desteklenen formatlar:
  /// - "X CatchPad" -> "X" döner (örn: "1 CatchPad" -> "1")
  /// - Sadece rakam -> direkt döner (örn: "2" -> "2", "8" -> "8")
  String? get deviceNameId {
    // Format 1: "X CatchPad" pattern
    List<String> sp = name.split(' ');
    if (sp.length == 2) {
      return sp[0];
    }

    // Format 2: Sadece rakam (1-12 arası)
    final trimmed = name.trim();
    final number = int.tryParse(trimmed);
    if (number != null && number >= 1 && number <= 12) {
      return trimmed;
    }

    return null;
  }

  Future<String?> deviceStickerId(WidgetRef ref) async {
    if (deviceNumber != null) {
      return deviceNumber.toString();
    }

    final sp = deviceNameId?.split('sticker_title');

    if (sp == null || sp.isEmpty) {
      assert(false);
      return null;
    }

    final stId = sp[1];
    return stId;
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

  Map<String, dynamic> toJson({Color? color}) {
    return {
      'id': id,
      'name': name,
      'color': color?.toHexTriplet()
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
extension ColorX on Color {
  String toHexTriplet() => '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}