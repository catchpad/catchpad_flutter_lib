

import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter/cupertino.dart';

class DevInfoModel {
  String? cpId,
      macId,
      stickerType,
      hwVersion,
      swVersion,
      bleName,
      accThr,
      noTm,
      variantId,
      dstThr,
      velThr,
      deviceId;


  DevInfoModel(
      {this.cpId,
        this.macId,
        this.stickerType,
        this.hwVersion,
        this.swVersion,
        this.bleName,
        this.accThr,
        this.noTm,
        this.variantId,
        this.dstThr,
        this.velThr,
        this.deviceId}); // CP ID 	/	MAC ID	/	STICKER TYPE	/	HW VERSION	/	SW VERSION	/	ACC THR	/	DST THR	/	VEL THR

  factory DevInfoModel.fromBytes(List<int> bytes,{required String deviceId}) {
    final st = String.fromCharCodes(bytes);
    final sp = st.split('/');

    const defaultValue = "9999999";


    return ( sp.toList().length != 1) ? DevInfoModel(
        cpId: sp[4],
        macId: sp[5],
        bleName: sp[6],
        stickerType: sp[7],
        hwVersion: sp[0],
        swVersion: sp[1],
        noTm: sp[2],
        variantId: sp[3],
        deviceId: deviceId

    ) : DevInfoModel(
      cpId: defaultValue,
      macId: defaultValue,
      bleName: defaultValue,
      stickerType: defaultValue,
      hwVersion: defaultValue,
      swVersion: defaultValue,
      deviceId: deviceId,
      noTm: defaultValue,
      variantId: "1",

    );
  }

  bool get isCp04 => hwVersion == "v1.2";

  @override
  String toString() {
    return [
      'CatchPad Id: $cpId',
      'Mac Id: $macId',
      'Sticker Type: $stickerType',
      'Hardware Version: $hwVersion',
      'Software Version: $swVersion',
      'ACC Threshold: $accThr',
      'DST Threshold: $dstThr',
      'VEL Threshold: $velThr',
      'VEL Threshold: $deviceId',
    ].join('\n');
  }
}
