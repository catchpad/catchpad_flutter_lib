import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const Duration responseTimeMistakeMargin = Duration(milliseconds: 20);
const String defaultSeperator = '/';
const String defaultEmptyValue = '-1';

// #region main stuff

const List<String> serviceIds = [ledServiceId, adminServiceId, sensorServiceId];

List<Uuid> get serviceUuids => serviceIds.map(Uuid.parse).toList();

// #endregion

// #region simulator only
const String simulatorServiceId = 'b3b7e8f4-9ab4-4d9b-80d4-bd61113a5017';
const String simulatorCharacteristicId = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';

Uuid get simulatorServiceUuid => Uuid.parse(simulatorServiceId);
Uuid get simulatorCharacteristicUuid => Uuid.parse(simulatorCharacteristicId);

QualifiedCharacteristic simulatorCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: simulatorServiceUuid,
      deviceId: deviceId,
      serviceId: simulatorServiceUuid,
    );
// #endregion

// #region led
const String ledServiceId = '55cb9fe8-b2ab-11ec-b909-000000000000';

/// this one takes only 1 colors for all 4 leds
const String ledCharacteristicId = '6412075e-b2ab-11ec-b909-000000000001';

/// this one takes a color for each led
const String ledAllCharacteristicId = '6412075e-b2ab-11ec-b909-000000000111';

Uuid get ledServiceUuid => Uuid.parse(ledServiceId);

Uuid get ledCharacteristicUuid => Uuid.parse(ledCharacteristicId);
Uuid get ledAllCharacteristicUuid => Uuid.parse(ledAllCharacteristicId);

QualifiedCharacteristic ledCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: ledCharacteristicUuid,
      deviceId: deviceId,
      serviceId: ledServiceUuid,
    );

QualifiedCharacteristic ledAllCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: ledAllCharacteristicUuid,
      deviceId: deviceId,
      serviceId: ledServiceUuid,
    );
// #endregion

// #region admin
const String adminServiceId = '23cb9fe8-b2ab-11ec-b909-000000000000';

const String adminCharacteristicId = 'a4bf0dbb-b2ab-11ec-b909-00000000000A';

Uuid get adminServiceUuid => Uuid.parse(adminServiceId);

Uuid get adminCharacteristicUuid => Uuid.parse(adminCharacteristicId);

QualifiedCharacteristic adminCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: adminCharacteristicUuid,
      deviceId: deviceId,
      serviceId: adminServiceUuid,
    );
// #endregion

// #region sensors
const String sensorServiceId = '722d9150-b2ab-11ec-b909-000000000000';
Uuid get sensorServiceUuid => Uuid.parse(sensorServiceId);

// #region ACC
const String accCharacteristicId = '7af57456-b2ab-11ec-b909-000000000001';
Uuid get accCharacteristicUuid => Uuid.parse(accCharacteristicId);

QualifiedCharacteristic accCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: accCharacteristicUuid,
      deviceId: deviceId,
      serviceId: sensorServiceUuid,
    );
// #endregion

// #region DST
const String dstCharacteristicId = '83e7f7e6-b2ab-11ec-b909-000000000002';
Uuid get dstCharacteristicUuid => Uuid.parse(dstCharacteristicId);

QualifiedCharacteristic dstCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: dstCharacteristicUuid,
      deviceId: deviceId,
      serviceId: sensorServiceUuid,
    );
// #endregion

// #endregion

abstract class PadConsts {
  static const Color errorColor = Color(0xFFF44336);
}
