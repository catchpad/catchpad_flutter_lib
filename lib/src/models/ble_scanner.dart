import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/consts.dart';
import 'device_model.dart';
import 'reactive_state.dart';

class BleScanner implements ReactiveState<BleScannerState> {
  BleScanner({
    required StateProviderRef ref,
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage,
        _ref = ref;

  bool _isScanning = false;

  // ignore: unused_field
  final StateProviderRef _ref;
  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;

  StreamController<BleScannerState>? _stateStreamController;

  final _devices = <DeviceModel>{};

  @override
  Stream<BleScannerState> get state {
    init();
    return _stateStreamController!.stream;
  }

  void startScan() async {
    // final deviceConnector = _ref.watch(bleDeviceConnectorProv);

    if (_isScanning) {
      await stopScan();
    }

    _isScanning = true;

    init();

    _logMessage('Start ble discovery');

    _subscription = _ble.scanForDevices(
      withServices: [],
      // TODO
      // serviceUuids,
    ).listen(
      (device) {
        if (!device.isCPDevice) return;

        // dont add already added devices
        if (_devices.any((element) => element.id == device.id)) return;

        _devices.add(device);

        _pushState();
      },
      onError: (Object e) => _logMessage(
        'Device scan fails with error: $e',
      ),
    );

    _pushState();

    await Future.delayed(scanDuration);
    stopScan();
  }

  void _pushState() {
    if (!isClosed) {
      _stateStreamController!.add(
        BleScannerState(
          deviceModels: _devices,
          scanIsInProgress: _subscription != null,
        ),
      );
    }
  }

  bool get isClosed =>
      _stateStreamController == null || _stateStreamController!.isClosed;

  Future<void> stopScan() async {
    _logMessage('Stop ble discovery');

    if (_subscription != null) {
      await _subscription?.cancel();
      _subscription = null;
    }

    if (!isClosed) {
      await dispose();
    }

    _isScanning = false;
  }

  Future<void> dispose() async {
    _pushState();
    await _stateStreamController?.close();
  }

  void init() {
    _stateStreamController ??= StreamController();
  }

  StreamSubscription? _subscription;
}

@immutable
class BleScannerState {
  const BleScannerState({
    required Set<DeviceModel> deviceModels,
    required this.scanIsInProgress,
  }) : _deviceModels = deviceModels;

  final Set<DeviceModel> _deviceModels;
  final bool scanIsInProgress;

  List<DeviceModel> get deviceModels =>
      _deviceModels.where((element) => element.isCPDevice).toList();
}
