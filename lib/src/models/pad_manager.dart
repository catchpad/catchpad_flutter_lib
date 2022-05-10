import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/big_guy.dart';
import '../utils/pad_consts.dart';
import 'battery_model.dart';
import 'ble_manager.dart';
import 'dev_info_model.dart';
import 'pad_manager.dart';
import 'pad_sensor_manager.dart';
import 'sensors/config/acc_config_model.dart';
import 'sensors/config/acc_interrupt_config_model.dart';
import 'sensors/config/dst_config_model.dart';
import 'sounds/martilar15s.dart';

export 'sides_colors_model.dart';

abstract class PadManager {
  static Future<bool> toggleLight(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    return await ledColor(
      deviceId,
      const SidesColorsModel(
        tr: Color.fromARGB(255, 255, 255, 0),
        tl: Color.fromARGB(255, 0, 255, 0),
        br: Color.fromARGB(255, 255, 0, 0),
        bl: Color.fromARGB(255, 0, 0, 255),
      ),
      ref: ref,
    );
  }

  static Future<bool> ledOff(
    String deviceId, {
    required WidgetRef ref,
    bool isCommand = false,
  }) async {
    return await ledColor(
      deviceId,
      SidesColorsModel.off(),
      ref: ref,
      isCommand: isCommand,
    );
  }

  static Future<bool> randomColors(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    for (var i = 0; i < 100; i++) {
      await ledColor(
        deviceId,
        // random color
        SidesColorsModel.all(BigGuy.randomColor()),
        ref: ref,
      );
    }

    return true;
  }

  static Future<bool> sendIsCommand(
    String deviceId, {
    required WidgetRef ref,
  }) {
    return ledColor(
      deviceId,
      const SidesColorsModel(same: true),
      ref: ref,
      isCommand: true,
    );
  }

  static Future<bool> ledColor(
    String deviceId,
    SidesColorsModel colorModel, {
    bool isCommand = false,
    required WidgetRef ref,

    /// for how long to flash the led
    /// if null, it will flash forever
    Duration? duration,
  }) async {
    final led = await _ledColor(
      deviceId,
      colorModel,
      isCommand: isCommand,
      ref: ref,
    );

    if (duration != null) {
      await Future.delayed(duration);
      await ledOff(
        deviceId,
        ref: ref,
      );
    }

    return led;
  }

  static Future<bool> _ledColor(
    String deviceId,
    SidesColorsModel colorModel, {
    bool isCommand = false,
    required WidgetRef ref,
  }) async {
    final dt = [
      BigGuy.boolToNumString(isCommand),
      colorModel,
    ].join(defaultSeperator);
    final charac = colorModel.allColorsSame
        ? ledAllCharacteristic.qualCharacteristic(deviceId)
        : ledCharacteristic.qualCharacteristic(deviceId);

    return await BleManager.writeCharacteristic(
      c: charac,
      data: utf8.encode(dt),
      withResponse: false,
      ref: ref,
    );
  }

  /// restart the device
  static Future<bool> resetDevice(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    const dt = 'R';
    return await BleManager.writeCharacteristic(
      c: adminCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: false,
      ref: ref,
    );
  }

  static Future<bool> resetDeviceSettings(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    return (await Future.wait<bool>(
      [
        PadSensorManager.configAccSensor(
          deviceId: deviceId,
          ref: ref,
          model: const AccConfigModel(
            scale: defConfigScale,
            mode: defConfigMode,
            dataRate: defDataRate,
            threshold: defAccThreshold,
            timeout: defAccTimeOut,
          ),
        ),
        PadSensorManager.configAccInterruptSensor(
          deviceId: deviceId,
          ref: ref,
          model: const AccInterruptConfigModel(
            scale: defConfigIntScale,
            mode: defConfigIntMode,
            dataRate: defIntDataRate,
            threshold: defAccIntThreshold,
            duration: defAccIntDuration,
            timeout: defAccTimeOut,
            sleepEnable: defSleepEnable,
          ),
        ),
        PadSensorManager.configDstSensor(
          deviceId: deviceId,
          ref: ref,
          model: const DstConfigModel(
            threshold: defDstThreshold,
            timeout: defDstTimeOut,
          ),
        ),
      ],
    ))
        .every((element) => element == true);
  }

