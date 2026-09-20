import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets('header command retains its platform font at scale $scale', (
      tester,
    ) async {
      const commandKey = ValueKey('header-command');
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.light,
          home: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: CatchSection.content(
                title: 'Your focus',
                trailing: CatchButton.command(
                  key: commandKey,
                  label: 'Change focus',
                  onPressed: () {},
                ),
                child: const Text('Grow my audience'),
              ),
            ),
          ),
        ),
      );
      final command = find.byKey(commandKey);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: command, matching: find.byType(RichText)),
      );
      final expected = CatchTextStyles.control(tester.element(command));
      expect(paragraph.text.toPlainText(), 'Change focus');
      expect(paragraph.text.style?.fontFamily, expected.fontFamily);
      expect(
        paragraph.text.style?.fontFamily,
        isNot(startsWith('packages/catch_ui/')),
        reason: 'The mono header package must not qualify a system font.',
      );
      expect(paragraph.text.style?.fontSize, expected.fontSize);
      expect(paragraph.text.style?.fontWeight, expected.fontWeight);
      expect(paragraph.text.style?.color, expected.color);
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
