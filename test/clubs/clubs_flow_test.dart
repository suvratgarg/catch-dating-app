import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_screen.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_discover_list.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_pump_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Clubs flow', () {
    testWidgets('club taps navigate with the required route param', (
      tester,
    ) async {
      final club = _buildClub();
      final user = _buildUser(uid: 'runner-1');
      final router = GoRouter(
        initialLocation: Routes.clubsListScreen.path,
        routes: [
          GoRoute(
            path: Routes.clubsListScreen.path,
            builder: (_, _) => Scaffold(
              body: CustomScrollView(
                slivers: [
                  ClubDiscoverList(
                    clubs: [club],
                    joinedClubIds: const {},
                    hostedClubIds: const {},
                  ),
                ],
              ),
            ),
            routes: [
              GoRoute(
                path: ':clubId',
                name: Routes.clubDetailScreen.name,
                builder: (_, state) => Text(
                  'Club ${state.pathParameters['clubId']}',
                  textDirection: TextDirection.ltr,
                ),
              ),
              GoRoute(
                path: 'create-club',
                name: Routes.createClubScreen.name,
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
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value([club])),
            uidProvider.overrideWith((ref) => Stream.value(user.uid)),
            watchActiveClubMembershipsForUserProvider(
              user.uid,
            ).overrideWith((ref) => Stream.value(const <ClubMembership>[])),
            exploreFeedViewModelProvider.overrideWithValue(
              const AsyncData(ExploreFeedViewModel(items: [])),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubFlow(tester);

      await tester.ensureVisible(find.text(club.name));
      await _pumpClubFlow(tester);
      await tester.tap(find.text(club.name));
      await _pumpClubFlow(tester);

      expect(find.text('Club ${club.id}'), findsOneWidget);
    });

    testWidgets('guest join CTA opens phone auth with the club as from route', (
      tester,
    ) async {
      final club = _buildClub();
      final router = GoRouter(
        initialLocation: Routes.clubsListScreen.path,
        routes: [
          GoRoute(
            path: Routes.authScreen.path,
            builder: (_, state) => Text(
              'Auth ${state.uri.queryParameters['from']}',
              textDirection: TextDirection.ltr,
            ),
          ),
          GoRoute(
            path: Routes.clubsListScreen.path,
            builder: (_, _) => const ClubsListScreen(),
            routes: [
              GoRoute(
                path: ':clubId',
                name: Routes.clubDetailScreen.name,
                builder: (_, state) => ClubDetailScreen(
                  clubId: state.pathParameters['clubId']!,
                  initialClub: state.extra is Club
                      ? state.extra! as Club
                      : null,
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
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value([club])),
            watchClubProvider(
              club.id,
            ).overrideWith((ref) => Stream.value(club)),
            watchEventsForClubProvider(
              club.id,
            ).overrideWith((ref) => Stream.value(const <Event>[])),
            watchReviewsForClubProvider(
              club.id,
            ).overrideWith((ref) => Stream.value(const <Review>[])),
            exploreFeedViewModelProvider.overrideWithValue(
              const AsyncData(ExploreFeedViewModel(items: [])),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubFlow(tester);

      final sheetScrollable = find
          .descendant(
            of: find.byKey(const ValueKey('explore-list-scroll-view')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text(club.name),
        200,
        scrollable: sheetScrollable,
      );
      await _pumpClubFlow(tester);
      await tester.tap(find.text(club.name));
      await _pumpClubFlow(tester);
      await tester.scrollUntilVisible(find.text('Sign in to join'), 200);
      await _pumpClubFlow(tester);
      await tester.tap(find.text('Sign in to join'));
      await _pumpClubFlow(tester);

      expect(find.text('Auth /clubs/${club.id}'), findsOneWidget);
    });

    testWidgets(
      'detail screen can load from live data without navigation extra',
      (tester) async {
        final club = _buildClub();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(club)),
              watchEventsForClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(const <Event>[])),
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
              home: ClubDetailScreen(clubId: club.id),
            ),
          ),
        );
        await _pumpClubFlow(tester);

        expect(find.text(club.name), findsOneWidget);
        expect(find.text('Club not found.'), findsNothing);
      },
    );

    testWidgets(
      'detail screen refreshes membership UI when the membership stream updates',
      (tester) async {
        final club = _buildClub();
        final controller = StreamController<Club?>.broadcast();
        final membershipController =
            StreamController<ClubMembership?>.broadcast();
        addTearDown(controller.close);
        addTearDown(membershipController.close);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchClubProvider(
                club.id,
              ).overrideWith((ref) => controller.stream),
              watchEventsForClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(const <Event>[])),
              watchReviewsForClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(const <Review>[])),
              uidProvider.overrideWith((ref) => Stream.value('runner-2')),
              watchUserProfileProvider.overrideWith(
                (ref) => Stream.value(_buildUser(uid: 'runner-2')),
              ),
              watchClubMembershipProvider(
                club.id,
                'runner-2',
              ).overrideWith((ref) => membershipController.stream),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: ClubDetailScreen(clubId: club.id, initialClub: club),
            ),
          ),
        );
        // Pump once so the provider subscribes to controller.stream, then emit initial value.
        await tester.pump();
        controller.add(club);
        membershipController.add(null);
        await _pumpClubFlow(tester);

        expect(find.text('Join club'), findsOneWidget);
        expect(find.text('Leave club'), findsNothing);

        membershipController.add(_membership(clubId: club.id, uid: 'runner-2'));
        await _pumpClubFlow(tester);

        expect(find.text('Join club'), findsNothing);
        expect(find.text('Leave club'), findsOneWidget);
      },
    );
  });
}

Future<void> _pumpClubFlow(WidgetTester tester) async {
  await pumpFeatureUi(tester);
}

Club _buildClub({String id = 'club-1', String hostUserId = 'host-1'}) {
  return Club(
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

ClubMembership _membership({required String clubId, required String uid}) =>
    ClubMembership(
      id: clubMembershipId(clubId: clubId, uid: uid),
      clubId: clubId,
      uid: uid,
      role: ClubMembershipRole.member,
      status: ClubMembershipStatus.active,
      joinedAt: DateTime(2026),
    );
