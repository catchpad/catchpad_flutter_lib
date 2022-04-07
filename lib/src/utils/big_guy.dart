import 'dart:ui';

import 'package:xrandom/xrandom.dart';

/// this class is just here for general purposed
/// methods
abstract class BigGuy {
  static Color randomColor() => Color(0xFF000000 | Xrandom().nextInt(0xFFFFFF));

  static int boolToInt(bool b) => b ? 1 : 0;

  static bool intToBool(int i) => i == 1;

  static String boolToNumString(bool b) => boolToInt(b).toString();

  static bool numStringToBool(String s) => intToBool(int.parse(s));

  static Duration responseTime(int actionTime, int commandTime) {
    final ms = actionTime - commandTime;
    return Duration(milliseconds: ms);
  }
}
