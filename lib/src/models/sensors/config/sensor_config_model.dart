import '../../../enums/sensors/config/config_data_rate.dart';
import '../../../enums/sensors/config/config_mode.dart';
import '../../../enums/sensors/config/config_scale.dart';
import '../../../enums/sensors/config/sensor_type.dart';

class SensorConfigModel {
  final SensorType sensorType;

  final ConfigScale? scale;
  final ConfigMode? mode;
  final DataRate? dataRate;

  /// ACC: 0-127
  /// DST: 0-2000
  final int? threshold;

  /// 0 - 99999 ms
  final int? timeout;

  const SensorConfigModel({
    required this.sensorType,
    this.scale,
    this.mode,
    this.dataRate,
    this.threshold,
    this.timeout,
  });
}
