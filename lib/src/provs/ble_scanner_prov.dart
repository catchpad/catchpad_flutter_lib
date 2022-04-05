import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ble_scanner.dart';
import 'ble_logger_prov.dart';
import 'ble_prov.dart';

final bleScannerProv = StateProvider<BleScanner>(
  (ref) => BleScanner(
    ref: ref,
    ble: ref.watch(bleProv),
    logMessage: ref.watch(bleLoggerProv).addToLog,
  ),
);
