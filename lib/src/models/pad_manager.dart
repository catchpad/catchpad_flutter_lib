import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'sides_colors_model.dart';

// TODO: seperate every service to its own file (e.g. led, audio, etc.)
abstract class PadManager {
  /// Catchpad
  static Future<bool> toggleLight(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    return await ledColor(
      deviceId,
      const SidesColorsModel(
        tr: Color.fromARGB(255, 0, 0, 255),
        tl: Color.fromARGB(255, 0, 255, 0),
        br: Color.fromARGB(255, 255, 0, 0),
        bl: Color.fromARGB(255, 255, 255, 0),
      ),
      ref: ref,
    );
  }

  static Future<bool> ledOff(
    String deviceId, {
    required WidgetRef ref,
    bool isCommand = false,
  }) async {
    return await ledColor(
      deviceId,
      SidesColorsModel.off(),
      ref: ref,
      isCommand: isCommand,
    );
  }

  static Future<bool> sleepDevice(
    String deviceId, {
    required WidgetRef ref,
    bool isCommand = false,
  }) async {
    const dt = 'S';
    logger.i("Sleep Device");
    return await BleManager.writeCharacteristic(
      c: sleepCharacteristicAdminInfo.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: Platform.isAndroid ? true : true,
      ref: ref,
    ).timeout(const Duration(milliseconds: 100), onTimeout: () => true);
  }

  static Future<bool> ledOffNoResponse(
    String deviceId, {
    required WidgetRef ref,
    bool isCommand = false,
  }) async {
    return await ledColor(
      deviceId,
      SidesColorsModel.off(),
      ref: ref,
      isCommand: isCommand,
      withResponse: false,
    );
  }

  @Deprecated('use ledColor')
  static Future<bool> randomColors(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    for (var i = 0; i < 100; i++) {
      await ledColor(
        deviceId,
        // random color
        SidesColorsModel.all(BigGuy.randomColor()),
        ref: ref,
      );
    }

    return true;
  }

  //Kronometreyi başlatır.
  static Future<bool> sendIsCommand(
    String deviceId, {
    required WidgetRef ref,
  }) {
    final dateTime = DateTime.now().millisecondsSinceEpoch;

    return ledColor(
      deviceId,
      const SidesColorsModel(same: true),
      ref: ref,
      isCommand: true,
    );
  }

  static Future<bool> ledColorNoResponse(
    String deviceId,
    SidesColorsModel colorModel, {
    bool isCommand = false,
    required WidgetRef ref,

    /// for how long to flash the led
    /// if null, it will flash forever
    Duration? duration,
  }) async {
    return ledColor(
      deviceId,
      colorModel,
      ref: ref,
      isCommand: isCommand,
      duration: duration,
      withResponse: false,
    );
  }
  //led settings

  static Future<bool> chargeLedOptimization(String deviceId,
      {required WidgetRef ref}) {
    final dt = ["LEDSETTING", "30", "1250", "20"].join(defaultSeperator);

    return BleManager.writeCharacteristic(
        ref: ref,
        c: ledSettingsCharacteristic.qualCharacteristic(deviceId),
        data: utf8.encode(dt),
        withResponse: false);
  }

  static Future<bool> ledMultiColor(
    Set<String> deviceIds,
    Set<SidesColorsModel> colorModels, {
    bool isCommand = false,
    required WidgetRef ref,
    bool withResponse = true,

    /// for how long to flash the led
    /// if null, it will flash forever
    Duration? duration,
  }) async {
    bool ret = false;
    List<bool> futs = [];

    final idColorMap = <String, SidesColorsModel>{
      for (int i = 0; i < deviceIds.length; i++)
        deviceIds.elementAt(i): colorModels.elementAt(i),
    };
    futs.addAll(
      await Future.wait(
        idColorMap.entries.map((entry) async {
          final devId = entry.key;
          final colorModel = entry.value;

          return await ledColor(
            devId,
            colorModel,
            ref: ref,
            isCommand: isCommand,
            duration: duration,
            withResponse: withResponse,
          );
        }),
      ),
    );

    if (duration != null) {
      await Future.delayed(duration);

      futs.addAll(
        await Future.wait(
          idColorMap.keys.map((deviceId) async {
            return await ledOff(
              deviceId,
              ref: ref,
              isCommand: isCommand,
            );
          }),
        ),
      );
    }

    ret = futs.every((fut) => fut);

    return ret;
  }

