import 'package:flutter_riverpod/flutter_riverpod.dart';

///This prov created for sometimes gets elapsed time 0 from pad.This problem
///leads to illogical calculations.Overcoming these obstacles with this provider
///is our main goal.

final commandDurationProv =
    StateNotifierProvider<CommandDurationControlNotifier, DateTime?>(
        (ref) => CommandDurationControlNotifier(null));

/// Maybe use chronometer instead of datetime. I think DateTime sense more
/// than Chronometer.Because chronometer consume ram in any game session.
/// DateTime logic once set start point by DateTime.now() and wait.
/// When get signal from pad set look this state and get different between
/// current time - current state

class CommandDurationControlNotifier extends StateNotifier<DateTime?> {
  CommandDurationControlNotifier(DateTime? state) : super(null);

  Future<void> setStartTimeByMillisecond() async =>
      state = DateTime.now();

}
