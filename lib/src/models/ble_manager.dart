import 'dart:async';

import 'package:catchpad_simulator_flutter/catchpad_simulator_flutter.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BleManager {
  static FlutterReactiveBle _inst(WidgetRef ref) => ref.read(bleProv);

  static Future<List<int>> readCharacteristic(
    QualifiedCharacteristic c, {
    required WidgetRef ref,
  }) =>
      _inst(ref).readCharacteristic(c);

  static Future<bool> writeCharacteristic({
    required WidgetRef ref,
    required QualifiedCharacteristic c,
    required List<int> data,
    bool withResponse = false,
  }) async {
    final inst = _inst(ref);
    if (withResponse) {
      await inst.writeCharacteristicWithResponse(c, value: data);
    } else {
      await inst.writeCharacteristicWithoutResponse(c, value: data);
    }

    return true;
  }

  static Stream<List<int>> subscribeToCharacteristic(
    QualifiedCharacteristic c, {
    required WidgetRef ref,
  }) {
    return _inst(ref).subscribeToCharacteristic(c);
  }
}
