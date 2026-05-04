import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_detail_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_screen.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Run clubs flow', () {
    testWidgets('club taps navigate with the required route param', (
      tester,
    ) async {
      final club = _buildClub();
      final user = _buildUser(uid: 'runner-1');
      final router = GoRouter(
        initialLocation: Routes.runClubsListScreen.path,
        routes: [
          GoRoute(
            path: Routes.runClubsListScreen.path,
            builder: (_, _) => const RunClubsListScreen(),
            routes: [
              GoRoute(
                path: 'run-clubs/:runClubId',
                name: Routes.runClubDetailScreen.name,
                builder: (_, state) => Text(
                  'Club ${state.pathParameters['runClubId']}',
                  textDirection: TextDirection.ltr,
                ),
              ),
              GoRoute(
                path: 'create-run-club',
                name: Routes.createRunClubScreen.name,
                builder: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
            watchRunClubsByLocationProvider(
              IndianCity.mumbai,
            ).overrideWith((ref) => Stream.value([club])),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(club.name).first);
      await tester.pumpAndSettle();

      expect(find.text('Club ${club.id}'), findsOneWidget);
    });

    testWidgets(
      'detail screen can load from live data without navigation extra',
      (tester) async {
        final club = _buildClub();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchRunClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(club)),
              watchRunsForClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(const <Run>[])),
              watchReviewsForClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(const <Review>[])),
              uidProvider.overrideWith((ref) => Stream.value(null)),
              watchUserProfileProvider.overrideWith(
                (ref) => Stream.value(null),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: RunClubDetailScreen(runClubId: club.id),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(club.name), findsOneWidget);
        expect(find.text('Run club not found.'), findsNothing);
      },
    );

    testWidgets(
      'detail screen refreshes membership UI when the club stream updates',
      (tester) async {
        final club = _buildClub();
        final controller = StreamController<RunClub?>.broadcast();
        addTearDown(controller.close);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchRunClubProvider(
                club.id,
              ).overrideWith((ref) => controller.stream),
              watchRunsForClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(const <Run>[])),
              watchReviewsForClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(const <Review>[])),
              uidProvider.overrideWith((ref) => Stream.value('runner-2')),
              watchUserProfileProvider.overrideWith(
                (ref) => Stream.value(_buildUser(uid: 'runner-2')),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: RunClubDetailScreen(
                runClubId: club.id,
                initialRunClub: club,
              ),
            ),
          ),
        );
        // Pump once so the provider subscribes to controller.stream, then emit initial value.
        await tester.pump();
        controller.add(club);
        await tester.pumpAndSettle();

        expect(find.text('Join club'), findsOneWidget);
        expect(find.text('Leave club'), findsNothing);

        controller.add(
          club.copyWith(memberUserIds: [...club.memberUserIds, 'runner-2']),
        );
        await tester.pumpAndSettle();

        expect(find.text('Join club'), findsNothing);
        expect(find.text('Leave club'), findsOneWidget);
      },
    );
  });
}

RunClub _buildClub({
  String id = 'club-1',
  String hostUserId = 'host-1',
  List<String> memberUserIds = const ['host-1'],
}) {
  return RunClub(
    id: id,
    name: 'Stride Social',
    description: 'Morning runners who like easy city loops.',
    location: IndianCity.mumbai,
    area: 'Bandra',
    hostUserId: hostUserId,
    hostName: 'Host',
    createdAt: DateTime(2025, 1, 1),
    memberUserIds: memberUserIds,
  );
}

UserProfile _buildUser({
  required String uid,
  List<String> joinedRunClubIds = const [],
}) {
  return UserProfile(
    uid: uid,
    email: '$uid@example.com',
    name: 'Runner $uid',
    dateOfBirth: DateTime(1995, 6, 15),
    bio: 'Here for the runs.',
    gender: Gender.man,
    phoneNumber: '+10000000000',
    profileComplete: true,
    joinedRunClubIds: joinedRunClubIds,
    interestedInGenders: const [Gender.woman],
  );
}
