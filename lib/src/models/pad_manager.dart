import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:async/async.dart' show StreamGroup;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/big_guy.dart';
import '../utils/pad_consts.dart';
import 'battery/battery_model.dart';
import 'ble_manager.dart';
import 'events/touch_event.dart';
import 'sides_colors_model.dart';
export 'sides_colors_model.dart';

abstract class PadManager {
  static Future<BatteryModel> readBattery(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    final bat = await BleManager.readCharacteristic(
      batteryCharacteristic(deviceId),
      ref: ref,
    );

    final model = BatteryModel.parse(bat);

    debugPrint(model.toString());

    return model;
  }

  static Future<bool> toggleLight(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    return await BleManager.writeCharacteristic(
      c: mainCharacteristic(deviceId),
      data: utf8.encode('C'),
      withResponse: false,
      ref: ref,
    );
  }

  static Future<bool> ledOff(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    return await ledColor(
      deviceId,
      SidesColorsModel.off(),
      ref: ref,
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

  static bool _validateSides(String? sides) {
    // if it's null, there's no assertion
    if (sides == null) {
      return false;
    }

    if (sides.length != 4 ||
        !sides.split('').every((element) => element != '0' || element != '1')) {
      assert(false, 'Sides must be 4 digits and only contain 0s and 1s');

      return false;
    }

    return true;
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
    return await BleManager.writeCharacteristic(
      c: ledCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  static Stream<TouchEvent> listenToTouch(
    String deviceId, {
    required WidgetRef ref,
  }) {
    return BleManager.subscribeToCharacteristic(
      simulatorCharacteristic(deviceId),
      ref: ref,
    ).map(TouchEvent.fromBytes);
  }

  static Stream<TouchEvent> listenToTouchMulti(
    Iterable<String> deviceIds, {
    required WidgetRef ref,
  }) {
    return StreamGroup.merge(
      deviceIds.map((deviceId) => listenToTouch(
            deviceId,
            ref: ref,
          )),
    );
  }
}
