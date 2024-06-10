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
  }

  Future<void> startDelay() async {
    state = false;
    Future.delayed(Duration(milliseconds: _delayMs), () {
      state = true;
    });
  }

}
