import 'dart:async';

import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:catchpad_flutter_lib/src/provs/ble_current_subscribes_prov.dart';
import 'package:catchpad_flutter_lib/src/provs/pad_listen_delay_prov.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BleManager {
  static FlutterReactiveBle _inst(WidgetRef ref) => ref.read(bleProv);

  static Future<List<int>?> readCharacteristic(
      QualifiedCharacteristic c, {
        required WidgetRef ref,

      }) async {
    FlutterReactiveBle inst;

    try {
      // if("015FCC39-5797-8D3D-8E8A-A5FB10465E53" == c.deviceId) return [];
      if (!ref.context.mounted) return [];
      inst = _inst(ref);
    } catch (e) {
      StackTrace currentTrace = StackTrace.current;
      logger.e("$e\n$currentTrace");
      return null;
    }

    List<int> read;

    try {


      read = await inst.readCharacteristic(c);
    } catch (e) {
      StackTrace currentTrace = StackTrace.current;
      logger.e("$e\n$currentTrace");
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
      if("015FCC39-5797-8D3D-8E8A-A5FB10465E53" == c.deviceId) return false;
      if (!ref.context.mounted) return false;

      bool unnecessaryCommand = false;

      print(String.fromCharCodes(data));

      if (ref.read(currentDevInfoManagers).containsKey(c.deviceId)) {
        //Called Functions...
        StackTrace stackTrace = StackTrace.current;

        final currentDevInfo = ref
            .read(currentDevInfoManagers)
            .values
            .firstWhere((element) => element.deviceId == c.deviceId);

        if (currentDevInfo.hwVersion != 'v2.0') {
          for (var cp05PerFunction in cp05FunctionsList) {
            if (stackTrace.toString().contains(cp05PerFunction)) {
              unnecessaryCommand = true;
            }
          }
        } else {}
      }
      if (unnecessaryCommand) return false;
      inst = _inst(ref);
    } catch (e) {
      StackTrace currentTrace = StackTrace.current;
      logger.e("$e\n$currentTrace");
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
          withResponse.toString() +
          e.toString());
      StackTrace stackTrace = StackTrace.current;
      debugPrint("Error: ${stackTrace.toString()}");
    }

    return true;
  }

  static Stream<List<int>> subscribeToCharacteristic(
      QualifiedCharacteristic c, {
        required WidgetRef ref,
      }) {
    ref.read(currentQualifiedManagerProv.notifier).add(ref, c);
    /// We are checking [currentHasDelayState] if the delay is active.
    /// If it is active, we will not subscribe to the characteristic.
    return _inst(ref).subscribeToCharacteristic(c).where((event) =>  ref.context.mounted && !ref.read(currentHasDelayState)).handleError(
          (e) {
        logger.e(e);
      },
      test: (e) => e is Exception,
    );
  }
}
