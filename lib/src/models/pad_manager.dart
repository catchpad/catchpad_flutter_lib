import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:catchpad_flutter_lib/src/models/cp_sound_data.dart';
import 'package:flutter/rendering.dart';

import 'dev_info_model.dart';

import 'ble_manager.dart';
import '../utils/pad_consts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/big_guy.dart';
import 'sides_colors_model.dart';

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
      const SidesColorsModel(),
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
      withResponse: false,
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
      withResponse: false,
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
      withResponse: false,
      ref: ref,
    );
  }
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

    await _turnAudioOff(ref, deviceId);

    const data = cpSoundData;

    const wholeSize = 500;
    const width = 2;
    //250
    const size = wholeSize ~/ width;

    // [08, 1f, 2d, ...]
    final st = data
        .map((e) => (e * level).toInt().toRadixString(16).padLeft(width, '0'))
        .toList();

    final len = st.length;

    bool b = false;
    int indx = 0;

    final sw = Stopwatch();

    while (!b) {
      final start = indx * size;
      final end = min((indx + 1) * size, len);

      b = end == len;

      // list of current 250
      final ls = st.sublist(start, end);

      sw.start();
      await BleManager.writeCharacteristic(
        c: audioCharacteristic.qualCharacteristic(deviceId),
        data: utf8.encode(ls.join()),
        withResponse: false,
        ref: ref,
      );
      sw.stop();

      indx++;
    }

    await _turnAudioOn(ref, deviceId);

    await Future.delayed(const Duration(milliseconds: 1100));

    await _turnAudioOff(ref, deviceId);

    debugPrint(
        'played into total of ${sw.elapsedMilliseconds}ms, avg ${sw.elapsedMilliseconds / indx}ms');

    return true;
  }

  // #endregion

}

/// where to print the debug info
enum AdminMonitorType {
  serial,
  ble,
}