  static Future<bool> ledColor(
    String deviceId,
    SidesColorsModel colorModel, {
    bool isCommand = false,
    required WidgetRef ref,
    bool withResponse = true,

    /// for how long to flash the led
    /// if null, it will flash forever
    Duration? duration,
  }) async {
    final led = await _ledColor(
      deviceId,
      colorModel,
      isCommand: isCommand,
      ref: ref,
      withResponse: withResponse,
    );

    bool ledoff = true;

    if (duration != null) {
      await Future.delayed(duration);

      ledoff = await ledOff(
        deviceId,
        ref: ref,
      );
    }

    return led && ledoff;
  }

  static Future<bool> _ledColor(
    String deviceId,
    SidesColorsModel colorModel, {
    bool isCommand = false,
    required WidgetRef ref,
    bool withResponse = false,
  }) async {
    if (debugMode) {
      EnviromentModel? env;

      try {
        env = ref.read(enviromentProv);
      } catch (e) {
        logger.e(e);
      }
      logger.w("Pad Manager (_ledColor)1: ");

      final isReal = env?.enviromentType.isReal ?? true;
      // we're doing this inside debugMode so we would not decrease
      // performance in production as ref.read is a bit expensive
      // and _ledColor is called often.
      //
      // we wanna reduce the opacity of the color to .02 which will
      // better for the eyes of the developer when debugging on the
      // pad. but this cant be applied on the simulator as that will
      // translate all the colors to black.
      if (isReal) {
        colorModel = colorModel.opacity(.02);
      }
    }

    final dt = [
      BigGuy.boolToNumString(isCommand),
      colorModel,
    ].join(defaultSeperator);

    final charac = colorModel.allColorsSame
        ? ledAllCharacteristic.qualCharacteristic(deviceId)
        : ledCharacteristic.qualCharacteristic(deviceId);

    return await BleManager.writeCharacteristic(
      c: charac,
      data: utf8.encode(dt),
      withResponse: withResponse,
      ref: ref,
    );
  }

  static Future<bool> isCommandRefresh(String deviceId,
      {required WidgetRef ref, bool withResponse = false}) async {
    const refreshDt = '1/-1/-1/-1';

    return await BleManager.writeCharacteristic(
      c: ledAllCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(refreshDt),
      withResponse: withResponse,
      ref: ref,
    );
  }

  static Future<bool> setSleepMode(String deviceId,
      {required WidgetRef ref,
      required bool sleepModeOnCustom,
      bool withResponse = false}) async {
    //12-14
    var slpMode = sleepModeOnCustom ? '1' : '0';

    final dt = 'ACC/-1/-1/-1/-1/-1/-1/-1/-1/-1/-1/-1/$slpMode/-1/-1';

    return await BleManager.writeCharacteristic(
      c: accCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: withResponse,
      ref: ref,
    );
  }

  //otaContiuneFlag
  static Future<bool> otaContiuneFlag(String deviceId,
      {required WidgetRef ref,
      bool isCommand = false,
      bool withResponse = false}) async {
    const dt = 'SETOTA/509/1';

    return await BleManager.writeCharacteristic(
      c: otaSettings.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: withResponse,
      ref: ref,
    );
  }

  static Future<bool> sendPart512(String deviceId,
      {required WidgetRef ref,
      required List<int> byteList,
      bool isCommand = false,
      bool withResponse = false}) async {
    return await BleManager.writeCharacteristic(
      c: otaFwCharacteristic.qualCharacteristic(deviceId),
      data: byteList,
      withResponse: withResponse,
      ref: ref,
    );
  }

  //play Music
  static Future<bool> playMusic(
    String deviceId, {
    required WidgetRef ref,
    bool isCommand = false,
    bool withResponse = false,
  }) async {
    const dt = 'PLAY';
    return await BleManager.writeCharacteristic(
      c: audioCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: withResponse,
      ref: ref,
    );
  }

  static Future<bool> sendPartMusicFile(String deviceId,
      {required WidgetRef ref,
      required List<int> byteList,
      bool isCommand = false,
      bool withResponse = false}) async {
    return await BleManager.writeCharacteristic(
      c: mp3transferCharacteristic.qualCharacteristic(deviceId),
      data: byteList,
      withResponse: withResponse,
      ref: ref,
    );
  }

