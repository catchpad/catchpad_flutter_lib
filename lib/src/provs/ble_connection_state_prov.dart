import 'dart:io';

import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef DeviceStatusMapProvider = StateProvider<DeviceStatusMap>;

typedef DeviceStatusMap = Map<DeviceModel, ConnectionStateUpdate>;

typedef DeviceStatusMapEntry = MapEntry<DeviceModel, ConnectionStateUpdate>;

final bleConenctionStateProv = StreamProvider<DeviceStatusMap>(
  (ref) async* {
    final con = ref.watch(bleDeviceConnectorProv);

    final st = con.state;

    await for (final el in st) {
      ref.read(bleConPr.notifier).updateEntry(el);

      // Auto connect.We check if we are in any game we trying connect again to pad.
      // And we adding to RandomlyDiscoveredList list that disconnected pad

      if (ref.read(bleAutoConnectStateNotifierProv) &&
          el.value.connectionState == DeviceConnectionState.disconnected) {
        ref.read(bleAutoConnectStateNotifierProv.notifier).changState(false);

        ref
            .read(randomlyDisconnectedDevProv.notifier)
            .addDiscoveredDevice(el.key);

        final deviceConnector = ref.read(bleDeviceConnectorProv);

        deviceConnector.connect(el.key);

        ref.read(bleAutoConnectStateNotifierProv.notifier).changState(true);
      }

      /// Clear cache if device is connected
      if (el.value.connectionState == DeviceConnectionState.connected  && Platform.isAndroid) {
        ref.read(bleProv).clearGattCache(el.key.id);
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
  }

  void updateDevice(DeviceModel d, DeviceConnectionState conState) =>
      update(d, conState);

  void updateEntry(DeviceStatusMapEntry entry) =>
      update(entry.key, entry.value.connectionState);

  void update(DeviceModel device, DeviceConnectionState conState) {
    DeviceStatusMap newM = {};

    for (var item in state.entries) {
      if (item.key == device) {
        newM[item.key] = item.value.copyWith(connectionState: conState);
      } else {
        newM[item.key] = item.value;
      }
    }

    if (conState == DeviceConnectionState.connected) {
      newM[device] ??= ConnectionStateUpdate(
        connectionState: conState,
        deviceId: device.id,
        failure: null,
      );
    } else {
      newM.remove(device);
    }

    state = newM;
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
