import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/catch_test_fonts.dart';

/// Auto-discovered by `flutter test` for tests under `test/ui_captures/`.
/// Mirrors the golden-test font setup so generated captures use the same
/// committed app fonts as runtime UI.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await loadCatchTestFonts();
  await testMain();
}
