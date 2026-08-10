import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _featureTestFrame = Duration(milliseconds: 16);
const _maximumFeatureTestFrames = 120;

/// Finds the vertical [Scrollable] owned by a named surface or route.
///
/// The owner excludes horizontal rails and nested text-input scrollables
/// without relying on tree position.
Finder findVerticalScrollable({required Finder within}) {
  final owners = within.evaluate().toList(growable: false);
  if (owners.length != 1) {
    throw TestFailure(
      'Expected one scroll-view owner for $within, found ${owners.length}.',
    );
  }
  final owner = owners.single;
  return find.byElementPredicate((element) {
    final widget = element.widget;
    if (widget is! Scrollable ||
        (widget.axisDirection != AxisDirection.down &&
            widget.axisDirection != AxisDirection.up)) {
      return false;
    }

    var belongsToOwner = false;
    var nestedInsideAnotherScrollable = false;
    element.visitAncestorElements((ancestor) {
      if (identical(ancestor, owner)) {
        belongsToOwner = true;
        return false;
      }
      if (ancestor.widget is Scrollable) {
        nestedInsideAnotherScrollable = true;
        return false;
      }
      return true;
    });
    return belongsToOwner && !nestedInsideAnotherScrollable;
  }, description: 'vertical Scrollable directly owned by $within');
}

/// Advances widget tests through route, sheet, dialog, and provider-delivery
/// frames used by existing feature harnesses.
///
/// Keep direct uses narrow. Prefer a domain-specific wrapper in the test file
/// when the action is semantically a sheet, route, wizard, or mutation update.
Future<void> pumpFeatureUi(WidgetTester tester) async {
  await tester.pump();
  for (var frame = 0; frame < _maximumFeatureTestFrames; frame += 1) {
    if (!tester.binding.hasScheduledFrame) return;
    await tester.pump(_featureTestFrame);
  }
  throw TestFailure(
    'Feature UI still scheduled frames after '
    '$_maximumFeatureTestFrames deterministic test frames.',
  );
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
