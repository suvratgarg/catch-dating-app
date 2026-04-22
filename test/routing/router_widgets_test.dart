import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../run_clubs/run_clubs_test_helpers.dart';

void main() {
  testWidgets('create-run route fetches the club when no extra is available', (
    tester,
  ) async {
    final club = buildRunClub(id: 'club-1', hostUserId: 'host-1');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fetchRunClubProvider('club-1').overrideWith((ref) async => club),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CreateRunRouteScreen(runClubId: 'club-1'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Select a date'), findsOneWidget);
    expect(find.text('Run club not found.'), findsNothing);
  });
}
