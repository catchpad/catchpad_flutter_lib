import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../models/cp_characteristic.dart';
import '../models/pad_sensor_manager.dart';

const Duration responseTimeMistakeMargin = Duration(milliseconds: 20);
const String defaultSeperator = '/';
const String defaultEmptyValue = '-1';

// #region sensor defaults
const ConfigScale defConfigScale = ConfigScale.LIS2DH12_4g;
const ConfigMode defConfigMode = ConfigMode.LIS2DH12_NM_10bit;
const DataRate defDataRate = DataRate.LIS2DH12_ODR_400Hz;

const minDstThreshold = 0;
const maxDstThreshold = 2000;
const defDstThreshold = 20;

const minAccThreshold = 0;
const maxAccThreshold = 127;
const defAccThreshold = 65;

const minTimeOut = 0;
const maxTimeOut = 99999;
const defTimeOut = 250;

int get minAccTimeOut => minTimeOut;
int get maxAccTimeOut => maxTimeOut;
int get defAccTimeOut => defTimeOut;

int get minDstTimeOut => minTimeOut;
int get maxDstTimeOut => maxTimeOut;
int get defDstTimeOut => defTimeOut;
// #endregion

// #region main stuff

const List<String> serviceIds = [ledServiceId, adminServiceId, sensorServiceId];

List<Uuid> get serviceUuids => serviceIds.map(Uuid.parse).toList();

// #endregion

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

abstract class PadConsts {
  static const Color errorColor = Color(0xFFF44336);
}
