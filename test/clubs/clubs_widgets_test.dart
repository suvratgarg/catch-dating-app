import 'dart:async';
import 'dart:convert';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/create/create_club_controller.dart';
import 'package:catch_dating_app/clubs/presentation/create/create_club_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/membership_button.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/stats_strip.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_screen.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/city_picker.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_list_tile.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list_body.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_sliver_header.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_cover_fallback.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_club_tools.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_pump_helpers.dart';
import 'clubs_test_helpers.dart';

const _testCities = [
  CityData(
    name: 'mumbai',
    label: 'Mumbai',
    latitude: 19.0760,
    longitude: 72.8777,
  ),
  CityData(
    name: 'delhi',
    label: 'Delhi',
    latitude: 28.7041,
    longitude: 77.1025,
  ),
];

class _NoDeviceLocation extends DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async => null;
}

Future<void> _pumpClubsSlivers(
  WidgetTester tester,
  List<Widget> slivers,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [uidProvider.overrideWith((ref) => Stream.value(null))],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: CustomScrollView(slivers: slivers)),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _pumpClubUi(WidgetTester tester) async {
  await pumpFeatureUi(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Clubs widgets', () {
    testWidgets('ClubsList shows the empty state when there are no clubs', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value(const [])),
            clubsListViewModelProvider.overrideWithValue(
              const AsyncData(
                ClubsListViewModel(joinedClubs: [], allClubs: []),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: CustomScrollView(slivers: [ClubsList()]),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No clubs in this city yet'), findsOneWidget);
      expect(find.text('Be the first to create one!'), findsOneWidget);
    });

    testWidgets('ClubsList shows search-specific empty copy', (tester) async {
      final sourceClub = buildClub(id: 'source-club', name: 'Bandra Pacers');
      final container = ProviderContainer(
        overrides: [
          watchClubsByLocationProvider(
            'mumbai',
          ).overrideWith((ref) => Stream.value([sourceClub])),
          clubsListViewModelProvider.overrideWithValue(
            const AsyncData(ClubsListViewModel(joinedClubs: [], allClubs: [])),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(clubSearchQueryProvider.notifier).setQuery('tempo');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: CustomScrollView(slivers: [ClubsList()]),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No clubs match your search'), findsOneWidget);
      expect(
        find.text('Try another club, neighborhood, host, or tag.'),
        findsOneWidget,
      );
      expect(find.text('No clubs in this city yet'), findsNothing);
    });

    testWidgets('ClubsContent renders avatar rail and discover sections', (
      tester,
    ) async {
      await _pumpClubsSlivers(tester, [
        ClubsListBody(
          viewModel: ClubsListViewModel(
            joinedClubs: [
              buildClub(id: 'joined-1', nextEventLabel: 'Sat 6:30 AM'),
            ],
            allClubs: [
              buildClub(id: 'joined-1', nextEventLabel: 'Sat 6:30 AM'),
              buildClub(id: 'discover-1'),
            ],
            joinedClubIds: {'joined-1'},
            hostedClubIds: {'joined-1'},
          ),
        ),
      ]);

      expect(find.text('Your clubs'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(_catchButtonWithLabel('Host'), findsOneWidget);
    });

    testWidgets(
      'ClubsHeader updates search query and clears it when the city changes',
      (tester) async {
        final container = ProviderContainer(
          retry: (_, _) => null,
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            uidProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: Builder(
                  builder: (context) => CustomScrollView(
                    slivers: ClubsSliverHeader().buildSlivers(context),
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpClubUi(tester);

        expect(
          tester.getSize(find.byType(CityPicker)).height,
          CatchTextField.compactControlHeight,
        );
        expect(
          tester.getSize(find.byType(CatchTextField)).height,
          CatchTextField.compactControlHeight,
        );

        await tester.enterText(find.byType(TextField), 'asha');
        await tester.pump();

        expect(container.read(clubSearchQueryProvider), 'asha');

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump();

        expect(container.read(clubSearchQueryProvider), isEmpty);

        await tester.enterText(find.byType(TextField), 'asha');
        await tester.pump();

        await tester.tap(find.text('Mumbai'));
        await _pumpClubUi(tester);
        await tester.tap(find.text('Delhi').hitTestable());
        await _pumpClubUi(tester);

        expect(container.read(selectedClubCityProvider).name, 'delhi');
        expect(container.read(clubSearchQueryProvider), isEmpty);

        final searchField = tester.widget<TextField>(find.byType(TextField));
        expect(searchField.controller!.text, isEmpty);
      },
    );

    testWidgets('ClubsHeader add button navigates to create club', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: Builder(
                builder: (context) => CustomScrollView(
                  slivers: ClubsSliverHeader().buildSlivers(context),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/create-club',
            name: Routes.createClubScreen.name,
            builder: (_, _) =>
                const Text('Create club', textDirection: TextDirection.ltr),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
            watchClubsHostedByProvider(
              'host-1',
            ).overrideWith((ref) => Stream.value(const <Club>[])),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await _pumpClubUi(tester);

      expect(find.text('Create club'), findsOneWidget);
    });

    testWidgets('directory and avatar chip variants render club metadata', (
      tester,
    ) async {
      final club = buildClub(
        name: 'Night Pacers',
        location: 'indore',
        tags: const ['social', 'Indore'],
        rating: 4.8,
        nextEventLabel: 'Race Course Road Main Gate',
      );

      await pumpTestApp(
        tester,
        Column(
          children: [
            Expanded(
              child: ClubListTile(
                club: club,
                variant: ClubListTileVariant.directory,
                isJoined: true,
              ),
            ),
            ClubListTile(
              club: club,
              variant: ClubListTileVariant.avatarChip,
              showLiveBadge: true,
            ),
          ],
        ),
      );

      expect(find.text('Night Pacers'), findsNWidgets(2));
      expect(find.text('Joined'), findsOneWidget);
      expect(find.text('Join'), findsNothing);
      expect(find.text('SOCIAL'), findsOneWidget);
      expect(find.text('INDORE'), findsNothing);
      expect(find.text('NEXT: RACE COURSE ROAD MAIN GATE'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
    });

    testWidgets('ClubListTile labels hosted clubs distinctly from joined', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        ClubListTile(
          club: buildClub(name: 'Host Club'),
          variant: ClubListTileVariant.directory,
          isJoined: true,
          isHost: true,
        ),
      );

      expect(_catchButtonWithLabel('Host'), findsOneWidget);
      expect(find.text('Joined'), findsNothing);
      expect(find.text('Join'), findsNothing);
    });

    testWidgets(
      'MembershipButton renders the correct action and pending state',
      (tester) async {
        await pumpTestApp(
          tester,
          const Column(
            children: [
              MembershipButton(
                clubId: 'club-1',
                isMember: false,
                isMutating: false,
                pushNotificationsEnabled: false,
                isPushMutating: false,
              ),
              MembershipButton(
                clubId: 'club-1',
                isMember: true,
                isMutating: true,
                pushNotificationsEnabled: false,
                isPushMutating: false,
              ),
            ],
          ),
        );

        expect(find.text('Join club'), findsOneWidget);
        expect(
          tester
              .widget<CatchButton>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is CatchButton && widget.label == 'Leave club',
                ),
              )
              .isLoading,
          isTrue,
        );
      },
    );

    testWidgets('MembershipButton join and leave actions hit the repository', (
      tester,
    ) async {
      final fakeRepository = FakeClubsRepository();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          cityListProvider.overrideWith((ref) async => _testCities),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      await container.pump();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: Column(
                children: [
                  MembershipButton(
                    clubId: 'club-join',
                    isMember: false,
                    isMutating: false,
                    pushNotificationsEnabled: false,
                    isPushMutating: false,
                  ),
                  MembershipButton(
                    clubId: 'club-leave',
                    isMember: true,
                    isMutating: false,
                    pushNotificationsEnabled: false,
                    isPushMutating: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.tap(find.text('Join club'));
      await _pumpClubUi(tester);
      await tester.tap(find.text('Leave club'));
      await _pumpClubUi(tester);

      expect(fakeRepository.joinedClubId, 'club-join');
      expect(fakeRepository.leftClubId, 'club-leave');
    });

    testWidgets('HostClubManagementPanel and StatsStrip show computed values', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        Column(
          children: [
            HostClubManagementPanel(
              club: buildClub(name: 'Host Club'),
              events: [
                buildEvent(
                  priceInPaise: 1500,
                  bookedCount: 2,
                  waitlistedCount: 1,
                ),
                buildEvent(priceInPaise: 0, bookedCount: 1),
              ],
              onEditClub: () {},
              onCreateEvent: () {},
            ),
            StatsStrip(
              club: buildClub(memberCount: 24, rating: 4.7),
              upcomingCount: 3,
            ),
          ],
        ),
      );

      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('3'), findsNWidgets(2));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('₹30'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);
    });

    testWidgets('ClubHeroAppBar share button invokes share handler', (
      tester,
    ) async {
      var sharedClubId = '';

      await pumpTestApp(
        tester,
        CustomScrollView(
          slivers: [
            ClubHeroAppBar(
              club: buildClub(name: 'Stride Social'),
              isHost: true,
              onShareClub: (_, club) async {
                sharedClubId = club.id;
              },
            ),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.ios_share_rounded));
      await _pumpClubUi(tester);

      expect(sharedClubId, 'club-1');
    });

    testWidgets(
      'ClubHeroAppBar shows rating and pops back from the detail route',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CustomScrollView(
                            slivers: [
                              ClubHeroAppBar(
                                club: buildClub(
                                  name: 'Rated Club',
                                  rating: 4.8,
                                  imageUrl: 'https://example.com/club.jpg',
                                ),
                                isHost: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: const Text('Open hero'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.tap(find.text('Open hero'));
        await _pumpClubUi(tester);

        expect(find.text('4.8'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await _pumpClubUi(tester);

        expect(find.text('Open hero'), findsOneWidget);
      },
    );

    testWidgets('ClubHeroAppBar uses branded fallback without a cover image', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        CustomScrollView(
          slivers: [
            ClubHeroAppBar(
              club: buildClub(name: 'Morning Miles', imageUrl: null),
              isHost: false,
            ),
          ],
        ),
      );

      expect(find.byType(ClubCoverFallback), findsOneWidget);
      expect(find.text('MM'), findsOneWidget);
      expect(find.text('Mumbai'), findsWidgets);
    });

    testWidgets('ClubListTile variants navigate to detail routes', (
      tester,
    ) async {
      Future<void> pumpVariant(
        ClubListTileVariant variant, {
        bool showLiveBadge = false,
        bool isJoined = false,
      }) async {
        final club = buildClub(
          id: variant.name,
          name: 'Club ${variant.name}',
          imageUrl: 'https://example.com/club.jpg',
        );
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: Center(
                  child: ClubListTile(
                    club: club,
                    variant: variant,
                    showLiveBadge: showLiveBadge,
                    isJoined: isJoined,
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/detail/:clubId',
              name: Routes.clubDetailScreen.name,
              builder: (_, state) => Text(
                'Detail ${state.pathParameters['clubId']}',
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await _pumpClubUi(tester);
        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is ClubListTile &&
                widget.club.id == club.id &&
                widget.variant == variant,
          ),
        );
        await _pumpClubUi(tester);

        expect(find.text('Detail ${club.id}'), findsOneWidget);
      }

      await pumpVariant(ClubListTileVariant.directory, isJoined: true);
      await pumpVariant(ClubListTileVariant.avatarChip, showLiveBadge: true);
    });

    testWidgets('ClubListTile uses club cover fallback when image is absent', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        ClubListTile(
          club: buildClub(name: 'No Cover Club', imageUrl: null),
          variant: ClubListTileVariant.directory,
        ),
      );

      expect(find.byType(ClubCoverFallback), findsOneWidget);
      expect(find.text('NC'), findsOneWidget);
    });

    testWidgets('ClubDetailBody host view exposes edit and create navigation', (
      tester,
    ) async {
      final club = buildClub(id: 'club-host', hostUserId: 'host-1');
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: ClubDetailBody(
                club: club,
                upcoming: [buildEvent(clubId: club.id)],
                reviews: const [],
                userProfile: buildUser(uid: 'host-1'),
                uid: 'host-1',
                isHost: true,
                isMember: true,
                isMutating: false,
                clubPushNotificationsEnabled: false,
                isClubPushMutating: false,
                isAuthenticated: true,
              ),
            ),
          ),
          GoRoute(
            path: '/edit/:clubId',
            name: Routes.editClubScreen.name,
            builder: (_, state) => Text(
              'Edit ${state.pathParameters['clubId']}',
              textDirection: TextDirection.ltr,
            ),
          ),
          GoRoute(
            path: '/create/:clubId',
            name: Routes.createEventScreen.name,
            builder: (_, state) => Text(
              'Create ${state.pathParameters['clubId']}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
      await _pumpClubUi(tester);

      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('Join club'), findsNothing);
      expect(find.text('Leave club'), findsNothing);
      expect(find.text('HOST TOOLS'), findsOneWidget);
      expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);
      expect(find.text('Share'), findsNothing);
      expect(find.text('Edit club'), findsOneWidget);
      expect(find.text('Add event'), findsOneWidget);

      await tester.tap(find.text('Edit club'));
      await _pumpClubUi(tester);

      expect(find.text('Edit club-host'), findsOneWidget);

      router.go('/');
      await _pumpClubUi(tester);

      await tester.tap(find.text('Add event'));
      await _pumpClubUi(tester);

      expect(find.text('Create club-host'), findsOneWidget);
    });

    testWidgets('ClubDetailBody shows host identity and opens host profile', (
      tester,
    ) async {
      final club = buildClub(
        id: 'club-host-profile',
        area: 'Bandra',
        hostUserId: 'host-42',
        hostName: 'Asha Shah',
      );
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: ClubDetailBody(
                club: club,
                upcoming: const [],
                reviews: const [],
                userProfile: buildUser(uid: 'runner-1'),
                uid: 'runner-1',
                isHost: false,
                isMember: false,
                isMutating: false,
                clubPushNotificationsEnabled: false,
                isClubPushMutating: false,
                isAuthenticated: true,
              ),
            ),
          ),
          GoRoute(
            path: '/profiles/:uid',
            name: Routes.publicProfileScreen.name,
            builder: (_, state) => Text(
              'Profile ${state.pathParameters['uid']}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.text('HOST'), findsOneWidget);
      expect(find.text('Asha Shah'), findsOneWidget);
      expect(find.text('Club host'), findsOneWidget);
      expect(find.text('Hosts events in Bandra'), findsOneWidget);

      await tester.tap(find.text('Asha Shah'));
      await _pumpClubUi(tester);

      expect(find.text('Profile host-42'), findsOneWidget);
    });

    testWidgets(
      'ClubDetailBody keeps club review aggregate read-only below schedule',
      (tester) async {
        final club = buildClub(id: 'club-reviews');
        final reviews = [
          buildReview(id: 'review-1', comment: 'Most recent.'),
          buildReview(id: 'review-2', comment: 'Second recent.'),
          buildReview(id: 'review-3', comment: 'Third recent.'),
          buildReview(id: 'review-4', comment: 'Fourth hidden.'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: ClubDetailBody(
                club: club,
                upcoming: const [],
                reviews: reviews,
                userProfile: buildUser(uid: 'runner-1'),
                uid: 'runner-1',
                isHost: false,
                isMember: true,
                isMutating: false,
                clubPushNotificationsEnabled: false,
                isClubPushMutating: false,
                isAuthenticated: true,
              ),
            ),
          ),
        );
        await _pumpClubUi(tester);

        final scrollView = tester.widget<CustomScrollView>(
          find.byType(CustomScrollView),
        );
        expect(scrollView.slivers[2], isA<ClubScheduleSection>());
        expect(scrollView.slivers[3], isA<SliverPadding>());

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
        await _pumpClubUi(tester);

        expect(find.text('Reviews'), findsOneWidget);
        expect(find.text('Most recent.'), findsOneWidget);
        expect(find.text('Second recent.'), findsOneWidget);
        expect(find.text('Third recent.'), findsOneWidget);
        expect(find.text('Fourth hidden.'), findsNothing);
        expect(find.text('Write a review'), findsNothing);
        expect(find.text('Edit your review'), findsNothing);
      },
    );

    testWidgets('ClubDetailBody agenda taps navigate to the selected event', (
      tester,
    ) async {
      final club = buildClub(id: 'club-schedule');
      final today = DateTime.now();
      final event = buildEvent(
        id: 'event-42',
        clubId: club.id,
        startTime: DateTime(today.year, today.month, today.day, 8),
        endTime: DateTime(today.year, today.month, today.day, 9),
      );
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: ClubDetailBody(
                club: club,
                upcoming: [event],
                reviews: const [],
                userProfile: buildUser(uid: 'runner-1'),
                uid: 'runner-1',
                isHost: false,
                isMember: true,
                isMutating: false,
                clubPushNotificationsEnabled: false,
                isClubPushMutating: false,
                isAuthenticated: true,
              ),
            ),
          ),
          GoRoute(
            path: '/events/:clubId/:eventId',
            name: Routes.eventDetailScreen.name,
            builder: (_, state) => Text(
              'Event ${state.pathParameters['eventId']}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
      await _pumpClubUi(tester);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await _pumpClubUi(tester);

      await tester.tap(find.text('Start'));
      await _pumpClubUi(tester);

      expect(find.text('Event event-42'), findsOneWidget);
    });

    testWidgets('ClubsListScreen follow button uses the repository', (
      tester,
    ) async {
      final fakeRepository = FakeClubsRepository();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
          ),
          watchActiveClubMembershipsForUserProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value(const [])),
          watchClubsByLocationProvider(
            buildClub().location,
          ).overrideWith((ref) => Stream.value([buildClub(id: 'club-99')])),
        ],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      await container.pump();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubsListScreen(),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.tap(find.text('Join'));
      await _pumpClubUi(tester);

      expect(fakeRepository.joinedClubId, 'club-99');
    });

    testWidgets('ClubsListScreen shows skeleton cards while loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value(const [])),
            clubsListViewModelProvider.overrideWithValue(const AsyncLoading()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubsListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CatchSkeleton), findsNWidgets(3));
      expect(find.byType(CatchTextField), findsNothing);
    });

    testWidgets(
      'ClubsListScreen hides search when the selected city is empty',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cityListProvider.overrideWith((ref) async => _testCities),
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
              watchClubsByLocationProvider(
                'mumbai',
              ).overrideWith((ref) => Stream.value(const [])),
              clubsListViewModelProvider.overrideWithValue(
                const AsyncData(
                  ClubsListViewModel(joinedClubs: [], allClubs: []),
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ClubsListScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Mumbai'), findsOneWidget);
        expect(find.byType(CatchTextField), findsNothing);
        expect(find.text('No clubs in this city yet'), findsOneWidget);
      },
    );

    testWidgets('ClubsListScreen shows a readable error message', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value(const [])),
            clubsListViewModelProvider.overrideWithValue(
              AsyncError(StateError('boom'), StackTrace.empty),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubsListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('boom'), findsOneWidget);
    });

    testWidgets('ClubsListScreen listens for follow mutation errors', (
      tester,
    ) async {
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          cityListProvider.overrideWith((ref) async => _testCities),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          watchClubsByLocationProvider(
            'mumbai',
          ).overrideWith((ref) => Stream.value([buildClub(id: 'club-err')])),
          clubsListViewModelProvider.overrideWithValue(
            AsyncData(
              ClubsListViewModel(
                joinedClubs: const [],
                allClubs: [buildClub(id: 'club-err')],
              ),
            ),
          ),
          uidProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubsListScreen(),
          ),
        ),
      );
      await tester.pump();

      try {
        await ClubMembershipController.joinMutation.run(container, (tx) async {
          throw StateError('join failed');
        });
      } catch (_) {}
      await _pumpClubUi(tester);

      expect(find.textContaining('join failed'), findsOneWidget);
    });

    testWidgets(
      'ClubDetailScreen uses initialClub while live data is still loading',
      (tester) async {
        final club = buildClub(name: 'Initial Club');
        final controller = StreamController<Club?>.broadcast();
        addTearDown(controller.close);

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
              uidProvider.overrideWith((ref) => Stream.value('runner-1')),
              watchUserProfileProvider.overrideWith(
                (ref) => Stream.value(buildUser(uid: 'runner-1')),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: ClubDetailScreen(clubId: club.id, initialClub: club),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Initial Club'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('ClubDetailScreen shows detail-provider errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clubDetailViewModelProvider('club-err').overrideWithValue(
              AsyncError(StateError('detail failed'), StackTrace.empty),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubDetailScreen(clubId: 'club-err'),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('detail failed'), findsOneWidget);
    });

    testWidgets('ClubDetailScreen shows a not-found state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clubDetailViewModelProvider(
              'club-missing',
            ).overrideWithValue(const AsyncData(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubDetailScreen(clubId: 'club-missing'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Club not found'), findsOneWidget);
      expect(find.text('This club is no longer available.'), findsOneWidget);
    });

    testWidgets('ClubDetailScreen listens for join mutation errors', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          clubDetailViewModelProvider('club-1').overrideWithValue(
            AsyncData(
              ClubDetailViewModel(
                club: buildClub(),
                isHost: false,
                isMember: false,
                upcomingEvents: const [],
                reviews: const [],
                userProfile: buildUser(uid: 'runner-1'),
                uid: 'runner-1',
                isAuthenticated: true,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubDetailScreen(clubId: 'club-1'),
          ),
        ),
      );
      await tester.pump();

      try {
        await ClubMembershipController.joinMutation.run(container, (tx) async {
          throw StateError('join failed');
        });
      } catch (_) {}
      await tester.pump();

      expect(find.textContaining('join failed'), findsOneWidget);
      ClubMembershipController.joinMutation.reset(container);
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      container.dispose();
      await _pumpClubUi(tester);
    });

    testWidgets('ClubDetailScreen listens for leave mutation errors', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          clubDetailViewModelProvider('club-1').overrideWithValue(
            AsyncData(
              ClubDetailViewModel(
                club: buildClub(),
                isHost: false,
                isMember: true,
                upcomingEvents: const [],
                reviews: const [],
                userProfile: buildUser(uid: 'runner-1'),
                uid: 'runner-1',
                isAuthenticated: true,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubDetailScreen(clubId: 'club-1'),
          ),
        ),
      );
      await tester.pump();

      try {
        await ClubMembershipController.leaveMutation.run(container, (tx) async {
          throw StateError('leave failed');
        });
      } catch (_) {}
      await tester.pump();

      expect(find.textContaining('leave failed'), findsOneWidget);
      ClubMembershipController.leaveMutation.reset(container);
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      container.dispose();
      await _pumpClubUi(tester);
    });

    testWidgets('CreateClubScreen picks and previews a cover image', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      const transparentPixel =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==';
      final fakeImageUploadRepository = FakeImageUploadRepository(
        pickedImage: XFile.fromData(
          base64Decode(transparentPixel),
          name: 'club-cover-test.png',
          mimeType: 'image/png',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            imageUploadRepositoryProvider.overrideWith(
              (ref) => fakeImageUploadRepository,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateClubScreen(),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.tap(find.text('Add cover photo'));
      await _pumpClubUi(tester);

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('CreateClubScreen shows mutation errors inline', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateClubScreen(),
          ),
        ),
      );
      await tester.pump();

      try {
        await CreateClubController.submitMutation.run(container, (tx) async {
          throw StateError('create failed');
        });
      } catch (_) {}
      await _pumpClubUi(tester);

      expect(find.textContaining('create failed'), findsOneWidget);
    });

    testWidgets('CreateClubScreen pre-fills fields in edit mode', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final club = buildClub(
        name: 'Morning Miles',
        area: 'Palasia',
        location: 'indore',
        description: 'Indore morning loops.',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: CreateClubScreen(initialClub: club),
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.text('Edit club'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Morning Miles'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Palasia'), findsOneWidget);
      expect(find.text('Indore'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await _pumpClubUi(tester);

      expect(find.text('Save changes'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Indore morning loops.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'CreateClubScreen validates and pops after a successful submit',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final fakeRepository = FakeClubsRepository();
        final fakeImageUploadRepository = FakeImageUploadRepository(
          pickedImage: XFile('/tmp/club-cover.jpg'),
        );
        final container = ProviderContainer(
          overrides: [
            clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
            imageUploadRepositoryProvider.overrideWith(
              (ref) => fakeImageUploadRepository,
            ),
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
            watchUserProfileProvider.overrideWith(
              (ref) => Stream.value(buildUser(uid: 'host-1', name: 'Priya')),
            ),
          ],
        );
        addTearDown(container.dispose);
        final uidSubscription = container.listen(
          uidProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(uidSubscription.close);
        final userProfileSubscription = container.listen(
          watchUserProfileProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(userProfileSubscription.close);
        await container.pump();
        await container.pump();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CreateClubScreen(),
                        ),
                      ),
                      child: const Text('Open create screen'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open create screen'));
        await _pumpClubUi(tester);

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);

        expect(find.text('Please enter a club name'), findsOneWidget);
        expect(find.text('Please select a city'), findsOneWidget);
        expect(find.text('Please enter an area'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(CatchTextField, 'Club name'),
          'Sunset Striders',
        );
        await tester.enterText(
          find.widgetWithText(CatchTextField, 'Area / neighbourhood'),
          'Bandra',
        );

        tester.testTextInput.hide();
        await tester.pump();
        final cityDropdownIcon = find.byIcon(Icons.expand_more_rounded);
        await tester.ensureVisible(cityDropdownIcon);
        await tester.tap(cityDropdownIcon);
        await _pumpClubUi(tester);
        await tester.tap(find.text('Mumbai').hitTestable());
        await _pumpClubUi(tester);

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);

        await tester.tap(find.text('Create club'));
        await _pumpClubUi(tester);

        expect(find.text('Please add a description'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(CatchTextField, 'Description'),
          'Easy social club',
        );
        tester.testTextInput.hide();
        await tester.pump();

        await tester.tap(find.text('Create club'));
        await _pumpClubUi(tester);

        expect(find.text('Open create screen'), findsOneWidget);
        expect(fakeRepository.lastCreateCall, isNotNull);
        expect(fakeRepository.lastCreateCall!.name, 'Sunset Striders');
      },
    );
  });
}

Finder _catchButtonWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CatchButton && widget.label == label,
  );
}
