import 'dart:async';
import 'dart:io';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catchpad_flutter_lib_init.dart';
import '../provs/ble_connection_state_prov.dart';
import '../provs/ble_prov.dart';
import 'device_model.dart';
import 'reactive_state.dart';

class BleDeviceConnector extends ReactiveState<DeviceStatusMapEntry> {
  BleDeviceConnector(this.ref) : _ble = ref.watch(bleProv);

  final Ref ref;

  final FlutterReactiveBle _ble;

  @override
  Stream<DeviceStatusMapEntry> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<DeviceStatusMapEntry>();

  final Map<String, StreamSubscription<DeviceStatusMapEntry>> _connections = {};

  int get activeConnectionCount => _connections.length;

  Future<void> connect(DeviceModel device) async {
    // Prevent duplicate subscriptions for the same device id
    await _connections[device.id]?.cancel();
    _connections.remove(device.id);

    final st = _ble.connectToDevice(
      id: device.id,
    );


    /// Android only
    if (Platform.isAndroid)
    {

      _ble.requestConnectionPriority(
          deviceId: device.id,
          priority: ConnectionPriority.highPerformance
      );

    }

    _updateStat(
        MapEntry<DiscoveredDevice, ConnectionStateUpdate> update) async {


      if (update.value.isConnected) {
        final mt = await _ble.requestMtu(deviceId: device.id, mtu: 512);

      }

      _deviceConnectionController.add(update);
    }

    /// initially we wanna make the connection status 'disconnecting',
    /// because on auto connect, we're requesting so many connections
    /// that the connector is giving us a connection state update only
    /// when the connection is established.
    /// this is an innocent step and it would not affect anything.
    _updateStat(
      MapEntry(
        device,
        ConnectionStateUpdate(
          connectionState: DeviceConnectionState.connecting,
          deviceId: device.id,
          failure: null,
        ),
      ),
    );
    // _connection
    _connections[device.id] = st.map(
          (event) {
        return MapEntry(device, event);
      },
    ).listen(
      _updateStat,
      onError: (Object e) =>
          logger.e('Connecting to device ${device.id} resulted in error $e'),
    );
  }

  Future<void> disconnect(DeviceModel device) async {
    try {

      await _connections[device.id]?.cancel();
      _connections.remove(device.id);
    } on Exception catch (e) {
      logger.e("Error disconnecting from a device: $e");
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
