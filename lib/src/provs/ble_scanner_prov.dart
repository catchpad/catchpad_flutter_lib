import '../../catchpad_simulator_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleScannerProv = StateProvider<BleScanner>(
  (ref) => BleScanner(
    ref: ref,
    ble: ref.watch(bleProv),
    logMessage: ref.watch(bleLoggerProv).addToLog,
  ),
);
