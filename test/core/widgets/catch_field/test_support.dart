import 'package:flutter_test/flutter_test.dart';

const double minimumAccessibleTarget = 44;

void expectMinimumAccessibleTarget(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  expect(rect.width, greaterThanOrEqualTo(minimumAccessibleTarget));
  expect(rect.height, greaterThanOrEqualTo(minimumAccessibleTarget));
}
