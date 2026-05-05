import 'package:flutter_test/flutter_test.dart';

/// Advances widget tests through route, sheet, dialog, and provider-delivery
/// frames used by existing feature harnesses.
///
/// Keep direct uses narrow. Prefer a domain-specific wrapper in the test file
/// when the action is semantically a sheet, route, wizard, or mutation update.
Future<void> pumpFeatureUi(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

/// Lets provider streams, callback futures, and test doubles deliver queued
/// async work without hiding the intent behind a raw zero-duration delay.
Future<void> flushTestEventQueue({int times = 20}) async {
  await pumpEventQueue(times: times);
}
