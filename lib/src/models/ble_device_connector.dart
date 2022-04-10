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

  final Map<DeviceModel, StreamSubscription<DeviceStatusMapEntry>>
      _connections = {};

  Future<void> connect(DeviceModel device) async {
    _logMessage('Start connecting to ${device.id}');

    final st = _ble.connectToDevice(id: device.id);

    // _connection
    _connections[device] = st.map(
      (event) {
        return MapEntry(device, event);
      },
    ).listen(
      (update) async {
        _logMessage(
            'ConnectionState for device ${device.id} : ${update.value.connectionState}');

        _deviceConnectionController.add(update);
      },
      onError: (Object e) =>
          _logMessage('Connecting to device ${device.id} resulted in error $e'),
    );
  }

  Future<void> disconnect(DeviceModel device) async {
    try {
      _logMessage('disconnecting to device: ${device.id}');
      await _connections[device]?.cancel();
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
