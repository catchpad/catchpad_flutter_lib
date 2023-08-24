import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CurrentQualifiedCharacteristic = Set<QualifiedCharacteristic>;


final currentQualifiedManagerProv =
    StateNotifierProvider<CurrentQualifiedManagerNotifier, CurrentQualifiedCharacteristic>(
        (ref) => CurrentQualifiedManagerNotifier({}));

class CurrentQualifiedManagerNotifier
    extends StateNotifier<CurrentQualifiedCharacteristic> {
  CurrentQualifiedManagerNotifier(CurrentQualifiedCharacteristic state)
      : super({});
  WidgetRef? ref;
  void add(WidgetRef customRef, QualifiedCharacteristic q) {
    state.add(q);
    ref = customRef;
  }

  void refreshSubscribes(){
    for (var perQualifed in state) {
      BleManager.subscribeToCharacteristic(perQualifed, ref: ref!);
    }
  }

  void deleteAll(WidgetRef ref) => state.clear();
}
