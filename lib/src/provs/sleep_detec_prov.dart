import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
The reason for creating this provider class was to address the
issue of a device still appearing on its BLE connection screen when
it went to sleep. So I created a timer that would remove the device
from the list if it was not connected for more than 10 seconds.
*/

typedef SleptDeviceByTimer = Map<String, int>;

final sleepDetectedByTimerNotifierProv = StateNotifierProvider<
    SleepDetectedByTimerNotifierNotifier,
    SleptDeviceByTimer>((ref) {
  return SleepDetectedByTimerNotifierNotifier({});
});

class SleepDetectedByTimerNotifierNotifier
    extends StateNotifier<SleptDeviceByTimer> {
  SleepDetectedByTimerNotifierNotifier(SleptDeviceByTimer state) : super({});
  static const int _timeOut = 10;
  //When the device sees any connectable device
  //you should refresh time state with this function
  void updateOrAddLastSeen(Ref ref, String deviceId) {
    final sinceEpoch = DateTime
        .now()
        .millisecondsSinceEpoch;
    if (state.containsKey(deviceId)) {
      SleptDeviceByTimer sleptDeviceByTimer = state;
      sleptDeviceByTimer[deviceId] = sinceEpoch;
      state = sleptDeviceByTimer;

    } else {
      state.addAll({deviceId: sinceEpoch});
    }
  }
  //Check it device to seen any time  in 10 sec. if i see it return false
  //if i dont see it return true
  bool checkNeedRemoveFromDevice(Ref ref, String deviceId) {
    if (ref
        .read(bleConPr)
        .values
        .any((element) => element.deviceId == deviceId)) {
      if (ref
          .read(bleConPr)
          .values
          .firstWhere((element) => element.deviceId == deviceId)
          .connectionState == DeviceConnectionState.connected) {
        updateOrAddLastSeen(ref, deviceId);
        return false;
      }
    }


    final sinceEpoch = DateTime
        .now()
        .millisecondsSinceEpoch;

    final diff = sinceEpoch - state[deviceId]!;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(diff);


    if (dateTime.second > _timeOut) {
      delete(ref, deviceId);
      return true;
    } else {
      return false;
    }
  }

  //Remove device from state
  void delete(Ref ref, String deviceId) {
    state.remove(deviceId);
  }
}
