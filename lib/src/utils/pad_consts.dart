import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const Duration responseTimeMistakeMargin = Duration(milliseconds: 20);

const String mainServiceId = '4fafc201-1fb5-459e-8fcc-c5c9c331914b',
    mainCharacteristicId = 'beb5483e-36e1-4688-b7f5-ea07361b26a8',
    batteryCharacteristicId = 'beb5483e-36e1-4688-b7f5-ea07361b26a9';

Uuid get mainServiceUuid => Uuid.parse(mainServiceId);
Uuid get mainCharacteristicUuid => Uuid.parse(mainCharacteristicId);
Uuid get batteryCharacteristicUuid => Uuid.parse(batteryCharacteristicId);

const List<String> serviceIds = [mainServiceId];

const List<String> characteristicIds = [
  mainCharacteristicId,
  batteryCharacteristicId
];

List<Uuid> get serviceUuids => serviceIds
    .map(
      (e) => Uuid.parse(e),
    )
    .toList();

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

abstract class PadConsts {
  static const Color errorColor = Color(0xFFF44336);
}