  /// restart the device
  static Future<bool> resetDevice(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    const dt = 'R';
    return await BleManager.writeCharacteristic(
      c: adminCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: false,
      ref: ref,
    );
  }

  static Future<bool> resetDeviceSettings(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    final futures = [
      () => PadSensorManager.configAccSensor(
          deviceId: deviceId,
          ref: ref,
          model: defAccConfigModel,
          intModel: accInterruptConfigModelWithMinusOne,
          needCheck: false),
      () => PadSensorManager.configDstSensor(
          deviceId: deviceId,
          ref: ref,
          model: defDstConfigModel,
          needCheck: false),
    ];

    bool ret = false;

    for (var future in futures) {
      final r = await future();

      if (!r) {
        ret = r;
      }
    }

    return ret;
  }

  static Future<bool> toggleDebug(
    String deviceId, {
    required bool enable,
    AdminMonitorType type = AdminMonitorType.serial,
    required WidgetRef ref,
    bool? inGame,
  }) async {
    final dt = [
      BigGuy.boolToInt(enable),
      type.index,
      (inGame == null) ? -1 : BigGuy.boolToInt(inGame)
    ].join(defaultSeperator);

    return await BleManager.writeCharacteristic(
      c: adminCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  static Future<bool> toggleMultiConnection(
    String deviceId, {
    required bool enable,
    AdminMonitorType type = AdminMonitorType.serial,
    required WidgetRef ref,
    bool? inGame,
  }) async {
    final dt = ["-1", "-1", enable ? "1" : "0"].join(defaultSeperator);

    return await BleManager.writeCharacteristic(
      c: adminCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  static Future<bool> toggleInGame(
    String deviceId, {
    AdminMonitorType type = AdminMonitorType.serial,
    required WidgetRef ref,
    bool inGame = false,
    bool withResponse = false,
  }) async {
    final dt = ["G", inGame ? "1" : "0"].join(defaultSeperator);
    logger.i("Toggle In Game: $dt");
    return await BleManager.writeCharacteristic(
        c: adminCharacteristic.qualCharacteristic(deviceId),
        data: utf8.encode(dt),
        withResponse: Platform.isIOS,
        ref: ref,
        disableUnnecessaryCommand: !inGame);
  }

  // // #region device info
  // static Future<bool> _sendGetDeviceInfoSignal(
  //   String deviceId, {
  //   required WidgetRef ref,
  // }) async {
  //   const dt = '?';

  //   return BleManager.writeCharacteristic(
  //     c: infoCharacteristic.qualCharacteristic(deviceId),
  //     data: utf8.encode(dt),
  //     withResponse: true,
  //     ref: ref,
  //   ).timeout(const Duration(milliseconds: 500), onTimeout: () => true);
  // }

  static Future<bool> _sendMemoryInfoSignal(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    const dt = 'M';
    logger.i("DevId:$deviceId");
    return await BleManager.writeCharacteristic(
      c: infoCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    ).timeout(const Duration(milliseconds: 500), onTimeout: () => true);
  }

  static Future<bool> _sendErrorInfoSignal(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    const dt = '?';
    logger.i("DevId:$deviceId");
    return await BleManager.writeCharacteristic(
      c: errorLog.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    ).timeout(const Duration(milliseconds: 500), onTimeout: () => true);
  }

  // Read heart rate from the device
  static Stream<List<int>?> readHeartRate(
    String deviceId, {
    required WidgetRef ref,
  }) async* {
    yield* BleManager.subscribeToCharacteristic(
      heartRateCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    ).map((dt) => dt.toList()).where((event) => event.isNotEmpty);
  }

  // static Future<DevInfoModel?> getDeviceInfo(
  //   String deviceId, {
  //   required WidgetRef ref,
  // }) async
  // {
  //   // logger.w("Getin Device Info");
  //   final Completer<DevInfoModel?> completer = Completer();
  //
  //   final currentDevs = ref.read(currentDevInfoManagers);
  //
  //   if (currentDevs.keys.toSet().contains(deviceId) && !completer.isCompleted) {
  //     completer.complete(currentDevs[deviceId]);
  //     return completer.future;
  //   }
  //
  //   // May-be this device is cp06Demo
  //   final deviceName = ref
  //       .read(bleConPr)
  //       .keys
  //       .toList()
  //       .firstWhere((perDiscovered) => perDiscovered.id == deviceId)
  //       .name;
  //
  //
  //   DevInfoModel? devInfoModel;
  //
  //   final characteristic = infoCharacteristic.qualCharacteristic(deviceId);
  //
  //   // Start subscribing to the characteristic
  //   BleManager.subscribeToCharacteristic(characteristic, ref: ref).listen(
  //     (dt) async {
  //       if (currentDevs.keys.toSet().contains(deviceId)) {
  //         if (!completer.isCompleted) {
  //           completer.complete(currentDevs[deviceId]);
  //         }
  //         return;
  //       }
  //
  //       _sendGetDeviceInfoSignal(deviceId, ref: ref);
  //
  //       final macId = ref
  //           .read(bleConPr)
  //           .keys
  //           .toList()
  //           .firstWhere((perDiscovered) => perDiscovered.id == deviceId)
  //           .deviceNameId;
  //
  //       final strResponse = String.fromCharCodes(dt);
  //       final isCp06 = strResponse.contains("v3.0");
  //
  //       if (isCp06) {
  //         devInfoModel = DevInfoModel.cp06DemoDeviceInfo(
  //           deviceId: deviceId,
  //           macId: macId ?? "",
  //         );
  //       } else {
  //         devInfoModel = DevInfoModel.fromBytes(dt, deviceId: deviceId);
  //       }
  //
  //       if (devInfoModel != null) {
  //         ref.read(currentDevInfoManagers.notifier).add(devInfoModel!);
  //
  //         if (!completer.isCompleted) {
  //           completer.complete(devInfoModel);
  //         }
  //       } else {
  //         logger.e("Dev Info is null");
  //         completer.complete(null);
  //       }
  //
  //     },
  //     onError: (error) {
  //       logger.e("Error while subscribing: $error");
  //       if (!completer.isCompleted) {
  //         completer.complete(null);
  //       }
  //     },
  //   );
  //
  //   // Wait for 2 seconds or until the completer is completed
  //   await Future.any([
  //     completer.future,
  //     Future.delayed(const Duration(seconds: 5)),
  //   ]);
  //
  //   if (completer.isCompleted) {
  //     return completer.future;
  //   }
  //
  //   // Check Cp06 is not, if after continue this code
  //   await _sendGetDeviceInfoSignal(deviceId, ref: ref);
  //
  //   final dt = await BleManager.readCharacteristic(
  //     characteristic,
  //     ref: ref,
  //   );
  //
  //   if (dt == null && !completer.isCompleted) {
  //     completer.complete(null);
  //   } else {
  //     if (!completer.isCompleted) {
  //       final devInfo = DevInfoModel.fromBytes(dt ?? [], deviceId: deviceId);
  //       ref.read(currentDevInfoManagers.notifier).add(devInfo);
  //       completer.complete(devInfo);
  //     }
  //   }
  //
  //   return completer.future;
  // }

  static Future<bool> iCanSeeYouStillControl(
    String deviceId, {
    required WidgetRef ref,
    required bool enableAttribute,
  }) async {
    final dt = [
      'SETINFO',
      '-1',
      '-1',
      '-1',
      '-1',
      '-1',
      '1',
      '30000',
      enableAttribute ? "1" : "0",
    ].join(defaultSeperator);

    return await BleManager.writeCharacteristic(
      c: infoCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  static Future<bool> circularPadShow(
    String deviceId, {
    required WidgetRef ref,
    Duration? totalDuration,
    Duration? timeOutLedOff,
    Duration? passingEndColorTime,
    required Color circularColor,
    Color? endColor,
  }) async {
    if (totalDuration == null) return false;
    int perSideDelayTime = totalDuration.inMilliseconds ~/ 4;
    final perSideDelayDuration = Duration(milliseconds: perSideDelayTime);

    for (int i = 0; i < 4; i++) {
      if (i != 0) {
        await Future.delayed(perSideDelayDuration);
      }

      PadManager.ledColor(
          deviceId,
          SidesColorsModel(
              tl: circularColor,
              bl: i >= 1 ? circularColor : null,
              br: i >= 2 ? circularColor : null,
              tr: i >= 3 ? circularColor : null,
              same: i == 4),
          ref: ref);
    }

    if (endColor != null) {
      await Future.delayed(passingEndColorTime ?? Duration.zero);
      PadManager.ledColor(deviceId, SidesColorsModel.all(endColor), ref: ref);
    }

    await Future.delayed(timeOutLedOff ?? Duration.zero);

    PadManager.ledOff(deviceId, ref: ref);

    return true;
  }

  static Future<bool> _setDeviceSetName(
    String deviceId, {
    required WidgetRef ref,
    String? cpId,
    String? bleName,
    String? cpSN,
    String? noTM,
    String? variantId,
    String? stickerId,
    String? groupName,
  }) async {
    final dt = [
      'SETINFO',
      noTM ?? '-1',
      variantId ?? '-1',
      cpSN ?? '-1',
      bleName ?? '-1',
      stickerId ?? '-1',
      "-1",
      "-1",
      groupName ?? "-1"
    ].join(defaultSeperator);

    return await BleManager.writeCharacteristic(
      c: infoCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  static Future<bool> requestErrorLog(
    String deviceId, {
    required WidgetRef ref,
    withResponse = true,
  }) async {
    const dt = '?';
    return await BleManager.writeCharacteristic(
      c: errorLog.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  //readErrorLog
  static Future<List<int>?> readErrorLog(
    String deviceId, {
    required WidgetRef ref,
    withResponse = false,
  }) async {
    return await BleManager.readCharacteristic(
        errorLog.qualCharacteristic(deviceId),
        ref: ref);
  }

  static Future<List<int>?> readAreUOkTimer(
    String deviceId, {
    required WidgetRef ref,
    withResponse = false,
  }) async {
    return await BleManager.readCharacteristic(
        pongLog.qualCharacteristic(deviceId),
        ref: ref);
  }

  static Future<bool> setDeviceCpId(
    String deviceId, {
    required WidgetRef ref,
    required String id,
  }) async {
    return _setDeviceSetName(
      deviceId,
      ref: ref,
      cpId: id,
    );
  }

  static Future<bool> setDeviceBleName(
    String deviceId, {
    required WidgetRef ref,
    required String name,
    String? cpSN,
    String? noTM,
    String? variantId,
    String? stickerId,
    String? groupName,
  }) async {
    return _setDeviceSetName(
      deviceId,
      ref: ref,
      bleName: name,
      cpSN: cpSN,
      variantId: variantId,
      stickerId: stickerId,
      noTM: noTM,
      groupName: groupName,
    );
  }

  // #region battery
  static Future<bool> _sendGetBatterySignal(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    const dt = '?';
    return await BleManager.writeCharacteristic(
      c: batteryCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: true,
      ref: ref,
    );
  }

  static Future<BatteryModel?> readBattery(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    final currentDevs = ref.read(currentDevInfoManagers);
    final currentDevBatteryMap = ref.read(currentBatteryModelControlProvider);

    if (!currentDevs.containsKey(deviceId)) return null;

    // if (currentDevBatteryMap.containsKey(deviceId) &&
    //     currentDevBatteryMap[deviceId] != null) {
    //   return currentDevBatteryMap[deviceId];
    // }

    if (currentDevs[deviceId]?.isCp06 ?? false) {
      return await getBatteryCp06(deviceId, ref: ref);
    }

    final signal = await _sendGetBatterySignal(deviceId, ref: ref);
    if (!signal) {
      logger.w("Signal false");
      return null;
    }

    BatteryModel? bat;

    try {
      DateTime start = DateTime.now();
      await Future.doWhile(
        () async {
          // keep the dart event loop running
          await Future.delayed(const Duration(milliseconds: 5));

          // Eğer widget unmounted ise, döngüyü sonlandır
          if (!ref.context.mounted) {
            // logger.w("Widget is unmounted, stopping readBattery.");
            return false;
          }

          final dt = await BleManager.readCharacteristic(
            batteryCharacteristic.qualCharacteristic(deviceId),
            ref: ref,
          );

          if (dt != null) {
            bat = BatteryModel.fromBytes(dt);
          }

          // bat null değilse ve widget hala mounted ise, güncellemeyi yap
          if (bat != null && ref.context.mounted) {
            ref
                .read(currentBatteryModelControlProvider.notifier)
                .updateOrAddBatteryModel(deviceId, bat);
            return false;
          }

          final now = DateTime.now();
          if (now.difference(start).inSeconds > 10) {
            return false;
          }

          return true;
        },
      );

      return bat;
    } catch (e) {
      logger.e(e);
      assert(false);
      return null;
    }
  }

  static Stream<String?> listenDebugLogsFromPad(String deviceId,
      {required WidgetRef ref, ProviderBase? base}) async* {
    yield* BleManager.subscribeToCharacteristic(
      adminCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    )
        .map((dt) => String.fromCharCodes(dt))
        .where((event) => event.isNotEmpty)
        .map((event) => event);
  }

  static Stream<String?> listenFSR(String deviceId,
      {required WidgetRef ref, ProviderBase? base}) async* {
    yield* BleManager.subscribeToCharacteristic(
      fsrCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    )
        .map((dt) => String.fromCharCodes(dt))
        .where((event) => event.isNotEmpty)
        .map((event) => event);
  }

  static Stream<BatteryModel> listenToBattery(
    String deviceId, {
    required WidgetRef ref,
    ProviderBase? base,
    bool needRead = true,
  }) async* {
    BatteryModel? batt;
    if (ref.context.mounted) {
      yield ref.read(currentBatteryModelControlProvider)[deviceId] ??
          BatteryModel.empty();
    }
    final currentDevBatteryMap = ref.read(currentBatteryModelControlProvider);
    if (currentDevBatteryMap.containsKey(deviceId) &&
        currentDevBatteryMap[deviceId] != null) {
      yield currentDevBatteryMap[deviceId]!;
    }

    // İlk olarak bataryayı okuyoruz
    batt = await readBattery(deviceId, ref: ref);

    // Eğer `base` verilmişse kontrol ediyoruz
    if (base != null) {
      final isExist = ref.exists(base);
    }

    // Eğer batarya bilgisi boş değilse
    if (batt != null) {
      // logger.i("Bat is not null-> ${batt.toString()}");
      yield batt;

      // Aboneliği başlatıyoruz ve gelen verileri işliyoruz
      yield* BleManager.subscribeToCharacteristic(
        batteryCharacteristic.qualCharacteristic(deviceId),
        ref: ref,
      )
          .asyncMap((dt) async {
            // `dt` boş olabilir, bunu kontrol ediyoruz
            try {
              return BatteryModel.fromBytes(dt);
            } catch (e) {
              logger.e("Error parsing battery data: $e");
              return null; // Geçerli olmayan bir durumda null döndürüyoruz
            }
          })
          .where((event) => event != null)
          .map((event) => event!)
          .handleError(
            (error, stackTrace) {
              logger.e("Error during BLE subscription: $error",
                  stackTrace.toString());
              // Hataları daha anlamlı bir şekilde ele almak isterseniz, burada farklı bir şeyler de yapabilirsiniz
            },
          );
    } else {
      logger.w("Battery data could not be read initially");
    }
  }

  static Stream<String> listenToResponseForOTAUpdate(
    String deviceId, {
    required WidgetRef ref,
  }) async* {
    yield* BleManager.subscribeToCharacteristic(
      otaFwCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    ).map((event) => String.fromCharCodes(event));
  }

  static Stream<String> listenToResponseForUploadMusicFile(
    String deviceId, {
    required WidgetRef ref,
  }) async* {
    yield* BleManager.subscribeToCharacteristic(
      audioCharacteristic.qualCharacteristic(deviceId),
      ref: ref,
    ).map((event) => String.fromCharCodes(event));
  }

  // #endregion

  // #endregion

  // #region audio

  static Future<bool> _turnAudio(
      WidgetRef ref, String deviceId, bool enable) async {
    return await BleManager.writeCharacteristic(
      c: audioCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(enable ? 'ON' : 'OFF'),
      withResponse: true,
      ref: ref,
    );
  }

  static Future<bool> _turnAudioOn(WidgetRef ref, String deviceId) =>
      _turnAudio(ref, deviceId, true);

  static Future<bool> _turnAudioOff(WidgetRef ref, String deviceId) =>
      _turnAudio(ref, deviceId, false);

  static Future<bool> playAudio(
    String deviceId, {
    required WidgetRef ref,
    // required String fileName,
    double level = 1.0,
  }) async {
    assert(level >= 0.0 && level <= 1.0);

    await _turnAudioOn(ref, deviceId);

    const data =
        // TODO: data = readFile(fileName);
        <int>[];
    // martilar15s;

    const wholeSize = 500;
    const width = 1;

    // 500
    const size = wholeSize ~/ width;

    // [08 -> 8, 1f -> 31, 2d -> 45, ...]
    final st = data.map((e) => (e * level).toInt()).toList();

    final len = st.length;

    bool b = false;
    int indx = 0;

    final sw = Stopwatch();
    final sums = <int>[];

    while (!b) {
      final start = indx * size;
      final end = min((indx + 1) * size, len);

      b = end == len;

      // list of current 500
      final ls = st.sublist(start, end);

      sw.start();
      await BleManager.writeCharacteristic(
        c: audioCharacteristic.qualCharacteristic(deviceId),
        data: ls,
        withResponse: false,
        ref: ref,
      );
      sw.stop();
      int s = sw.elapsedMilliseconds;
      sums.add(s);

      indx++;
    }

    await _turnAudioOff(ref, deviceId);

    return true;
  }

// #endregion
  static Future<bool> toggleVibration(String deviceId,
      {required WidgetRef ref,
      required bool vibrationOn,
      String? val,
      bool withResponse = true}) async {
    logger.i("Vibration Activated:$vibrationOn");
    //12-14
    var power = vibrationOn ? '20' : '0';

    if (val != null) power = val;
    final isCp06 = ref.read(currentDevInfoManagers)[deviceId]?.isCp06 ?? false;

    final dt = isCp06 ? 'VIB/1/$power/1000' : '1/$power';

    return await BleManager.writeCharacteristic(
      c: vibrationCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: withResponse,
      ref: ref,
    ).timeout(const Duration(milliseconds: 200), onTimeout: () => true);
  }

  static Future<bool> toggleNfc(String deviceId,
      {required WidgetRef ref,
      required bool nfcOn,
      bool withResponse = true}) async {
    //12-14

    final dt = nfcOn ? '1' : '0';

    return await BleManager.writeCharacteristic(
      c: nfcCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: withResponse,
      ref: ref,
    );
  }

  // ACCSLEEP/3/1/8/20/3/

  static Future<bool> fabricAccSleep(String deviceId,
      {required WidgetRef ref}) async {
    final dt = ["ACCSLEEP", "3", "1", "8", "20", "3"].join(defaultSeperator);

    return await BleManager.writeCharacteristic(
        ref: ref,
        c: configCharacteristic.qualCharacteristic(deviceId),
        data: utf8.encode(dt),
        withResponse: false);
  }

  // static Future<String> getMemoryInfos(String deviceId,
  //     {required WidgetRef ref}) async {
  //  final dt = ["ACCDT","1","20","500"].join(defaultSeperator);
  //
  //
  //   return String.fromCharCodes(data);
  // }

  // Acc Double Tap Ayarı: ACCDT/1/20/500/

  static Future<bool> fabricDoubleTap(String deviceId,
      {required WidgetRef ref}) {
    final dt = ["ACCDT", "1", "20", "500"].join(defaultSeperator);

    return BleManager.writeCharacteristic(
        ref: ref,
        c: configCharacteristic.qualCharacteristic(deviceId),
        data: utf8.encode(dt),
        withResponse: false);
  }

  // Deep Sleep Ayarı: DEEPSLEEP/1/5/

  static Future<bool> fabricDeepSleep(String deviceId,
      {required WidgetRef ref}) {
    final dt = ["DEEPSLEEP", "1", "5"].join(defaultSeperator);

    return BleManager.writeCharacteristic(
        ref: ref,
        c: configCharacteristic.qualCharacteristic(deviceId),
        data: utf8.encode(dt),
        withResponse: false);
  }

  static Future<bool> toggleFSR(String deviceId,
      {required WidgetRef ref,
      required bool fsrOn,
      bool withResponse = true}) async {
    //12-14

    final dt = fsrOn ? '1' : '0';

    return await BleManager.writeCharacteristic(
      c: fsrCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: withResponse,
      ref: ref,
    );
  }

  //Hey catchpad we are still connected.
  static Future<bool> setConnectionFlagTrue(String deviceId,
      {required WidgetRef ref,
      //Todo: enable disable mode!
      bool withResponse = false}) async {
    final dt = ['SETINFO', '-1', '-1', '-1', '-1', '-1', '1', '-1', '-1']
        .join(defaultSeperator);
    return await BleManager.writeCharacteristic(
      c: infoCharacteristic.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: withResponse,
      ref: ref,
    );
  }

  static Future<String> getMemoryInfosCp06(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    // Completer oluşturuyoruz
    final completer = Completer<String>();

    // Characteristic'e subscribe oluyoruz
    BleManager.subscribeToCharacteristic(
            infoCharacteristic.qualCharacteristic(deviceId),
            ref: ref)
        .listen((event) {
      logger.i("Get Memory Infos: $event");
      // Gelen veriyi Completer ile tamamlıyoruz
      if (!completer.isCompleted) {
        completer.complete(event
            .toString()); // Burada event yerine döndürmek istediğiniz veri formatını seçebilirsiniz
      }
    });

    // Cihaza veri yazılmadan önce subscribe oluyoruz
    _sendMemoryInfoSignal(deviceId, ref: ref);

    // Completer tamamlanana kadar bekliyoruz
    return completer.future;
  }

  static Future<String> getErrorInfosCp06(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    // Completer oluşturuyoruz
    final completer = Completer<String>();

    // Characteristic'e subscribe oluyoruz
    BleManager.subscribeToCharacteristic(errorLog.qualCharacteristic(deviceId),
            ref: ref)
        .listen((event) {
      logger.i("Get Error  Infos: $event");
      // Gelen veriyi Completer ile tamamlıyoruz
      if (!completer.isCompleted) {
        completer.complete(event
            .toString()); // Burada event yerine döndürmek istediğiniz veri formatını seçebilirsiniz
      }
    });

    // Cihaza veri yazılmadan önce subscribe oluyoruz
    _sendErrorInfoSignal(deviceId, ref: ref);

    // Completer tamamlanana kadar bekliyoruz
    return completer.future;
  }

  static Future<bool> otaDisable(String deviceId,
      {required WidgetRef ref,
      bool isCommand = false,
      bool withResponse = false}) async {
    const dt = 'SETOTA/-1/0';

    return await BleManager.writeCharacteristic(
      c: otaSettings.qualCharacteristic(deviceId),
      data: utf8.encode(dt),
      withResponse: withResponse,
      ref: ref,
    );
  }

  static Future<DevInfoModel?> getDeviceInfo(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    final devInfoModel = DevInfoModel(
        deviceId: deviceId,
        macId: deviceId,
        hwVersion: "2.0",
        swVersion: "9999999",
        variantId: '3');
    ref.read(currentDevInfoManagers.notifier).add(devInfoModel);
    return devInfoModel;

    // Completer oluşturuyoruz
    final completer = Completer<DevInfoModel?>();

    // Characteristic'e subscribe oluyoruz
    BleManager.subscribeToCharacteristic(
            infoCharacteristic.qualCharacteristic(deviceId),
            ref: ref)
        .listen((event) {
      // Gelen veriyi Completer ile tamamlıyoruz
      if (!completer.isCompleted) {
        final devInfoModel = DevInfoModel.fromBytes(event, deviceId: deviceId);
        completer.complete(devInfoModel);
        ref.read(currentDevInfoManagers.notifier).add(devInfoModel);
        logger.i("Get Device Infos: $devInfoModel");
      }
    });

    // Cihaza veri yazılmadan önce subscribe oluyoruz
    // if (!completer.isCompleted) {
    //   _sendGetDeviceInfoSignal(deviceId, ref: ref);
    // }

    // Completer tamamlanana kadar bekliyoruz
    return completer.future;
  }

  static Future<BatteryModel?> getBatteryCp06(
    String deviceId, {
    required WidgetRef ref,
  }) async {
    // Completer oluşturuyoruz
    final completer = Completer<BatteryModel?>();

    // Characteristic'e subscribe oluyoruz
    BleManager.subscribeToCharacteristic(
            batteryCharacteristic.qualCharacteristic(deviceId),
            ref: ref)
        .listen((event) {
      // Gelen veriyi Completer ile tamamlıyoruz
      if (!completer.isCompleted) {
        final batteryModel = BatteryModel.fromBytes(event);
        completer.complete(BatteryModel.fromBytes(event));
        ref
            .read(currentBatteryModelControlProvider.notifier)
            .updateOrAddBatteryModel(deviceId, batteryModel);
      }
    });

    // Cihaza veri yazılmadan önce subscribe oluyoruz
    _sendGetBatterySignal(deviceId, ref: ref);

    // Completer tamamlanana kadar bekliyoruz
    return completer.future;
  }
}

/// where to print the debug info
enum AdminMonitorType {
  serial,
  ble,
}
