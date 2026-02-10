import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef DeviceStatusMapProvider = StateProvider<DeviceStatusMap>;

typedef DeviceStatusMap = Map<DeviceModel, ConnectionStateUpdate>;

typedef DeviceStatusMapEntry = MapEntry<DeviceModel, ConnectionStateUpdate>;

final bleConenctionStateProv = StreamProvider<DeviceStatusMap>(
  (ref) async* {
    final con = ref.watch(bleDeviceConnectorProv);
    final reconnectAttemptAt = <String, DateTime>{};
    const reconnectCooldown = Duration(seconds: 4);

    final st = con.state;

    await for (final el in st) {
      final device = el.value;

      if (device.failure != null) {
        logger.e(device.failure!.message);
      }

      ref.read(bleConPr.notifier).updateEntry(el);

      // Auto connect.We check if we are in any game we trying connect again to pad.
      // And we adding to RandomlyDiscoveredList list that disconnected pad

      if (ref.read(bleAutoConnectStateNotifierProv) &&
          el.value.connectionState == DeviceConnectionState.disconnected) {
        final now = DateTime.now();
        final lastAttempt = reconnectAttemptAt[el.key.id];
        if (lastAttempt != null &&
            now.difference(lastAttempt) < reconnectCooldown) {
          logger.w('Auto reconnect skipped for ${el.key.id}: cooldown active');
          continue;
        }

        reconnectAttemptAt[el.key.id] = now;
        reconnectAttemptAt.removeWhere(
          (_, attemptedAt) =>
              now.difference(attemptedAt) > const Duration(minutes: 1),
        );

        ref.read(bleAutoConnectStateNotifierProv.notifier).changState(false);

        try {
          ref
              .read(randomlyDisconnectedDevProv.notifier)
              .addDiscoveredDevice(el.key);

          final deviceConnector = ref.read(bleDeviceConnectorProv);
          await deviceConnector.connect(el.key);
        } catch (e) {
          logger.e('Auto reconnect failed for ${el.key.id}: $e');
        } finally {
          ref.read(bleAutoConnectStateNotifierProv.notifier).changState(true);
        }
      }
    }
  },
);

final bleConPr =
    StateNotifierProvider<BleConnectionStateNotifier, DeviceStatusMap>(
  (ref) {
    return BleConnectionStateNotifier();
  },
);

class BleConnectionStateNotifier extends StateNotifier<DeviceStatusMap> {
  BleConnectionStateNotifier() : super({});

  void deleteFromId(String deviceModelId) {
    DeviceStatusMap newM = {};

    newM = state;

    DeviceModel chooseDeviceModel =
        state.keys.firstWhere((element) => element.id == deviceModelId);
    newM.remove(chooseDeviceModel);

    state = newM;

    DeviceStatusMap deviceStatusMap = {};

    state.forEach((key, value) {
      if (!deviceStatusMap.keys.any((pDevice) => pDevice.id == key.id)) {
        deviceStatusMap.addAll({key: value});
      }
    });

    state = deviceStatusMap;
  }

  void updateDevice(DeviceModel d, DeviceConnectionState conState) =>
      update(d, conState);

  void updateEntry(DeviceStatusMapEntry entry) =>
      update(entry.key, entry.value.connectionState);

  void update(DeviceModel device, DeviceConnectionState conState) {
    DeviceStatusMap newM = {};

    for (var item in state.entries) {
      if (item.key.id == device.id) {
        newM[item.key] = item.value.copyWith(connectionState: conState);
      } else {
        newM[item.key] = item.value;
      }
    }

    // Keep non-disconnected states (e.g. connecting) so callers do not
    // continuously issue duplicate connect requests while a connection
    // attempt is already in progress.
    if (conState != DeviceConnectionState.disconnected) {
      final hasEntry = newM.keys.any((k) => k.id == device.id);
      if (!hasEntry) {
        newM[device] = ConnectionStateUpdate(
          connectionState: conState,
          deviceId: device.id,
          failure: null,
        );
      }
    } else {
      newM.removeWhere((key, _) => key.id == device.id);
    }
    state = newM;

    DeviceStatusMap deviceStatusMap = {};

    state.forEach((key, value) {
      if (!deviceStatusMap.keys.any((pDevice) => pDevice.id == key.id)) {
        deviceStatusMap.addAll({key: value});
      }
    });

    state = deviceStatusMap;
  }
}

final connectedDevicesProv =
    StateNotifierProvider<ConnectedDevicesNotifier, DevList>(
  (ref) {
    return ConnectedDevicesNotifier();
  },
);

class ConnectedDevicesNotifier extends StateNotifier<DevList> {
  ConnectedDevicesNotifier() : super([]);

  void addDevice(DeviceModel d) {
    state = List.from(state)..add(d);
  }

  void removeDevice(DeviceModel d) {
    state = List.from(state)..removeWhere((element) => element.id == d.id);
  }

  void updateDevice(DeviceModel d) {
    final DevList ls = List.from(state);
    ls.removeWhere((element) => element.id == d.id);
    ls.add(d);
    state = ls;
  }
}
