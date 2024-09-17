import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final currentHasDelayState =
StateNotifierProvider<PadListenDelayControlNotifier, bool>(
      (_) => PadListenDelayControlNotifier(false),
);


class PadListenDelayControlNotifier extends StateNotifier<bool> {
  PadListenDelayControlNotifier(bool state) : super(false);

  int _delayMs = 50;

  set delayMs(int delayMs) {
    _delayMs = delayMs;
    logger.i('startDelay2');
  }

  Future<void> startDelay() async {
    logger.i('startDelay');
    state = false;
    Future.delayed(Duration(milliseconds: _delayMs), () {
      state = true;
    });
  }

}
