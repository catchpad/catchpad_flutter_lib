import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../models/cp_characteristic.dart';

const Duration responseTimeMistakeMargin = Duration(milliseconds: 20);
const String defaultSeperator = '/';
const String defaultEmptyValue = '-1';

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
  id: '8a19169a-b2ab-11ec-b909-00000000000Cs',
  serviceId: sensorServiceId,
);
// #endregion

abstract class PadConsts {
  static const Color errorColor = Color(0xFFF44336);
}
