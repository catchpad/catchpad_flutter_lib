import '../../../../catchpad_flutter_lib.dart';
import 'sensor_event.dart';

import '../acc_tap_model.dart';

class TouchEvent extends SensorEvent {
  final AcceleremetorTapModel tap;

  const TouchEvent(String deviceId, this.tap) : super(deviceId);

  Duration? get responseTime => tap.responseTime;

  @override
  bool get isValid => responseTime != null;
}
