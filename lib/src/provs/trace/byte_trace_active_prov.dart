import 'package:flutter_riverpod/flutter_riverpod.dart';


final byteTraceActiveControlProv =
    StateNotifierProvider<ByteTraceActiveControlNotifier, bool>(
        (ref) => ByteTraceActiveControlNotifier(false));

class ByteTraceActiveControlNotifier extends StateNotifier<bool> {
  ByteTraceActiveControlNotifier(bool state) : super(false);

  void changState(bool val) => state = val;
}
