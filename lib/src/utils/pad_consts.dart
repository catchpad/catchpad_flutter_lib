import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../enums/sensors/config/config_data_rate.dart';
import '../enums/sensors/config/config_mode.dart';
import '../enums/sensors/config/config_scale.dart';
import '../models/cp_characteristic.dart';

const Duration responseTimeMistakeMargin = Duration(milliseconds: 20);
const String defaultSeperator = '/';
const String subSeperator = ',';
const String defaultEmptyValue = '-1';

// #region sensor defaults
const ConfigScale defConfigScale = ConfigScale.LIS2DH12_16g;
const ConfigMode defConfigMode = ConfigMode.LIS2DH12_HR_12bit;
const DataRate defDataRate = DataRate.LIS2DH12_ODR_1kHz620_LP;

const ConfigScale defConfigIntScale = ConfigScale.LIS2DH12_2g;
const ConfigMode defConfigIntMode = ConfigMode.LIS2DH12_HR_12bit;
const DataRate defIntDataRate = DataRate.LIS2DH12_ODR_400Hz;

const bool defSleepEnable = true;

const minDstThreshold = 0;
const maxDstThreshold = 2000;
const defDstThreshold = 40;

const minAccThreshold = 0;
const maxAccThreshold = 127;
const defAccThreshold = 35;

const minAccIntThreshold = 0;
const maxAccIntThreshold = 127;
const defAccIntThreshold = 10;

const minAccIntDuration = 0;
const maxAccIntDuration = 20;
const defAccIntDuration = 5;

const minTimeOut = 0;
const maxTimeOut = 99999;
const defTimeOut = 100;

const int minAccTimeOut = minTimeOut;
const int maxAccTimeOut = maxTimeOut;
const int defAccTimeOut = defTimeOut;

const int minDstTimeOut = minTimeOut;
const int maxDstTimeOut = maxTimeOut;
const int defDstTimeOut = defTimeOut;

const int minAccIntTimeOut = 0;
const int maxAccIntTimeOut = 20;
const int defAccIntTimeOut = 20;
// #endregion

// #region main stuff

const List<String> serviceIds = [ledServiceId, adminServiceId, sensorServiceId];

List<Uuid> get serviceUuids => serviceIds.map(Uuid.parse).toList();

// #endregion

// #region new characteristics

// #region simulator only
const String simulatorServiceId = 'b3b7e8f4-9ab4-4d9b-80d4-bd61113a5017';

const CpCharacteristic simulatorCharacteristic = CpCharacteristic(
  id: '4fafc201-1fb5-459e-8fcc-c5c9c331914b',
  serviceId: simulatorServiceId,
);
// #endregion

// #region led
const String ledServiceId = '55cb9fe8-b2ab-11ec-b909-000000000000';

const CpCharacteristic ledCharacteristic = CpCharacteristic(
  id: '6412075e-b2ab-11ec-b909-000000000001',
  serviceId: ledServiceId,
);
const CpCharacteristic ledAllCharacteristic = CpCharacteristic(
  id: '6412075e-b2ab-11ec-b909-000000000111',
  serviceId: ledServiceId,
);
// #endregion

// #region admin
const String adminServiceId = '23cb9fe8-b2ab-11ec-b909-000000000000';

const CpCharacteristic adminCharacteristic = CpCharacteristic(
  id: 'a4bf0dbb-b2ab-11ec-b909-00000000000A',
  serviceId: adminServiceId,
);
// #endregion

// #region sensors
const String sensorServiceId = '722d9150-b2ab-11ec-b909-000000000000';

const CpCharacteristic accCharacteristic = CpCharacteristic(
  id: '7af57456-b2ab-11ec-b909-000000000001',
  serviceId: sensorServiceId,
);

const CpCharacteristic dstCharacteristic = CpCharacteristic(
  id: '83e7f7e6-b2ab-11ec-b909-000000000002',
  serviceId: sensorServiceId,
);

const CpCharacteristic activateCharacteristic = CpCharacteristic(
  id: 'a4bf0dba-b2ab-11ec-b909-00000000000A',
  serviceId: sensorServiceId,
);

const CpCharacteristic configCharacteristic = CpCharacteristic(
  id: '8a19169a-b2ab-11ec-b909-00000000000C',
  serviceId: sensorServiceId,
);
// #endregion

// #region info
const String infoServiceId = '23cb9fe8-b2ab-11ec-b909-DDDDDDDDDDDD';

const CpCharacteristic infoCharacteristic = CpCharacteristic(
  id: 'a4bf0dbb-b2ab-11ec-b909-DDDDDDDDDDD0',
  serviceId: infoServiceId,
);

const CpCharacteristic batteryCharacteristic = CpCharacteristic(
  id: 'a4bf0dbb-b2ab-11ec-b909-DDDDDDDDDDD1',
  serviceId: infoServiceId,
);
// #endregion
// #region audio
const String audioServiceId = '23cb9fe8-b2ab-11ec-b909-AAAAAAAAAAAA';

const CpCharacteristic audioCharacteristic = CpCharacteristic(
  id: 'a4bf0dbb-b2ab-11ec-b909-AAAAAAAAAAAA',
  serviceId: audioServiceId,
);
// #endregion
// #endregion

const String oldMainServiceId = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
const oldMainCharacteristicId = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

Uuid get oldMainServiceUuid => Uuid.parse(oldMainServiceId);
Uuid get oldMainCharacteristicUuid => Uuid.parse(oldMainCharacteristicId);

const CpCharacteristic oldMainCharacteristic = CpCharacteristic(
  id: oldMainCharacteristicId,
  serviceId: oldMainServiceId,
);

abstract class PadConsts {
  static const Color errorColor = Color(0xFFF44336);
}
