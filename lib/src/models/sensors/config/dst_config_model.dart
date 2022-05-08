import '../../../enums/sensors/config/sensor_type.dart';
import 'sensor_config_model.dart';

class DstConfigModel {
  ///  0-2000
  final int? threshold;

  /// 0 - 99999 ms
  final int? timeout;

  const DstConfigModel({
    this.threshold,
    this.timeout,
  });

  SensorConfigModel toSensorConfigModel() {
    return SensorConfigModel(
      sensorType: SensorType.dst,
      threshold: threshold,
      timeout: timeout,
    );
  }
}
