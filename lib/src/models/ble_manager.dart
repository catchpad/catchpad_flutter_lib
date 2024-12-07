import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:catchpad_flutter_lib/src/catchpad_flutter_lib_init.dart';
import 'package:catchpad_flutter_lib/src/provs/ble_current_subscribes_prov.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provs/write_logs_prov.dart';
// import 'dart:io';

abstract class BleManager {
  static FlutterReactiveBle _inst(WidgetRef ref) => ref.read(bleProv);

  static Future<List<int>?> readCharacteristic(QualifiedCharacteristic c, {
    required WidgetRef ref,
  }) async {
    FlutterReactiveBle inst;
    final cDevs = ref.read(currentDevInfoManagers);
    if(!cDevs.containsKey(c.deviceId)) return null;

    // Check if the device is cp06
    final isCp06 =
        ref.read(currentDevInfoManagers)[c.deviceId]?.isCp06 ?? false;


    // If cp06, subscribe and get the value from the stream
    if (isCp06) {
      try {
        logger.d("Detected CP06 device, subscribing to characteristic");
        final completer = Completer<List<int>?>();
        final subscription = subscribeToCharacteristic(c, ref: ref).listen(
              (data) {
            // logger.i("Data: $data");
            // When data arrives, complete the future
            if (!completer.isCompleted) {
              completer.complete(data);
            }
          },
          onError: (error) {
            logger.e("Subscribe error: $error");
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
        );

        // Wait for the first value with a timeout of 5 seconds
        final read = await completer.future
            .timeout(Duration(seconds: Platform.isIOS ? 7 : 5), onTimeout: () {

          subscription.cancel(); // Cancel the subscription on timeout
          return null;
        });

        await subscription.cancel(); // Cleanup after we got the data or timeout
        return read;
      } catch (e) {
        StackTrace currentTrace = StackTrace.current;
        logger.e("$e\n$currentTrace");
        return null;
      }
    }

    try {
      // If not cp06, perform normal read
      if (!ref.context.mounted) {
        logger.e("Context is not mounted");
        return [];
      }
      inst = _inst(ref);
    } catch (e) {
      StackTrace currentTrace = StackTrace.current;
      logger.e("$e\n$currentTrace");
      return null;
    }

    List<int> read;

    try {
      read = await inst.readCharacteristic(c);
      logger.i("Read:\n${String.fromCharCodes(read)}");
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
    bool disableUnnecessaryCommand = false
  }) async {
    FlutterReactiveBle inst;


      if ("015FCC39-5797-8D3D-8E8A-A5FB10465E53" == c.deviceId) return false;
      if (!ref.context.mounted) return false;
      final isCp06 =
          ref.read(currentDevInfoManagers)[c.deviceId]?.isCp06 ?? false;
      String commandStr = String.fromCharCodes(data);

      if (isCp06) {
        commandStr = "$commandStr/";
        data = utf8.encode(commandStr);
      }
      bool unnecessaryCommand = false;
      if (ref.read(currentDevInfoManagers).containsKey(c.deviceId)) {
        //Called Functions...
        StackTrace stackTrace = StackTrace.current;

        final currentDevInfo = ref
            .read(currentDevInfoManagers)
            .values
            .firstWhere((element) => element.deviceId == c.deviceId);

        if (currentDevInfo.hwVersion != 'v2.0') {
          for (var cp05PerFunction in cp05FunctionsList) {
            if (stackTrace.toString().contains(cp05PerFunction) && !disableUnnecessaryCommand) {
              unnecessaryCommand = true;
            }
          }
        }
      }
      if (unnecessaryCommand) return false;
      inst = _inst(ref);

      final beautifulCommand =
          "***\nCommand: $commandStr\nDevice Id: ${c.deviceId}\nDevice Name: ${ref.read(currentDevInfoManagers)[c.deviceId]?.bleName}";


    try {
      final isCp06 =
          ref.read(currentDevInfoManagers)[c.deviceId]?.isCp06 ?? false;
      logger.i("Is Cp06: $isCp06 $commandStr");

      if (withResponse && !isCp06) {

        //cp06 çalışmıyor.
        await inst.writeCharacteristicWithResponse(c, value: data);
        ref.read(writeLogControlNotifierProvider.notifier).addLog(beautifulCommand);
      } else {
        logger.i("Is Cp06: $isCp06 $commandStr");
        //cp05 çalışmıyor.
        // add to data that is "/" character to the end of the data
        // if(isCp06){
        //   data.add(47);
        // }

        await inst.writeCharacteristicWithoutResponse(c, value: data);
        ref.read(writeLogControlNotifierProvider.notifier).addLog(beautifulCommand);
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

  static Stream<List<int>> subscribeToCharacteristic(QualifiedCharacteristic c,
      {
        required WidgetRef ref,
      }) {
    ref.read(currentQualifiedManagerProv.notifier).add(ref, c);

    /// We are checking [currentHasDelayState] if the delay is active.
    /// If it is active, we will not subscribe to the characteristic.
    return _inst(ref).subscribeToCharacteristic(c).where((event) {
      if(event.isNotEmpty){
      }
      return ref.context.mounted && !ref.read(currentHasDelayState);
    }).handleError(
          (e) {
        logger.e(e);
      },
      test: (e) => e is Exception,
    );
  }
}
