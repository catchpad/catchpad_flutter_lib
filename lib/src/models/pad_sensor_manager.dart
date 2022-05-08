// ignore_for_file: constant_identifier_names

import 'dart:convert';

import '../enums/sensors/config/acc_sensor_type.dart';
import '../enums/sensors/config/sensor_type.dart';
import 'ble_manager.dart';
import 'sensors/acc_gravity_model.dart';
import 'sensors/acc_tap_model.dart';
import '../utils/big_guy.dart';
import '../utils/pad_consts.dart';

import 'sensors/config/acc_config_model.dart';
import 'sensors/config/dst_config_model.dart';
import 'sensors/config/sensor_config_model.dart';
import 'sensors/dst_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async/async.dart' show StreamGroup;

import 'sensors/events/distance_event.dart';
import 'sensors/events/motion_event.dart';
import 'sensors/events/touch_event.dart';

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
    required SensorConfigModel model,
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
        model: model.toSensorConfigModel(),
      );

  static Future<bool> configDstSensor({
    required String deviceId,
    required WidgetRef ref,
    required DstConfigModel model,
  }) =>
      _config(
        deviceId: deviceId,
        ref: ref,
        model: model.toSensorConfigModel(),
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
