import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CurrentMapOfBatteryModel = Map<String, BatteryModel?>;

final currentBatteryModelControlProvider = StateNotifierProvider<
    CurrentBatteryModelControlNotifier,
    CurrentMapOfBatteryModel>((ref) => CurrentBatteryModelControlNotifier({}));

//Why i created this class is to have a way to update the state
//of the currentBatteryModelControlProvider from anywhere in the app
//for example when start a game check this provider to
//see if the battery is charging or not also check voltage is low or not

class CurrentBatteryModelControlNotifier
    extends StateNotifier<CurrentMapOfBatteryModel> {
  CurrentBatteryModelControlNotifier(CurrentMapOfBatteryModel state)
      : super({});

  void changState(CurrentMapOfBatteryModel val) => state = val;

  void updateOrAddBatteryModel(String deviceId, BatteryModel? val){
    state[deviceId] = val;
  }

}
