import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/matches/presentation/chat_list_tile.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('stays tappable when the public profile read fails', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          publicProfileProvider(
            'runner-2',
          ).overrideWith((ref) => Stream<Never>.error(Exception('boom'))),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ChatListTile(
              match: Match(
                id: 'match-1',
                user1Id: 'runner-1',
                user2Id: 'runner-2',
                runId: 'run-1',
                createdAt: DateTime(2026, 4, 23, 9),
              ),
              currentUid: 'runner-1',
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('You matched!'), findsOneWidget);

    await tester.tap(find.byType(ListTile));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
