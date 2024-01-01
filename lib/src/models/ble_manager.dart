import 'dart:async';

import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:catchpad_flutter_lib/src/provs/ble_current_subscribes_prov.dart';
import 'package:catchpad_flutter_lib/src/provs/device/device_info_prov.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catchpad_flutter_lib_init.dart';
import '../provs/ble_prov.dart';

abstract class BleManager {
  static FlutterReactiveBle _inst(WidgetRef ref) => ref.read(bleProv);

  static Future<List<int>?> readCharacteristic(
    QualifiedCharacteristic c, {
    required WidgetRef ref,
  }) async {
    FlutterReactiveBle inst;

    try {
      if (!ref.context.mounted) return [];
      inst = _inst(ref);
    } catch (e) {
      logger.e(e);
      return null;
    }

    List<int> read;

    try {
      read = await inst.readCharacteristic(c);
    } catch (e) {
      logger.e(e);
      return null;
    }

    return read;
  }

  static Future<bool> writeCharacteristic({
    required WidgetRef ref,
    required QualifiedCharacteristic c,
    required List<int> data,
    required bool withResponse,
  }) async {
    FlutterReactiveBle inst;

    try {
      //Called Functions...
      StackTrace stackTrace = StackTrace.current;

      final currentDevInfo = ref
          .read(currentDevInfoManagers)
          .values
          .firstWhere((element) => element.cpId == c.deviceId);

      bool unnecessaryCommand = false;

      if(currentDevInfo.hwVersion != 'v2.0'){
        for (var cp05PerFunction in cp05FunctionsList) {
          if(stackTrace.toString().contains(cp05PerFunction)){
            unnecessaryCommand = true;
          }
        }
      }

      if(unnecessaryCommand) return false;

      if (!ref.context.mounted) return false;

      inst = _inst(ref);
    } catch (e) {
      debugPrint('its in writeCharacteristic and failed');
      logger.e(e);
      return false;
    }

    try {
      if (withResponse) {
        await inst.writeCharacteristicWithResponse(c, value: data);
      } else {
        await inst.writeCharacteristicWithoutResponse(c, value: data);
      }
    } catch (e) {
      logger.e(c.characteristicId.toString() +
          data.toString() +
          withResponse.toString());
      return false;
    }

    return true;
  }

  static Stream<List<int>> subscribeToCharacteristic(
    QualifiedCharacteristic c, {
    required WidgetRef ref,
  }) {
    ref.read(currentQualifiedManagerProv.notifier).add(ref, c);

    return _inst(ref).subscribeToCharacteristic(c);
  }
}
