// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'ble_manager.dart';
import 'sensors/acc_gravity_model.dart';
import 'sensors/acc_tap_model.dart';
import '../utils/big_guy.dart';
import '../utils/pad_consts.dart';

import 'sensors/dst_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async/async.dart' show StreamGroup;

import 'sensors/events/distance_event.dart';
import 'sensors/events/motion_event.dart';
import 'sensors/events/touch_event.dart';

/// the Accelederometer sensor has 2 modes, gravity
/// and tap. even though it streams on the same characteristic,
/// the shape of data it streams is different.
enum AccSensorType { tap, gravity }

enum SensorType { acc, dst, vel }

/// as in the multimeter, the lower the number, the more accurate the reading
enum ConfigScale {
  LIS2DH12_2g,
  LIS2DH12_4g,
  LIS2DH12_8g,
  LIS2DH12_16g,
}

/// the higher the bitrate is, the more accurate the reading
enum ConfigMode {
  LIS2DH12_HR_12bit,
  LIS2DH12_NM_10bit,
}

/// how many calculation in 1 second,
/// keeping at 1khz is the most ideal
enum DataRate {
  LIS2DH12_POWER_DOWN,
  LIS2DH12_ODR_1Hz,
  LIS2DH12_ODR_10Hz,
  LIS2DH12_ODR_25Hz,
  LIS2DH12_ODR_50Hz,
  LIS2DH12_ODR_100Hz,
  LIS2DH12_ODR_200Hz,
  LIS2DH12_ODR_400Hz,
  LIS2DH12_ODR_1kHz620_LP,
  LIS2DH12_ODR_5kHz376_LP_1kHz344_NM_HP,
}

abstract class PadSensorManager {
  // #region activate

  // #region dst methods
  static Future<bool> activateDst({
    required WidgetRef ref,
    required String deviceId,
  }) async {
    return _activate(
      sensorType: SensorType.dst,
      status: true,
      ref: ref,
      deviceId: deviceId,
    );
  }

  static Future<bool> deactivateDst({
    required WidgetRef ref,
    required String deviceId,
  }) async {
    return _activate(
      sensorType: SensorType.dst,
      status: false,
      ref: ref,
      deviceId: deviceId,
    );
  }

  static Future<bool> lockDstThreshold({
    required WidgetRef ref,
    required String deviceId,
  }) =>
      _lockThreshold(
        sensorType: SensorType.dst,
        ref: ref,
        deviceId: deviceId,
      );

  static Future<bool> unlockDstThreshold({
    required WidgetRef ref,
    required String deviceId,
  }) =>
      _unlockThreshold(
        sensorType: SensorType.dst,
        ref: ref,
        deviceId: deviceId,
      );

  // #endregion

  // #region acc methods
  static Future<bool> activateAccGravity({
    required WidgetRef ref,
    required String deviceId,
  }) async {
    return _activate(
      sensorType: SensorType.acc,
      accSensorType: AccSensorType.gravity,
      status: true,
      ref: ref,
      deviceId: deviceId,
    );
  }

  static Future<bool> activateAccTap({
    required WidgetRef ref,
    required String deviceId,
  }) async {
    return _activate(
      sensorType: SensorType.acc,
      accSensorType: AccSensorType.tap,
      status: true,
      ref: ref,
      deviceId: deviceId,
    );
  }

  static Future<bool> deactivateAcc({
    required WidgetRef ref,
    required String deviceId,
  }) async {
    return _activate(
      sensorType: SensorType.acc,
      accSensorType: AccSensorType.values[0],
      status: false,
      ref: ref,
      deviceId: deviceId,
    );
  }

  static Future<bool> lockAccGravityThreshold({
    required WidgetRef ref,
    required String deviceId,
  }) =>
      _lockThreshold(
        sensorType: SensorType.acc,
        accSensorType: AccSensorType.gravity,
        ref: ref,
        deviceId: deviceId,
      );

  static Future<bool> unlockAccGravityThreshold({
    required WidgetRef ref,
    required String deviceId,
  }) =>
      _unlockThreshold(
        sensorType: SensorType.acc,
        accSensorType: AccSensorType.gravity,
        ref: ref,
        deviceId: deviceId,
      );

  static Future<bool> lockAccTapThreshold({
    required WidgetRef ref,
    required String deviceId,
  }) =>
      _lockThreshold(
        sensorType: SensorType.acc,
        accSensorType: AccSensorType.tap,
        ref: ref,
        deviceId: deviceId,
      );

  static Future<bool> unlockAccTapThreshold({
    required WidgetRef ref,
    required String deviceId,
  }) =>
      _unlockThreshold(
        sensorType: SensorType.acc,
        accSensorType: AccSensorType.tap,
        ref: ref,
        deviceId: deviceId,
      );

