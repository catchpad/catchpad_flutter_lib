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
  factory SidesColorsModel.all100(SidesColorsColor clr) {
    return SidesColorsModel.from100Colors(tr: clr, tl: clr, br: clr, bl: clr);
  }

  factory SidesColorsModel.from100Colors({
    SidesColorsColor? tr,
    SidesColorsColor? tl,
    SidesColorsColor? br,
    SidesColorsColor? bl,
  }) {
    return SidesColorsModel(
      tr: tr?.to255Color(),
      tl: tl?.to255Color(),
      br: br?.to255Color(),
      bl: bl?.to255Color(),
    );
  }

  String colorOrNull(Color? c) {
    // if empty we should send '-1/-1/-1'
    if (c == null) {
      return List.generate(3, (index) => defaultEmptyValue)
          .join(defaultSeperator);
    }

    return [c.red, c.green, c.blue].map(colorUnitTo100).join(defaultSeperator);
  }

  int colorUnitTo100(int unit) => (unit / 255 * 100).floor();

  /// the circles take command in reverse of clockwise order
  Iterable<Color?> get clrs => [tl, bl, br, tr];

  bool get allColorsSame => clrs.every((c) => c == tl);

  @override
  String toString() {
    /// if all same we send data as 'r/g/b'
    /// else, we send each circle seperate like 'r1/g1/b1/r2/g2/b2/r3/g3/b3'
    return allColorsSame
        ? colorOrNull(clrs.elementAt(0))
        : clrs.map(colorOrNull).join(defaultSeperator);
  }

  SidesColorsModel copyWith({
    Color? tr,
    Color? tl,
    Color? br,
    Color? bl,
  }) {
    return SidesColorsModel(
      tr: tr ?? this.tr,
      tl: tl ?? this.tl,
      br: br ?? this.br,
      bl: bl ?? this.bl,
    );
  }
}

/// the range of r g b here are 0-100
class SidesColorsColor {
  int r, g, b;

  SidesColorsColor(
    this.r,
    this.g,
    this.b,
  );

  Color to255Color() {
    return Color.fromARGB(
      255,
      (r / 100 * 255).floor(),
      (g / 100 * 255).floor(),
      (b / 100 * 255).floor(),
    );
  }
}
