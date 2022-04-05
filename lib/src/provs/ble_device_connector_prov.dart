import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ble_device_connector.dart';
import 'ble_logger_prov.dart';
import 'ble_prov.dart';

final bleDeviceConnectorProv = StateProvider<BleDeviceConnector>(
  (ref) => BleDeviceConnector(
    ble: ref.watch(bleProv),
    logMessage: ref.watch(bleLoggerProv).addToLog,
  ),
);
