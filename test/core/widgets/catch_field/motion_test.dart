import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchField input omits AnimatedSize under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: CatchField.input(title: 'Why Catch?', maxLines: 5),
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(CatchField),
        matching: find.byType(AnimatedSize),
      ),
      findsNothing,
    );
  });
}
