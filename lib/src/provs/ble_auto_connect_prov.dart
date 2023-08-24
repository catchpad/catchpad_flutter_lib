import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*

 This provider was created to address the problem of a device randomly
disconnecting from the mobile device.
This issue can occur due to various reasons.
We have devised a temporary solution for this problem.
Whenever we enter a game, we set this condition to 'true.'
The library displays the status of the device whenever any device
disconnects from the mobile device. When this happens, we check the auto-connect
state. If it is set to 'true,' we attempt to reconnect the device.

*/

final bleAutoConnectStateNotifierProv =
    StateNotifierProvider<BleAutoConnectStateNotifier, bool>(
  (_) => BleAutoConnectStateNotifier(false),
);

final randomlyDisconnectedDevProv = StateNotifierProvider<
    AutoConnectListControlNotifier,
    RandomlyDisconnectedDevice>((ref) {
  return AutoConnectListControlNotifier([]);
});

typedef RandomlyDisconnectedDevice = List<DiscoveredDevice>;

class BleAutoConnectStateNotifier extends StateNotifier<bool> {
  BleAutoConnectStateNotifier(bool state) : super(false);
  changState(bool val) => state = val;
}


class AutoConnectListControlNotifier
    extends StateNotifier<RandomlyDisconnectedDevice> {
  AutoConnectListControlNotifier(RandomlyDisconnectedDevice state) : super([]);

  void changState(RandomlyDisconnectedDevice val) => state = val;


  addDiscoveredDevice(DiscoveredDevice device) {
    if (!state.contains(device)) {
      state = [...state, device];
    }
  }


  removeDiscoveredDevice(DiscoveredDevice device) {
    state = state.where((element) => element != device).toList();
  }


}