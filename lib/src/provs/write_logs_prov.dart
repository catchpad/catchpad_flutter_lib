


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';


/// Save Write Commands

final writeLogControlNotifierProvider = StateNotifierProvider<WriteLogControlNotifier, List<String>>((ref) {
  return WriteLogControlNotifier([]);
});

class WriteLogControlNotifier extends StateNotifier<List<String>> {
  WriteLogControlNotifier(List<String> state) : super([]);

  void addLog(String log) {
    state = [...state, log];
  }

  void clearLogs() {
    state = [];
  }
}