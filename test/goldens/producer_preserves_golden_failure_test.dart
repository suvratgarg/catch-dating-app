import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Temporary hosted negative control. Never merge this intentionally failing test
// or regenerate its existing baseline to accept the mismatch.
void main() {
  testWidgets(
    'generated captures cannot approve a real golden mismatch',
    (tester) async {
      expect(
        autoUpdateGoldenFiles,
        isFalse,
        reason: 'The negative control must never update the reviewed baseline.',
      );
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(440, 1450);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      const key = ValueKey<String>('intentional-golden-mismatch');
      await tester.pumpWidget(
        const RepaintBoundary(
          key: key,
          child: SizedBox.expand(child: ColoredBox(color: Color(0xffff00ff))),
        ),
      );
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('baseline/bar_indicator_family@1.0.light.png'),
      );
    },
    tags: const ['golden'],
  );
}
