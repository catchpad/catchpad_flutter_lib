import 'package:catchpad_flutter_lib/src/models/sensors/events/sensor_event.dart';

import '../acc_gravity_model.dart';

class MotionEvent extends SensorEvent {
  final AcceleremetorGravityModel motion;

  const MotionEvent(String deviceId, this.motion) : super(deviceId);

  @override
  bool get isValid => true;
}
