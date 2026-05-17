import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_detail_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_screen.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_pump_helpers.dart';

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
              'mumbai',
            ).overrideWith((ref) => Stream.value([club])),
            uidProvider.overrideWith((ref) => Stream.value(user.uid)),
            watchActiveRunClubMembershipsForUserProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value(const <RunClubMembership>[])),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpRunClubFlow(tester);

      await tester.tap(find.bySemanticsLabel('Open ${club.name} run club'));
      await _pumpRunClubFlow(tester);

      expect(find.text('Club ${club.id}'), findsOneWidget);
    });

    testWidgets('guest join CTA opens phone auth with the club as from route', (
      tester,
    ) async {
      final club = _buildClub();
      final router = GoRouter(
        initialLocation: Routes.runClubsListScreen.path,
        routes: [
          GoRoute(
            path: Routes.authScreen.path,
            builder: (_, state) => Text(
              'Auth ${state.uri.queryParameters['from']}',
              textDirection: TextDirection.ltr,
            ),
          ),
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
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value(null)),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
            watchRunClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value([club])),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpRunClubFlow(tester);

      await tester.tap(find.text('Join'));
      await _pumpRunClubFlow(tester);

      expect(find.text('Auth /clubs/run-clubs/${club.id}'), findsOneWidget);
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
        await _pumpRunClubFlow(tester);

        expect(find.text(club.name), findsOneWidget);
        expect(find.text('Run club not found.'), findsNothing);
      },
    );

    testWidgets(
      'detail screen refreshes membership UI when the membership stream updates',
      (tester) async {
        final club = _buildClub();
        final controller = StreamController<RunClub?>.broadcast();
        final membershipController =
            StreamController<RunClubMembership?>.broadcast();
        addTearDown(controller.close);
        addTearDown(membershipController.close);

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
              watchRunClubMembershipProvider(
                club.id,
                'runner-2',
              ).overrideWith((ref) => membershipController.stream),
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
        membershipController.add(null);
        await _pumpRunClubFlow(tester);

        expect(find.text('Join club'), findsOneWidget);
        expect(find.text('Leave club'), findsNothing);

        membershipController.add(_membership(clubId: club.id, uid: 'runner-2'));
        await _pumpRunClubFlow(tester);

        expect(find.text('Join club'), findsNothing);
        expect(find.text('Leave club'), findsOneWidget);
      },
    );
  });
}

Future<void> _pumpRunClubFlow(WidgetTester tester) async {
  await pumpFeatureUi(tester);
}

RunClub _buildClub({String id = 'club-1', String hostUserId = 'host-1'}) {
  return RunClub(
    id: id,
    name: 'Stride Social',
    description: 'Morning runners who like easy city loops.',
    location: 'mumbai',
    area: 'Bandra',
    hostUserId: hostUserId,
    hostName: 'Host',
    createdAt: DateTime(2025, 1, 1),
  );
}

UserProfile _buildUser({required String uid}) {
  return UserProfile(
    uid: uid,
    email: '$uid@example.com',
    name: 'Runner $uid',
    dateOfBirth: DateTime(1995, 6, 15),
    gender: Gender.man,
    phoneNumber: '+10000000000',
    profileComplete: true,
    interestedInGenders: const [Gender.woman],
  );
}

RunClubMembership _membership({required String clubId, required String uid}) =>
    RunClubMembership(
      id: runClubMembershipId(clubId: clubId, uid: uid),
      clubId: clubId,
      uid: uid,
      role: RunClubMembershipRole.member,
      status: RunClubMembershipStatus.active,
      joinedAt: DateTime(2026),
    );
