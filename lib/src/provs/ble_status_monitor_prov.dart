import 'package:catchpad_simulator_flutter/catchpad_simulator_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ble_status_monitor.dart';

final bleStatusMonitorProv = StateProvider<BleStatusMonitor>(
  (ref) {
    final _ble = ref.watch(bleProv);
    return BleStatusMonitor(_ble);
  },
);
