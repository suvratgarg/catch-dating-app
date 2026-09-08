import 'dart:async';

import 'package:catch_ui/catch_ui.dart';

/// Mutable save feedback owned and disposed by one form row editor.
class CatchFormSaveState {
  Object? error;
  bool saving = false;
  CatchFieldStatus status = CatchFieldStatus.idle;
  Timer? savedTimer;

  void reset() {
    savedTimer?.cancel();
    error = null;
    status = CatchFieldStatus.idle;
  }

  void dispose() => savedTimer?.cancel();
}
