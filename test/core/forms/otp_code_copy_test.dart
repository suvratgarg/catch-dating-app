import 'package:catch_dating_app/core/widgets/catch_otp_code_field.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(
  theme: CatchTheme.light,
  home: Scaffold(body: child),
);

void main() {
  test('the app catalog preserves the existing OTP accessibility label', () {
    expect(
      AppLocalizationsEn().coreCatchOtpCodeFieldSemanticLabel,
      'One-time code',
    );
  });

  testWidgets(
    'caller label leaves paste, contract length and autofill intact',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String? changed;
      String? submitted;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => CatchOtpCodeField(
              semanticsLabel: 'Code à usage unique',
              inputKey: const ValueKey('otp-input'),
              contract: const CatchContractFieldConstraints(
                path: 'test.code',
                valueTypes: ['string'],
                minLength: 4,
                maxLength: 4,
              ),
              length: 6,
              controller: controller,
              autofocus: true,
              onChanged: (value) => setState(() => changed = value),
              onSubmitted: (value) => submitted = value,
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Code à usage unique'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('otp-input')),
        '1a2b3456',
      );
      await tester.pump();
      expect(changed, '1234');
      expect(controller.text, '1234');
      expect(find.byType(CatchCodeInputCell), findsNWidgets(4));
      expect(find.byKey(const ValueKey('otp_digit_3')), findsOneWidget);
      expect(find.byKey(const ValueKey('otp_digit_4')), findsNothing);
      expect(tester.widget<TextField>(find.byType(TextField)).autofillHints, [
        AutofillHints.oneTimeCode,
      ]);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, '1234');
    },
  );

  testWidgets(
    'new accessibility copy preserves controller and digit identities',
    (tester) async {
      final controller = TextEditingController(text: '12');
      addTearDown(controller.dispose);
      var label = 'One-time code';
      late StateSetter rebuild;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return CatchOtpCodeField(
                semanticsLabel: label,
                controller: controller,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {},
              );
            },
          ),
        ),
      );
      final firstDigit = tester.element(
        find.byKey(const ValueKey('otp_digit_0')),
      );
      rebuild(() => label = 'Code à usage unique');
      await tester.pump();
      final spokenLabel = tester
          .getSemantics(find.byType(CatchOtpCodeField))
          .label;
      expect(spokenLabel, startsWith('Code à usage unique'));
      expect(spokenLabel, isNot(contains('One-time code')));
      expect(controller.text, '12');
      expect(
        tester.element(find.byKey(const ValueKey('otp_digit_0'))),
        same(firstDigit),
      );
    },
  );
}
