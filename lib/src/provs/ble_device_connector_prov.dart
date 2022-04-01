import '../../catchpad_simulator_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleDeviceConnectorProv = StateProvider<BleDeviceConnector>(
  (ref) => BleDeviceConnector(
    ble: ref.watch(bleProv),
    logMessage: ref.watch(bleLoggerProv).addToLog,
  ),
);
