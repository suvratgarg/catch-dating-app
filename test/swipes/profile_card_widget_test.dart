import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/name_overlay.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

Widget _profileCardHarness({required ThemeData theme}) {
  final profile = buildPublicProfile(
    name: 'Manan',
    age: 26,
  ).copyWith(city: 'indore', relationshipGoal: RelationshipGoal.casual);

  return ProviderScope(
    child: MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 340,
            height: 620,
            child: ProfileCard(profile: profile),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('NameOverlay shows display name, age, and city only', (
    tester,
  ) async {
    final profile = buildPublicProfile(
      name: 'Manan',
      age: 26,
    ).copyWith(city: 'indore', relationshipGoal: RelationshipGoal.casual);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: NameOverlay(profile: profile)),
      ),
    );

    expect(find.text('Manan'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('Indore'), findsOneWidget);
    expect(find.text('Something casual'), findsNothing);
  });

  testWidgets(
    'ProfileCard renders polished missing-photo state in light mode',
    (tester) async {
      await tester.pumpWidget(_profileCardHarness(theme: AppTheme.light));
      await tester.pump();

      expect(find.text('Photo coming soon'), findsOneWidget);
      expect(find.text('ON A PERFECT RUN'), findsOneWidget);
      expect(find.text('Something casual'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ProfileCard renders the same content in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(_profileCardHarness(theme: AppTheme.dark));
    await tester.pump();

    expect(find.text('Photo coming soon'), findsOneWidget);
    expect(find.text('Manan'), findsOneWidget);
    expect(find.text('RUN PROFILE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
