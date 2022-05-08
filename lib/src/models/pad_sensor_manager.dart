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

/// well we have `SensorType` but, that does not include
/// sub categories like tap and motion.
enum UsedSensorsType { tap, motion, distance }

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

class AccConfigModel {
  final ConfigScale scale;
  final ConfigMode mode;
  final DataRate dataRate;

  /// 0-127
  final int threshold;

  /// 0 - 99999 ms
  final int timeout;

  const AccConfigModel({
    this.scale = defConfigScale,
    this.mode = defConfigMode,
    this.dataRate = defDataRate,
    required this.threshold,
    required this.timeout,
  });
}

class DstConfigModel {
  ///  0-2000
  final int threshold;

  /// 0 - 99999 ms
  final int timeout;

  const DstConfigModel({
    required this.threshold,
    required this.timeout,
  });
}

class _SensorConfigModel {
  final SensorType sensorType;

  final ConfigScale? scale;
  final ConfigMode? mode;
  final DataRate? dataRate;

  /// ACC: 0-127
  /// DST: 0-2000
  final int threshold;

  /// 0 - 99999 ms
  final int timeout;

  const _SensorConfigModel({
    required this.sensorType,
    this.scale,
    this.mode,
    this.dataRate,
    required this.threshold,
    required this.timeout,
  });

  factory _SensorConfigModel.fromAccConfigModel(AccConfigModel accConfigModel) {
    return _SensorConfigModel(
      sensorType: SensorType.acc,
      scale: accConfigModel.scale,
      mode: accConfigModel.mode,
      dataRate: accConfigModel.dataRate,
      threshold: accConfigModel.threshold,
      timeout: accConfigModel.timeout,
    );
  }

  factory _SensorConfigModel.fromDstConfigModel(DstConfigModel dstConfigModel) {
    return _SensorConfigModel(
      sensorType: SensorType.dst,
      threshold: dstConfigModel.threshold,
      timeout: dstConfigModel.timeout,
    );
  }
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

  static Future<bool> deactivateAccTap({
    required WidgetRef ref,
    required String deviceId,
  }) async {
    return _deactivateAcc(
      ref: ref,
      deviceId: deviceId,
      accSensorType: AccSensorType.tap,
    );
  }

  static Future<bool> deactivateAccGravity({
    required WidgetRef ref,
    required String deviceId,
  }) async {
    return _deactivateAcc(
      ref: ref,
      deviceId: deviceId,
      accSensorType: AccSensorType.gravity,
    );
  }

  static Future<bool> _deactivateAcc({
    required WidgetRef ref,
    required String deviceId,
    required AccSensorType accSensorType,
  }) async {
    return _activate(
      sensorType: SensorType.acc,
      accSensorType: accSensorType,
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
  }) async {
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
    return await BleManager.writeCharacteristic(
      ref: ref,
      c: activateCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
    );
  }

  static Future<bool> deactivateAll({
    required WidgetRef ref,
    required String deviceId,
  }) =>
      _deactivateAll(ref: ref, deviceId: deviceId);

  static Future<bool> _deactivateAll({
    required WidgetRef ref,
    required String deviceId,
  }) async {
    final reqs = [deactivateAccTap, deactivateAccGravity, deactivateDst];

    bool allTrue = true;

    for (final req in reqs) {
      final res = await req(ref: ref, deviceId: deviceId);

      if (!res) {
        allTrue = false;
      }
    }

    return allTrue;
  }
  // #endregion

  // #region config
  static Future<bool> _config({
    required String deviceId,
    required WidgetRef ref,
    required _SensorConfigModel model,
  }) {
    final dt = [
      BigGuy.sensorTypeToStr(model.sensorType),
      model.scale?.index,
      model.mode?.index,
      model.dataRate?.index,
      model.threshold,
      model.timeout,
    ].join(defaultSeperator);

    return BleManager.writeCharacteristic(
      ref: ref,
      c: configCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
    );
  }

  static Future<bool> configAccSensor({
    required String deviceId,
    required WidgetRef ref,
    required AccConfigModel model,
  }) =>
      _config(
        deviceId: deviceId,
        ref: ref,
        model: _SensorConfigModel.fromAccConfigModel(model),
      );

  static Future<bool> configDstSensor({
    required String deviceId,
    required WidgetRef ref,
    required DstConfigModel model,
  }) =>
      _config(
        deviceId: deviceId,
        ref: ref,
        model: _SensorConfigModel.fromDstConfigModel(model),
      );

  // #endregion

  // #region listeners

  // #region distance
  static Stream<DistanceEvent> listenToDistance(
    String deviceId, {
    required WidgetRef ref,
  }) async* {
    await _deactivateAll(
      ref: ref,
      deviceId: deviceId,
    );

    await activateDst(ref: ref, deviceId: deviceId);

    yield* BleManager.subscribeToCharacteristic(
      dstCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    ).map(
      (bytes) => DistanceEvent(
        deviceId,
        DistanceModel.fromBytes(bytes),
      ),
    );
  }

  static Stream<DistanceEvent> listenToDistanceMulti(
    Iterable<String> deviceIds, {
    required WidgetRef ref,
  }) {
    return StreamGroup.merge(
      deviceIds.map(
        (deviceId) => listenToDistance(
          deviceId,
          ref: ref,
        ),
      ),
    );
  }
  // #endregion

  // #region motion
  static Stream<MotionEvent> listenToMotion(
    String deviceId, {
    required WidgetRef ref,
  }) async* {
    await _deactivateAll(
      ref: ref,
      deviceId: deviceId,
    );

    await activateAccGravity(ref: ref, deviceId: deviceId);

    yield* BleManager.subscribeToCharacteristic(
      accCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    ).map(
      (bytes) => MotionEvent(
        deviceId,
        AcceleremetorGravityModel.fromBytes(bytes),
      ),
    );
  }

  static Stream<MotionEvent> listenToMotionMulti(
    Iterable<String> deviceIds, {
    required WidgetRef ref,
  }) {
    return StreamGroup.merge(
      deviceIds.map(
        (deviceId) => listenToMotion(
          deviceId,
          ref: ref,
        ),
      ),
    );
  }
  // #endregion

  // #region touch
  static Stream<TouchEvent> listenToTouch(
    String deviceId, {
    required WidgetRef ref,
  }) async* {
    await _deactivateAll(
      ref: ref,
      deviceId: deviceId,
    );

    await activateAccTap(ref: ref, deviceId: deviceId);

    yield* BleManager.subscribeToCharacteristic(
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

  // #endregion
}
