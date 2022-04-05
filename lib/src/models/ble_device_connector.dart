import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../provs/ble_connection_state_prov.dart';
import 'device_model.dart';
import 'reactive_state.dart';

class BleDeviceConnector extends ReactiveState<DeviceStatusMapEntry> {
  BleDeviceConnector({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;

  @override
  Stream<DeviceStatusMapEntry> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<DeviceStatusMapEntry>();

  late StreamSubscription<DeviceStatusMapEntry> _connection;

  Future<void> connect(DeviceModel device) async {
    _logMessage('Start connecting to ${device.id}');

    final st = _ble.connectToDevice(id: device.id);

    // _connection
    _connection = st.map(
      (event) {
        return MapEntry(device, event);
      },
    ).listen(
      (update) async {
        _logMessage(
            'ConnectionState for device ${device.id} : ${update.value.connectionState}');
        debugPrint(
            'ConnectionState for device ${device.id} : ${update.value.connectionState}');

        // FUTURE: this maybe needed later, when
        // we start personal sales, for now it is
        // not necessary
        // if (update.value.isConnected &&
        //     // requestConnectionPriority does not work on iOS
        //     Platform.isAndroid) {
        //   await _ble.requestConnectionPriority(
        //       deviceId: deviceId, priority: ConnectionPriority.highPerformance);
        // }

        _deviceConnectionController.add(update);

        final mt = await _ble.requestMtu(deviceId: device.id, mtu: 512);
        debugPrint('mtu request: $mt');
      },
      onError: (Object e) =>
          _logMessage('Connecting to device ${device.id} resulted in error $e'),
    );
  }

  // TODO: this does not work properly
  Future<void> disconnect(DeviceModel device) async {
    try {
      _logMessage('disconnecting to device: ${device.id}');
      await _connection.cancel();
    } on Exception catch (e, _) {
      _logMessage("Error disconnecting from a device: $e");
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _deviceConnectionController.add(
        MapEntry(
          device,
          ConnectionStateUpdate(
            deviceId: device.id,
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      );
    }
  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}
