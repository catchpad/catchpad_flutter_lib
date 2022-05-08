import 'sensor_config_model.dart';

import '../../../enums/sensors/config/sensor_type.dart';

import '../../../enums/sensors/config/config_data_rate.dart';
import '../../../enums/sensors/config/config_mode.dart';
import '../../../enums/sensors/config/config_scale.dart';

export '../../../enums/sensors/config/config_data_rate.dart';
export '../../../enums/sensors/config/config_mode.dart';
export '../../../enums/sensors/config/config_scale.dart';

class AccConfigModel {
  final ConfigScale? scale;
  final ConfigMode? mode;
  final DataRate? dataRate;

  /// 0-127
  final int? threshold;

  /// 0 - 99999 ms
  final int? timeout;

  const AccConfigModel({
    this.scale,
    this.mode,
    this.dataRate,
    this.threshold,
    this.timeout,
  });

  SensorConfigModel toSensorConfigModel() {
    return SensorConfigModel(
      sensorType: SensorType.acc,
      scale: scale,
      mode: mode,
      dataRate: dataRate,
      threshold: threshold,
      timeout: timeout,
    );
  }
}
