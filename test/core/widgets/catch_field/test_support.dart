import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

double get minimumAccessibleTarget =>
    CatchPlatformTokens.minimumInteractiveExtent;

void expectMinimumAccessibleTarget(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  expect(rect.width, greaterThanOrEqualTo(minimumAccessibleTarget));
  expect(rect.height, greaterThanOrEqualTo(minimumAccessibleTarget));
}
