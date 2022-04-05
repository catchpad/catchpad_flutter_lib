import '../../utils/pad_consts.dart';
import '../device_model.dart';

class TouchEvent {
  final String deviceNameId;
  final Duration responseTime;

  const TouchEvent._(this.deviceNameId, this.responseTime);

  factory TouchEvent.fromBytes(List<int> bytes) {
    final str = String.fromCharCodes(bytes);
    // str's format is: '/[deviceId]/[responseTime]/'
    // [responseTime] is the time it took to respond to the touch
    // calculated in ms
    final split = str.split('/').where((element) => element.isNotEmpty);

    final deviceId = split.elementAt(0);
    final responseTime = int.parse(split.elementAt(1));
    final responseDuration = Duration(milliseconds: responseTime);

    return TouchEvent._(deviceId, responseDuration);
  }

  /// the pads may calculate mistakenly and return like 10ms off result
  /// so we wanna put [responseTimeMistakeMargin] mistake margin
  bool get isValid => responseTime >= responseTimeMistakeMargin;

  @override
  String toString() {
    return 'TouchEvent{deviceId: $deviceNameId, responseTime: $responseTime, isValid: $isValid}';
  }

  bool equalsDevice(DeviceModel device) {
    try {
      final devId = device.name.split(' ').first;
      return devId == deviceNameId;
    } catch (e) {
      assert(false);

      return false;
    }
  }
}
