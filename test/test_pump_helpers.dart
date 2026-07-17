import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Finder findPrimaryScrollable() => find.byType(Scrollable).first;

Finder findFirstByType<T extends Widget>() => find.byType(T).first;

Finder findLastByType<T extends Widget>() => find.byType(T).last;

Finder findFirstByTooltip(String tooltip) => find.byTooltip(tooltip).first;

Finder findLastByTooltip(String tooltip) => find.byTooltip(tooltip).last;

Finder findLastText(String text) => find.text(text).last;

/// Advances widget tests through route, sheet, dialog, and provider-delivery
/// frames used by existing feature harnesses.
///
/// Keep direct uses narrow. Prefer a domain-specific wrapper in the test file
/// when the action is semantically a sheet, route, wizard, or mutation update.
Future<void> pumpFeatureUi(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

/// Advances a known animation/clock interval while keeping raw duration pumps
/// out of individual feature tests.
Future<void> pumpFeatureUiFor(WidgetTester tester, Duration duration) async {
  await tester.pump(duration);
}

/// Lets provider streams, callback futures, and test doubles deliver queued
/// async work without hiding the intent behind a raw zero-duration delay.
Future<void> flushTestEventQueue({int times = 20}) async {
  await pumpEventQueue(times: times);
}
