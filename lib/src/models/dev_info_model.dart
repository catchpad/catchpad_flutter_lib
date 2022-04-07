class DevInfoModel {
  final String cpId,
      macId,
      stickerType,
      hwVersion,
      swVersion,
      accThr,
      dstThr,
      velThr;

  const DevInfoModel({
    required this.cpId,
    required this.macId,
    required this.stickerType,
    required this.hwVersion,
    required this.swVersion,
    required this.accThr,
    required this.dstThr,
    required this.velThr,
  });

  // CP ID 	/	MAC ID	/	STICKER TYPE	/	HW VERSION	/	SW VERSION	/	ACC THR	/	DST THR	/	VEL THR

  factory DevInfoModel.fromBytes(List<int> bytes) {
    final st = String.fromCharCodes(bytes);
    final sp = st.split('/');

    return DevInfoModel(
      cpId: sp[0],
      macId: sp[1],
      stickerType: sp[2],
      hwVersion: sp[3],
      swVersion: sp[4],
      accThr: sp[5],
      dstThr: sp[6],
      velThr: sp[7],
    );
  }

  @override
  String toString() {
    return [
      'CatchPad Id: ' + cpId,
      'Mac Id: ' + macId,
      'Sticker Type: ' + stickerType,
      'Hardware Version: ' + hwVersion,
      'Software Version: ' + swVersion,
      'ACC Threshold: ' + accThr,
      'DST Threshold: ' + dstThr,
      'VEL Threshold: ' + velThr,
    ].join('\n');
  }
}
