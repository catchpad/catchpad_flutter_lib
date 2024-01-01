

import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CurrentDevInfos = Map<String,DevInfoModel>;


final currentDevInfoManagers = StateNotifierProvider<
    DeviceInfoProvNotifier, CurrentDevInfos>(
        (ref) => DeviceInfoProvNotifier({}));

/// This provider class will determine whether or not to run the function we
/// have previously specified according to the hardware!. There is no point
/// in sending unnecessary commands, is there?
class DeviceInfoProvNotifier extends StateNotifier<CurrentDevInfos> {
  DeviceInfoProvNotifier(CurrentDevInfos state) : super({});


  /// Add for control!
  void add(DevInfoModel infoModel) {
    final temp = state;
    temp.addAll({infoModel.cpId!: infoModel});
    state = temp;
  }
}
