import 'dart:async';

import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleConnectionCheckProvider =
StateNotifierProvider<BleConnectionCheckStateControlNotifier, bool>(
        (_) => BleConnectionCheckStateControlNotifier(false));
class BleConnectionCheckStateControlNotifier extends StateNotifier<bool> {
  BleConnectionCheckStateControlNotifier(bool state) : super(false);

  Timer? resumeTimer;
  Timer? pauseTimer;

  void changState(bool val) => state = val;

  //Initialize listen ble!
  void startListenToBleResumeState(WidgetRef ref) {
    final scan = ref.watch(bleScanStreamProv);
    scan.when(
        data: (data) {
          final conMap = ref.watch(bleConPr);

          final anyConnectedDevice = conMap.values.any((element) =>
              element.connectionState == DeviceConnectionState.connected);

          //If i connect to any device look to resumeTimer if null start periodically start flag
          if (anyConnectedDevice && resumeTimer == null) {
            resumeTimer =
                Timer.periodic(const Duration(seconds: 5), (timer) async {
              final connectedDevices = conMap.entries.where((element) {
                if (element.value.connectionState ==
                    DeviceConnectionState.connected) {
                  return true;
                } else {
                  return false;
                }
              }).toList();

              final _ftrList = <Future>[];
              for (var perConnectedDevice in connectedDevices) {
                _ftrList.add(PadManager.setConnectionFlagTrue(
                    perConnectedDevice.key.id,
                    ref: ref));
              }

              await Future.wait(_ftrList);
            });
          }

          if (!anyConnectedDevice && resumeTimer != null) {
            resumeTimer!.cancel();
            resumeTimer = null;
          }
        },
        error: (obj, sTrace) {
          logger.e("Error:$obj $sTrace");
        },
        loading: () => debugPrint("loading..."));
  }

  //Listen to AppLifeCycle
  void catchpadConnectionCheck(
      AppLifecycleState appLifecycleState, WidgetRef ref) {
    switch (appLifecycleState) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        pauseTimer?.cancel();
        pauseTimer = null;
        startListenToBleResumeState(ref);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        //Start Timer2
        startListenToBlePauseState(ref);
        break;
    }
  }

  void startListenToBlePauseState(WidgetRef ref) {
    final scan = ref.watch(bleScanStreamProv);

    scan.when(
        data: (data) {
          final conMap = ref.watch(bleConPr);

          final anyConnectedDevice = conMap.values.any((element) =>
              element.connectionState == DeviceConnectionState.connected);

          //If i connect to any device look to resumeTimer if null start periodically start flag
          if (anyConnectedDevice && pauseTimer == null) {
            pauseTimer =
                Timer.periodic(const Duration(seconds: 5), (timer) async {
              final connectedDevices = conMap.entries.where((element) {
                if (element.value.connectionState ==
                    DeviceConnectionState.connected) {
                  return true;
                } else {
                  return false;
                }
              }).toList();

              final _ftrList = <Future>[];
              for (var perConnectedDevice in connectedDevices) {
                _ftrList.add(PadManager.setConnectionFlagTrue(
                    perConnectedDevice.key.id,
                    ref: ref));
              }

              await Future.wait(_ftrList);
            });
          }

          if (!anyConnectedDevice && pauseTimer != null) {
            pauseTimer!.cancel();
            pauseTimer = null;
          }
        },
        error: (obj, sTrace) {
          logger.e("Error:$obj $sTrace");
        },
        loading: () => debugPrint("loading..."));
  }
}
