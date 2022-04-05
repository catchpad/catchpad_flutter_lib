import 'dart:ui';

import '../utils/pad_consts.dart';

class SidesColorsModel {
  final Color? tr, tl, br, bl;

  const SidesColorsModel({
    this.tr,
    this.tl,
    this.br,
    this.bl,
  });

  factory SidesColorsModel.off() {
    const offColor = Color(0xFF000000);
    return const SidesColorsModel(
        tr: offColor, tl: offColor, br: offColor, bl: offColor);
  }
  factory SidesColorsModel.all(Color clr) {
    return SidesColorsModel(tr: clr, tl: clr, br: clr, bl: clr);
  }

  String colorOrNull(Color? c) {
    // if empty we should send '-1/-1/-1'
    if (c == null) {
      return List.generate(3, (index) => defaultEmptyValue).join('/');
    }

    return [c.red, c.green, c.blue].map(colorUnitTo100).join(defaultSeperator);
  }

  int colorUnitTo100(int unit) => (unit / 255 * 100).floor();

  /// the circles take command in reverse of clockwise order
  Iterable<Color?> get clrs => [tl, bl, br, tr];

  @override
  String toString() {
    return clrs.map(colorOrNull).join(defaultSeperator);
  }
}