  static Future<bool> toggleDebug(
    String deviceId, {
    required bool enable,
    AdminMonitorType type = AdminMonitorType.serial,
    required WidgetRef ref,
  }) async {
    final dt = [BigGuy.boolToInt(enable), type.index].join(defaultSeperator);
    return await BleManager.writeCharacteristic(
      c: adminCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  // #region device info
  static Future<bool> _sendGetDeviceInfoSignal(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    const dt = '?';

    return await BleManager.writeCharacteristic(
      c: infoCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  static Future<DevInfoModel> getDeviceInfo(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    await _sendGetDeviceInfoSignal(deviceId, ref: ref);
    final dt = await BleManager.readCharacteristic(
      infoCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    );

    return DevInfoModel.fromBytes(dt);
  }

  static Future<bool> setDeviceName(
    String deviceId, {
    required WidgetRef ref,
    required String name,
  }) async {
    final dt = ['SETNAME', name].join(defaultSeperator);

    return await BleManager.writeCharacteristic(
      c: infoCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  // #region battery
  static Future<bool> _sendGetBatterySignal(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    const dt = '?';

    return await BleManager.writeCharacteristic(
      c: batteryCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  static Future<BatteryModel> readBattery(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    await _sendGetBatterySignal(deviceId, ref: ref);
    BatteryModel? bat;

    // WHY???
    // well, it's basic math
    // when we write a '?' on the characteristic,
    // apparently its shared, so when we read it,
    // we will get the '?' that we sent, if the
    // device has not written anything yet
    // so we keep reading until we get real data
    // that the device has written
    while (bat == null) {
      final dt = await BleManager.readCharacteristic(
        batteryCharacteristic.qualCharacteristic(deviceId),
        ref: ref,
      );

      bat = BatteryModel.fromBytes(dt);
    }
    return bat;
  }

  static Stream<BatteryModel> listenToBattery(
    String deviceId, {
    required WidgetRef ref,
  }) async* {
    yield await readBattery(deviceId, ref: ref);
    yield* BleManager.subscribeToCharacteristic(
      batteryCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    )
        .map((dt) => BatteryModel.fromBytes(dt))
        .where((event) => event != null)
        .map((event) => event!);
  }
  // #endregion

  // #endregion

  // #region audio

  static Future<bool> _turnAudio(
      WidgetRef ref, String deviceId, bool enable) async {
    return await BleManager.writeCharacteristic(
      c: audioCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(enable ? 'ON' : 'OFF'),
      withResponse: true,
      ref: ref,
    );
  }

  static Future<bool> _turnAudioOn(WidgetRef ref, String deviceId) =>
      _turnAudio(ref, deviceId, true);

  static Future<bool> _turnAudioOff(WidgetRef ref, String deviceId) =>
      _turnAudio(ref, deviceId, false);

  static Future<bool> playAudio(
    String deviceId, {
    required WidgetRef ref,
    // required String fileName,
    double level = 1.0,
  }) async {
    assert(level >= 0.0 && level <= 1.0);

    await _turnAudioOn(ref, deviceId);

    const data = martilar15s;

    const wholeSize = 500;
    const width = 1;

    // 500
    const size = wholeSize ~/ width;

    // [08 -> 8, 1f -> 31, 2d -> 45, ...]
    final st = data.map((e) => (e * level).toInt()).toList();

    final len = st.length;

    bool b = false;
    int indx = 0;

    final sw = Stopwatch();
    final sums = <int>[];

    while (!b) {
      final start = indx * size;
      final end = min((indx + 1) * size, len);

      b = end == len;

      // list of current 500
      final ls = st.sublist(start, end);

      sw.start();
      await BleManager.writeCharacteristic(
        c: audioCharacteristic.qualCharacteristic(deviceId),
        data: ls,
        withResponse: false,
        ref: ref,
      );
      sw.stop();
      int s = sw.elapsedMilliseconds;
      sums.add(s);
      debugPrint('ms $indx: $s');

      indx++;
    }

    await _turnAudioOff(ref, deviceId);

    debugPrint(
        'played into total of ${sw.elapsedMilliseconds}ms, avg ${sw.elapsedMilliseconds / indx}ms');
    debugPrint(sums.toString());

    return true;
  }

  // #endregion

}

/// where to print the debug info
enum AdminMonitorType {
  serial,
  ble,
}