  // #endregion

  static Future<bool> _lockThreshold({
    required SensorType sensorType,
    required WidgetRef ref,
    required String deviceId,
    AccSensorType? accSensorType,
  }) async {
    return _activate(
      sensorType: sensorType,
      status: true,
      ref: ref,
      deviceId: deviceId,
      accSensorType: accSensorType,
      // this kinda works in reverse, the comment in _activate
      thrLock: false,
    );
  }

  static Future<bool> _unlockThreshold({
    required SensorType sensorType,
    required WidgetRef ref,
    required String deviceId,
    AccSensorType? accSensorType,
  }) async {
    return _activate(
      sensorType: sensorType,
      status: true,
      ref: ref,
      deviceId: deviceId,
      accSensorType: accSensorType,
      // this kinda works in reverse, the comment in _activate
      thrLock: true,
    );
  }

  static Future<bool> _activate({
    required SensorType sensorType,
    AccSensorType? accSensorType,

    /// true if enable, false if disable
    required bool status,

    /// wether to respect the threshold or not.
    /// if true, the sensor will keep streaming
    /// even if the threshold is not met.
    bool thrLock = false,
    required WidgetRef ref,
    required String deviceId,
  }) {
    // SENSOR TYPE NAME	/	SENSOR STATUS	/	ACC SENSOR TYPE	/	THRLOCK
    final dt = [
      BigGuy.sensorTypeToStr(sensorType),
      BigGuy.boolToInt(status),
      (accSensorType
              // we have to send a value for the acc sensor type
              // even if it is not used.
              ??
              AccSensorType.values[0])
          .index,
      BigGuy.boolToInt(thrLock),
    ].join(defaultSeperator);
    return BleManager.writeCharacteristic(
      ref: ref,
      c: activateCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
    );
  }
  // #endregion

  // #region config
  static Future<bool> _config({
    required SensorType sensorType,
    required String deviceId,
    required WidgetRef ref,
    ConfigScale? scale = defConfigScale,
    ConfigMode? mode = defConfigMode,
    DataRate? dataRate = defDataRate,

    /// ACC: 0-127
    /// DST: 0-2000
    required int threshold,

    /// 0 - 99999 ms
    required int timeout,
  }) {
    final dt = [
      BigGuy.sensorTypeToStr(sensorType),
      scale?.index,
      mode?.index,
      dataRate?.index,
      threshold,
      timeout,
    ].join(defaultSeperator);

    return BleManager.writeCharacteristic(
      ref: ref,
      c: configCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
    );
  }

  static Future<bool> configAcc({
    required String deviceId,
    required WidgetRef ref,
    required ConfigScale scale,
    required ConfigMode mode,
    required DataRate dataRate,

    /// 0-127
    required int threshold,

    /// 0 - 99999 ms
    required int timeout,
  }) =>
      _config(
        sensorType: SensorType.acc,
        deviceId: deviceId,
        ref: ref,
        scale: scale,
        mode: mode,
        dataRate: dataRate,
        threshold: threshold,
        timeout: timeout,
      );

  static Future<bool> configDst({
    required String deviceId,
    required WidgetRef ref,

    ///  0-2000
    required int threshold,

    /// 0 - 99999 ms
    required int timeout,
  }) =>
      _config(
        sensorType: SensorType.dst,
        deviceId: deviceId,
        ref: ref,
        threshold: threshold,
        timeout: timeout,
      );

  // #endregion

  // #region listeners
  static Stream<DistanceEvent> listenToDistance(
    String deviceId, {
    required WidgetRef ref,
  }) {
    return BleManager.subscribeToCharacteristic(
      dstCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    ).map(
      (bytes) => DistanceEvent(
        deviceId,
        DistanceModel.fromBytes(bytes),
      ),
    );
  }

  static Stream<MotionEvent> listenToMotion(
    String deviceId, {
    required WidgetRef ref,
  }) {
    return BleManager.subscribeToCharacteristic(
      accCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    ).map(
      (bytes) => MotionEvent(
        deviceId,
        AcceleremetorGravityModel.fromBytes(bytes),
      ),
    );
  }

  static Stream<TouchEvent> listenToTouch(
    String deviceId, {
    required WidgetRef ref,
  }) {
    return BleManager.subscribeToCharacteristic(
      accCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    ).map(
      (bytes) => TouchEvent(
        deviceId,
        AcceleremetorTapModel.fromBytes(bytes),
      ),
    );
  }

  static Stream<TouchEvent> listenToTouchMulti(
    Iterable<String> deviceIds, {
    required WidgetRef ref,
  }) {
    return StreamGroup.merge(
      deviceIds.map(
        (deviceId) => listenToTouch(
          deviceId,
          ref: ref,
        ),
      ),
    );
  }
  // #endregion
}
