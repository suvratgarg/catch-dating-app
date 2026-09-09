part of 'catch_section_test.dart';

void _registerSectionInteractionTests() {
  testWidgets(
    'semantic page body gives divided field interaction the full paint plane',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 390,
              child: CatchPageBody.screen(
                variant: CatchPageBodyVariant.fixed,
                pt: 0,
                pb: 0,
                child: CatchSection.fieldRows(
                  first: true,
                  title: 'Notifications',
                  children: [
                    CatchField.nav(
                      copy: catchFieldCopy(AppLocalizationsEn()),
                      title: 'Delivery',
                      onTap: _noop,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final fieldRect = tester.getRect(find.byType(CatchField));
      final overlayFinder = find.byKey(CatchField.pressOverlayKey);
      final overlayRect = tester.getRect(overlayFinder);
      expect(fieldRect.left, CatchSpacing.screenPx);
      expect(fieldRect.right, 390 - CatchSpacing.screenPx);
      expect(overlayRect.left, 0);
      expect(overlayRect.right, 390);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CatchField)),
      );
      await tester.pump();
      final decoration =
          tester.widget<AnimatedContainer>(overlayFinder).decoration!
              as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.zero);
      expect(decoration.border, isNull);
      expect(
        decoration.color,
        CatchFieldTokens.pressedSurface(CatchTokens.editorialLight),
      );
      await gesture.up();
    },
  );

  testWidgets(
    'divided section can explicitly retain rounded tile interaction',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 390,
              child: CatchPageBody.screen(
                variant: CatchPageBodyVariant.fixed,
                pt: 0,
                pb: 0,
                child: CatchSection.fieldRows(
                  first: true,
                  interaction: CatchDividedFieldInteraction.roundedTile,
                  children: [
                    CatchField.nav(
                      copy: catchFieldCopy(AppLocalizationsEn()),
                      title: 'Delivery',
                      onTap: _noop,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final fieldRect = tester.getRect(find.byType(CatchField));
      final overlayRect = tester.getRect(
        find.byKey(CatchField.pressOverlayKey),
      );
      expect(
        overlayRect.left,
        fieldRect.left - CatchFieldTokens.dividedRowBleed,
      );
      expect(
        overlayRect.right,
        fieldRect.right + CatchFieldTokens.dividedRowBleed,
      );
    },
  );
}
