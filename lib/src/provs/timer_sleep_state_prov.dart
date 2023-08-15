import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SleptDeviceByTimer = Map<String, int>;

final sleepDetectedByTimerNotifierProv = StateNotifierProvider<
    SleepDetectedByTimerNotifierNotifier, SleptDeviceByTimer>((ref) {
  return SleepDetectedByTimerNotifierNotifier({});
});

class SleepDetectedByTimerNotifierNotifier
    extends StateNotifier<SleptDeviceByTimer> {
  SleepDetectedByTimerNotifierNotifier(SleptDeviceByTimer state) : super({});

  void updateOrAddLastSeen(Ref ref, String deviceId) {
    final sinceEpoch = DateTime.now().millisecondsSinceEpoch;
    if (state.containsKey(deviceId)) {
      state.update(deviceId, (value) => sinceEpoch);
    } else {
      state.addAll({deviceId: sinceEpoch});
    }
    logger.i(state);
  }

  bool checkNeedRemoveFromDevice(Ref ref, String deviceId) {
    final sinceEpoch = DateTime.now().millisecondsSinceEpoch;
    final diff = sinceEpoch - state[deviceId]!;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(diff);
    if (dateTime.second > 10) {
      delete(ref, deviceId);
      return true;
    } else {
      return false;
    }
  }

  void delete(Ref ref, String deviceId) {
    state.remove(deviceId);
  }
}
