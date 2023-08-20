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

typedef RandomlyDisconnectedDevice = List<DiscoveredDevice>;

class BleAutoConnectStateNotifier extends StateNotifier<bool> {
  BleAutoConnectStateNotifier(bool state) : super(false);


  /// This list is used when want randomly select a device in the game.
  /// If it device in this list, we will not select it.
  final RandomlyDisconnectedDevice _randomlyDisconnectedDevice = [];

  changState(bool val) => state = val;

  addDiscoveredDevice(DiscoveredDevice device) =>
      _randomlyDisconnectedDevice.add(device);

  removeDiscoveredDevice(DiscoveredDevice device) =>
      _randomlyDisconnectedDevice.remove(device);

  RandomlyDisconnectedDevice get randomlyDisconnectedDevice =>
      _randomlyDisconnectedDevice;
}
