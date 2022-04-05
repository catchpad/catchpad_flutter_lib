import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const Duration responseTimeMistakeMargin = Duration(milliseconds: 20);
const String defaultSeperator = '/';
const String defaultEmptyValue = '-1';
// legacy
const String mainServiceId = '4fafc201-1fb5-459e-8fcc-c5c9c331914b',
    mainCharacteristicId = 'beb5483e-36e1-4688-b7f5-ea07361b26a8',
    batteryCharacteristicId = 'beb5483e-36e1-4688-b7f5-ea07361b26a9';

// !!!simulator only!!! //
const simulatorServiceId = 'b3b7e8f4-9ab4-4d9b-80d4-bd61113a5017';
// !!!simulator only!!! //

Uuid get mainServiceUuid => Uuid.parse(mainServiceId);
Uuid get simulatorServiceUuid => Uuid.parse(simulatorServiceId);
Uuid get mainCharacteristicUuid => Uuid.parse(mainCharacteristicId);
Uuid get batteryCharacteristicUuid => Uuid.parse(batteryCharacteristicId);

// TODO: update with the new services
const List<String> serviceIds = [mainServiceId];

// TODO: update with the new characteristics
const List<String> characteristicIds = [
  mainCharacteristicId,
  batteryCharacteristicId
];

List<Uuid> get serviceUuids => serviceIds.map(Uuid.parse).toList();

List<Uuid> get characteristicUuids => characteristicIds
    .map(
      (e) => Uuid.parse(e),
    )
    .toList();

QualifiedCharacteristic mainCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: mainCharacteristicUuid,
      deviceId: deviceId,
      serviceId: mainServiceUuid,
    );

QualifiedCharacteristic batteryCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: batteryCharacteristicUuid,
      deviceId: deviceId,
      serviceId: mainServiceUuid,
    );

QualifiedCharacteristic simulatorCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: mainCharacteristicUuid,
      deviceId: deviceId,
      serviceId: simulatorServiceUuid,
    );

// legacy end
//
//

// led start //
const String ledServiceId = '55cb9fe8-b2ab-11ec-b909-000000000000';

const String ledCharacteristicId = '6412075e-b2ab-11ec-b909-000000000001';

Uuid get ledServiceUuid => Uuid.parse(ledServiceId);

Uuid get ledCharacteristicUuid => Uuid.parse(ledCharacteristicId);

QualifiedCharacteristic ledCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: ledCharacteristicUuid,
      deviceId: deviceId,
      serviceId: ledServiceUuid,
    );
// led end //

abstract class PadConsts {
  static const Color errorColor = Color(0xFFF44336);
}
