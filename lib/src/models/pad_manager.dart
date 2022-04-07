import 'dart:convert';
import 'dart:ui';

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
    ].join('/');
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

  static Future<bool> toggleDebug(
    String deviceId, {
    required bool enable,
    AdminMonitorType type = AdminMonitorType.serial,
    required WidgetRef ref,
  }) async {
    final dt = [BigGuy.boolToInt(enable), type.index].join('/');
    return await BleManager.writeCharacteristic(
      c: adminCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: false,
      ref: ref,
    );
  }
}

/// where to print the debug info
enum AdminMonitorType {
  serial,
  ble,
}
