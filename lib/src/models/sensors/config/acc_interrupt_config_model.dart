import '../../../enums/sensors/config/config_data_rate.dart';
import '../../../enums/sensors/config/config_mode.dart';
import '../../../enums/sensors/config/config_scale.dart';
import '../../../enums/sensors/config/sensor_type.dart';
import 'sensor_config_model.dart';

export '../../../enums/sensors/config/config_data_rate.dart';
export '../../../enums/sensors/config/config_mode.dart';
export '../../../enums/sensors/config/config_scale.dart';

/// this sets settings for the accelerometer
/// interrupt (sleep)
class AccInterruptConfigModel {
  final ConfigScale? scale;
  final ConfigMode? mode;
  final DataRate? dataRate;

  /// 0-127
  final int? threshold;

  /// ms
  /// 0 - 20 ms
  /// how long to wait for an interrupt
  final int? duration;

  /// MINUTE
  /// 0 - 60 minutes
  /// after how long of inactivity to go to sleep
  final int? timeout;

  /// wether to enable sleep mode
  final bool? sleepEnable;

  const AccInterruptConfigModel({
    this.scale,
    this.mode,
    this.dataRate,
    this.threshold,
    this.timeout,
    this.sleepEnable,
    this.duration,
  });

  SensorConfigModel toSensorConfigModel() {
    return SensorConfigModel(
      sensorType: SensorType.acc,
      intScale: scale,
      intMode: mode,
      intDataRate: dataRate,
      intThreshold: threshold,
      intTimeout: timeout,
      intDuration: duration,
      intSleepEnable: sleepEnable,
    );
  }
}
