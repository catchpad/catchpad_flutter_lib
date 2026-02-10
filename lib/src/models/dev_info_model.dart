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
      deviceId,
      disconnectingCount,
      areYouOkCount,
      areYouEnable;

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
      this.deviceId,
      this.disconnectingCount,
      this.areYouOkCount,
      this.areYouEnable}); // CP ID 	/	MAC ID	/	STICKER TYPE	/	HW VERSION	/	SW VERSION	/	ACC THR	/	DST THR	/	VEL THR

  //Is cp06 device
  bool get isCp06 => true;

  bool get isCp04 => hwVersion == "v1.2";

  //TODO: Create factory for cp06 demo DevInfoModel
  factory DevInfoModel.cp06DemoDeviceInfo(
      {required String deviceId, required String macId}) {
    return DevInfoModel(
      cpId: "9999999",
      macId: macId,
      bleName: "9999999",
      stickerType: "9999999",
      hwVersion: "v3.0",
      swVersion: "9999999",
      deviceId: deviceId,
      disconnectingCount: "9999999",
      areYouOkCount: "9999999",
      noTm: "9999999",
      areYouEnable: "9999999",
      variantId: "3",
    );
  }

  factory DevInfoModel.fromBytes(List<int> bytes, {required String deviceId}) {
    final st = String.fromCharCodes(bytes);
    // "CP ID 	/	MAC ID	/	STICKER TYPE	/	HW VERSION	/	SW VERSION	/	ACC THR	/	DST THR	/	VEL THR"
    final sp = st.split('/');

    const defaultValue = "9999999";

    return (sp.toList().length != 1)
        ? DevInfoModel(
            cpId: sp.length > 4 ? sp[4] : "unknown",
            macId: sp.length > 5 ? sp[5] : "unknown",
            bleName: sp.length > 6 ? sp[6] : "unknown",
            stickerType: sp.length > 7 ? sp[7] : "unknown",
            disconnectingCount: sp.length > 8 ? sp[8] : "unknown",
            areYouOkCount: sp.length > 9 ? sp[9] : "unknown",
            hwVersion: sp.first,
            swVersion: sp[1],
            noTm: sp.length > 2 ? sp[2] : "unknown",
            variantId: sp.length > 3 ? sp[3] : "unknown",
            areYouEnable: sp.length > 10 ? sp[10] : "unknown",
            deviceId: deviceId)
        : DevInfoModel(
            cpId: defaultValue,
            macId: defaultValue,
            bleName: defaultValue,
            stickerType: defaultValue,
            hwVersion: defaultValue,
            swVersion: defaultValue,
            deviceId: deviceId,
            disconnectingCount: defaultValue,
            areYouOkCount: defaultValue,
            areYouEnable: defaultValue,
            noTm: defaultValue,
            variantId: "1",
          );
  }

  String toFabricString() {
    return "MacID:$macId\n"
        "StickerType:$stickerType\n"
        "HWVersion:$hwVersion\n"
        "SWVersion:$swVersion\n"
        "BLEName:$bleName\n"
        "AreYouOk:$areYouOkCount\n"
        "AreYouEnable:$areYouEnable\n"
        "NoTm:$noTm\n"
        "VariantId:$variantId\n"
        "ACC:$accThr\n"
        "DST:$dstThr\n"
        "VEL:$velThr";
  }

  @override
  String toString() {
    String text = "CP_INFO: "
        "Mac Id: $cpId "
        "Sticker Type: $stickerType "
        "Hardware Version: $hwVersion "
        "Software Version: $swVersion "
        "BLE Name: $bleName "
        "Are U oK: $areYouOkCount"
        "Are u ok Enable: $areYouEnable"
        "NoTm: $noTm "
        "Variant Id: $variantId "
        "ACC: $accThr "
        "DST: $dstThr "
        "Dst: $dstThr "
        "VEL: $velThr ";
    return text;
  }
}
