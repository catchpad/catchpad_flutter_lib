import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ble_logger.dart';

final bleLoggerProv = StateProvider<BleLogger>(
  (ref) => BleLogger(),
);
