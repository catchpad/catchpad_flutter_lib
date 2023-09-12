import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectingStateControlProv =
    StateNotifierProvider<ConnectingStateControlNotifier, bool>(
        (ref) => ConnectingStateControlNotifier(false));

class ConnectingStateControlNotifier extends StateNotifier<bool> {
  ConnectingStateControlNotifier(bool state) : super(false);

  void changeState(bool value, WidgetRef ref) => state = value;

}
