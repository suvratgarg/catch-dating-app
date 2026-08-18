import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_follower_update_composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart' as club_test;
import '../test_pump_helpers.dart';

void main() {
  testWidgets('submits trimmed follower copy and closes after acceptance', (
    tester,
  ) async {
    String? submitted;
    final club = club_test.buildClub(id: 'organizer-1');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => unawaited(
                showHostFollowerUpdateComposer(
                  context: context,
                  club: club,
                  remainingQuota: 2,
                  onSubmitPost: (text) async => submitted = text,
                ),
              ),
              child: const Text('Open composer'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open composer'));
    await pumpFeatureUi(tester);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-follower-update-text')),
        matching: find.byType(EditableText),
      ),
      '  Meet by the east gate.  ',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('host-follower-update-submit')));
    await pumpFeatureUi(tester);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1));

    expect(submitted, 'Meet by the east gate.');
    expect(find.text('Post to followers'), findsNothing);
    expect(find.text('Posted to followers.'), findsOneWidget);
  });
}
