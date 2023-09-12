import 'package:async/async.dart';
import 'package:catchpad_flutter_lib/catchpad_flutter_lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef CurrentQualifiedCharacteristic = Set<QualifiedCharacteristic>;

final currentQualifiedManagerProv = StateNotifierProvider<
        CurrentQualifiedManagerNotifier, CurrentQualifiedCharacteristic>(
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

  void refreshSubscribes() {

  }

  void deleteAll(WidgetRef ref) => state.clear();
}
