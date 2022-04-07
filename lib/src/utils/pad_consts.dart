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
// led end //

// admin start //
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
// admin end //

// sensors start //

const String sensorServiceId = '722d9150-b2ab-11ec-b909-000000000000';
Uuid get sensorServiceUuid => Uuid.parse(sensorServiceId);

// ACC START //
const String accCharacteristicId = '7af57456-b2ab-11ec-b909-000000000001';
Uuid get accCharacteristicUuid => Uuid.parse(accCharacteristicId);

QualifiedCharacteristic accCharacteristic(String deviceId) =>
    QualifiedCharacteristic(
      characteristicId: accCharacteristicUuid,
      deviceId: deviceId,
      serviceId: sensorServiceUuid,
    );
// ACC END //

// sensors end //
abstract class PadConsts {
  static const Color errorColor = Color(0xFFF44336);
}
