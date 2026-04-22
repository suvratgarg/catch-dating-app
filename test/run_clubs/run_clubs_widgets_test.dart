import 'dart:async';
import 'dart:convert';

import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/create_run_club_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/create_run_club_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_club_detail_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_club_detail_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_clubs_list_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_clubs_list_screen.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_clubs_list_state.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/club_detail_body.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/horizontal_club_section.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/host_stats_bar.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/membership_button.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/nearby_clubs_section.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/run_club_list_tile.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/run_clubs_content.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/run_clubs_header.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/stats_strip.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_schedule_grid.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'run_clubs_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Run clubs widgets', () {
    testWidgets(
      'RunClubsContent shows the empty state when there are no clubs',
      (tester) async {
        await pumpTestApp(
          tester,
          const RunClubsContent(
            viewModel: RunClubsListViewModel(
              joinedClubs: [],
              discoverClubs: [],
            ),
            isFollowPending: false,
          ),
        );

        expect(find.text('No run clubs in this city yet'), findsOneWidget);
        expect(find.text('Be the first to create one!'), findsOneWidget);
      },
    );

    testWidgets('RunClubsContent renders joined and discover sections', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        RunClubsContent(
          viewModel: RunClubsListViewModel(
            joinedClubs: [
              buildRunClub(id: 'joined-1', nextRunLabel: 'Sat 6:30 AM'),
            ],
            discoverClubs: [buildRunClub(id: 'discover-1')],
          ),
          isFollowPending: false,
        ),
      );

      expect(find.text('Your clubs'), findsOneWidget);
      expect(find.text('For you'), findsOneWidget);
      expect(find.text('Nearby'), findsOneWidget);
    });

    testWidgets(
      'RunClubsHeader updates search query and clears it when the city changes',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: const Scaffold(body: RunClubsHeader()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'asha');
        await tester.pump();

        expect(container.read(runClubSearchQueryProvider), 'asha');

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump();

        expect(container.read(runClubSearchQueryProvider), isEmpty);

        await tester.enterText(find.byType(TextField), 'asha');
        await tester.pump();

        await tester.tap(find.text('Mumbai'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delhi').last);
        await tester.pumpAndSettle();

        expect(container.read(selectedRunClubCityProvider), IndianCity.delhi);
        expect(container.read(runClubSearchQueryProvider), isEmpty);

        final searchField = tester.widget<TextField>(find.byType(TextField));
        expect(searchField.controller!.text, isEmpty);
      },
    );

    testWidgets('RunClubsHeader add button navigates to create run club', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: RunClubsHeader()),
          ),
          GoRoute(
            path: '/create-run-club',
            name: Routes.createRunClubScreen.name,
            builder: (_, _) =>
                const Text('Create run club', textDirection: TextDirection.ltr),
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
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Create run club'), findsOneWidget);
    });

    testWidgets('row tile follow button is tappable and accessible', (
      tester,
    ) async {
      var didFollow = false;

      await pumpTestApp(
        tester,
        RunClubListTile(club: buildRunClub(), onFollow: () => didFollow = true),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Follow'));
      await tester.pump();

      expect(didFollow, isTrue);
    });

    testWidgets('row tile joined state uses the default next-run copy', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        RunClubListTile(club: buildRunClub(nextRunLabel: null), isJoined: true),
      );

      expect(find.text('Next run coming up'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Joined'), findsOneWidget);
    });

    testWidgets('directory and avatar chip variants render club metadata', (
      tester,
    ) async {
      final club = buildRunClub(name: 'Night Pacers', rating: 4.8);

      await pumpTestApp(
        tester,
        Column(
          children: [
            Expanded(
              child: RunClubListTile(
                club: club,
                variant: RunClubListTileVariant.directory,
                isJoined: true,
              ),
            ),
            RunClubListTile(
              club: club,
              variant: RunClubListTileVariant.avatarChip,
              isActive: true,
            ),
          ],
        ),
      );

      expect(find.text('Night Pacers'), findsNWidgets(2));
      expect(find.text('JOINED'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
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
              ),
              MembershipButton(
                clubId: 'club-1',
                isMember: true,
                isMutating: true,
              ),
            ],
          ),
        );

        expect(find.text('Join club'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('MembershipButton join and leave actions hit the repository', (
      tester,
    ) async {
      final fakeRepository = FakeRunClubsRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
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
                  ),
                  MembershipButton(
                    clubId: 'club-leave',
                    isMember: true,
                    isMutating: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join club'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave club'));
      await tester.pumpAndSettle();

      expect(fakeRepository.joinedClubId, 'club-join');
      expect(fakeRepository.joinedUserId, 'runner-1');
      expect(fakeRepository.leftClubId, 'club-leave');
      expect(fakeRepository.leftUserId, 'runner-1');
    });

    testWidgets('HostStatsBar and StatsStrip show computed values', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        Column(
          children: [
            HostStatsBar(
              runs: [
                buildRun(
                  priceInPaise: 1500,
                  signedUpUserIds: const ['a', 'b'],
                  waitlistUserIds: const ['c'],
                ),
                buildRun(priceInPaise: 0, signedUpUserIds: const ['d']),
              ],
            ),
            StatsStrip(
              club: buildRunClub(memberCount: 24, rating: 4.7),
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

    testWidgets('ClubHeroAppBar share button shows feedback', (tester) async {
      await pumpTestApp(
        tester,
        CustomScrollView(
          slivers: [
            ClubHeroAppBar(
              club: buildRunClub(name: 'Stride Social'),
              isHost: true,
            ),
          ],
        ),
      );

      await tester.tap(find.byIcon(Icons.ios_share_rounded));
      await tester.pumpAndSettle();

      expect(
        find.text('Sharing for run clubs is coming soon.'),
        findsOneWidget,
      );
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
                                club: buildRunClub(
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
        await tester.pumpAndSettle();

        expect(find.text('4.8'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Open hero'), findsOneWidget);
      },
    );

    testWidgets(
      'Horizontal and nearby sections render separators for multiple clubs',
      (tester) async {
        await pumpTestApp(
          tester,
          Column(
            children: [
              HorizontalClubSection(
                title: 'Your clubs',
                height: 220,
                clubs: [
                  buildRunClub(id: 'a'),
                  buildRunClub(id: 'b'),
                ],
                variant: RunClubListTileVariant.scrollCard,
                isJoined: true,
              ),
              NearbyClubsSection(
                clubs: [
                  buildRunClub(id: 'c'),
                  buildRunClub(id: 'd'),
                ],
                isFollowPending: false,
              ),
            ],
          ),
        );

        expect(
          find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == 10,
          ),
          findsWidgets,
        );
        expect(find.byType(Divider), findsOneWidget);
      },
    );

    testWidgets('RunClubListTile variants navigate to detail routes', (
      tester,
    ) async {
      Future<void> pumpVariant(
        RunClubListTileVariant variant, {
        bool isActive = false,
        bool isJoined = false,
      }) async {
        final club = buildRunClub(
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
                  child: RunClubListTile(
                    club: club,
                    variant: variant,
                    isActive: isActive,
                    isJoined: isJoined,
                  ),
                ),
              ),
            ),
            GoRoute(
              path: '/detail/:runClubId',
              name: Routes.runClubDetailScreen.name,
              builder: (_, state) => Text(
                'Detail ${state.pathParameters['runClubId']}',
                textDirection: TextDirection.ltr,
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(club.name).first);
        await tester.pumpAndSettle();

        expect(find.text('Detail ${club.id}'), findsOneWidget);
      }

      await pumpVariant(RunClubListTileVariant.rowTile);
      await pumpVariant(RunClubListTileVariant.scrollCard, isJoined: true);
      await pumpVariant(RunClubListTileVariant.directory, isJoined: true);
      await pumpVariant(RunClubListTileVariant.avatarChip, isActive: true);
    });

    testWidgets('ClubDetailBody host view exposes create run navigation', (
      tester,
    ) async {
      final club = buildRunClub(id: 'club-host', hostUserId: 'host-1');
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: ClubDetailBody(
                runClub: club,
                runs: const [],
                upcoming: [buildRun(runClubId: club.id)],
                reviews: const [],
                appUser: buildUser(uid: 'host-1'),
                uid: 'host-1',
                isHost: true,
                isMember: true,
                isMutating: false,
              ),
            ),
          ),
          GoRoute(
            path: '/create/:runClubId',
            name: Routes.createRunScreen.name,
            builder: (_, state) => Text(
              'Create ${state.pathParameters['runClubId']}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
      await tester.pumpAndSettle();

      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('Join club'), findsNothing);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Create club-host'), findsOneWidget);
    });

    testWidgets('ClubDetailBody schedule taps navigate to the selected run', (
      tester,
    ) async {
      final club = buildRunClub(id: 'club-schedule');
      final run = buildRun(
        id: 'run-42',
        runClubId: club.id,
        startTime: DateTime.now().add(const Duration(hours: 2)),
      );
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: ClubDetailBody(
                runClub: club,
                runs: [run],
                upcoming: [run],
                reviews: const [],
                appUser: buildUser(uid: 'runner-1'),
                uid: 'runner-1',
                isHost: false,
                isMember: true,
                isMutating: false,
              ),
            ),
          ),
          GoRoute(
            path: '/runs/:runClubId/:runId',
            name: Routes.runDetailScreen.name,
            builder: (_, state) => Text(
              'Run ${state.pathParameters['runId']}',
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();

      final scheduleGrid = tester.widget<RunScheduleGrid>(
        find.byType(RunScheduleGrid),
      );
      scheduleGrid.onRunSelected!(run);
      await tester.pumpAndSettle();

      expect(find.text('Run run-42'), findsOneWidget);
    });

    testWidgets('RunClubsListScreen follow button uses the repository', (
      tester,
    ) async {
      final fakeRepository = FakeRunClubsRepository();
      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          appUserStreamProvider.overrideWith(
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
          ),
          watchRunClubsByLocationProvider(
            buildRunClub().location,
          ).overrideWith((ref) => Stream.value([buildRunClub(id: 'club-99')])),
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
            home: const RunClubsListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Follow'));
      await tester.pumpAndSettle();

      expect(fakeRepository.joinedClubId, 'club-99');
      expect(fakeRepository.joinedUserId, 'runner-1');
    });

    testWidgets('RunClubsListScreen shows a spinner while loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            runClubsListViewModelProvider.overrideWithValue(
              const AsyncLoading(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const RunClubsListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('RunClubsListScreen shows a readable error message', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            runClubsListViewModelProvider.overrideWithValue(
              AsyncError(StateError('boom'), StackTrace.empty),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const RunClubsListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Error loading clubs:'), findsOneWidget);
      expect(find.textContaining('boom'), findsOneWidget);
    });

    testWidgets('RunClubsListScreen listens for follow mutation errors', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          runClubsListViewModelProvider.overrideWithValue(
            AsyncData(
              RunClubsListViewModel(
                joinedClubs: const [],
                discoverClubs: [buildRunClub(id: 'club-err')],
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const RunClubsListScreen(),
          ),
        ),
      );
      await tester.pump();

      try {
        await RunClubsListController.followMutation.run(container, (tx) async {
          throw StateError('follow failed');
        });
      } catch (_) {}
      await tester.pumpAndSettle();

      expect(find.textContaining('follow failed'), findsOneWidget);
    });

    testWidgets(
      'RunClubDetailScreen uses initialRunClub while live data is still loading',
      (tester) async {
        final club = buildRunClub(name: 'Initial Club');
        final controller = StreamController<RunClub?>.broadcast();
        addTearDown(controller.close);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              watchRunClubProvider(
                club.id,
              ).overrideWith((ref) => controller.stream),
              runsForClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(const <Run>[])),
              watchReviewsForClubProvider(
                club.id,
              ).overrideWith((ref) => Stream.value(const <Review>[])),
              uidProvider.overrideWith((ref) => Stream.value('runner-1')),
              appUserStreamProvider.overrideWith(
                (ref) => Stream.value(buildUser(uid: 'runner-1')),
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
        await tester.pump();

        expect(find.text('Initial Club'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets('RunClubDetailScreen shows detail-provider errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            runClubDetailViewModelProvider('club-err').overrideWithValue(
              AsyncError(StateError('detail failed'), StackTrace.empty),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const RunClubDetailScreen(runClubId: 'club-err'),
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('detail failed'), findsOneWidget);
    });

    testWidgets('RunClubDetailScreen shows a not-found state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            runClubDetailViewModelProvider(
              'club-missing',
            ).overrideWithValue(const AsyncData(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const RunClubDetailScreen(runClubId: 'club-missing'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Run club not found.'), findsOneWidget);
    });

    testWidgets('RunClubDetailScreen listens for join mutation errors', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          runClubDetailViewModelProvider('club-1').overrideWithValue(
            AsyncData(
              RunClubDetailViewModel(
                runClub: buildRunClub(),
                isHost: false,
                isMember: false,
                upcomingRuns: const [],
                allRuns: const [],
                reviews: const [],
                appUser: buildUser(uid: 'runner-1'),
                uid: 'runner-1',
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
            home: const RunClubDetailScreen(runClubId: 'club-1'),
          ),
        ),
      );
      await tester.pump();

      try {
        await RunClubDetailController.joinMutation.run(container, (tx) async {
          throw StateError('join failed');
        });
      } catch (_) {}
      await tester.pump();

      expect(find.textContaining('join failed'), findsOneWidget);
      RunClubDetailController.joinMutation.reset(container);
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      container.dispose();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('RunClubDetailScreen listens for leave mutation errors', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          runClubDetailViewModelProvider('club-1').overrideWithValue(
            AsyncData(
              RunClubDetailViewModel(
                runClub: buildRunClub(),
                isHost: false,
                isMember: true,
                upcomingRuns: const [],
                allRuns: const [],
                reviews: const [],
                appUser: buildUser(uid: 'runner-1'),
                uid: 'runner-1',
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
            home: const RunClubDetailScreen(runClubId: 'club-1'),
          ),
        ),
      );
      await tester.pump();

      try {
        await RunClubDetailController.leaveMutation.run(container, (tx) async {
          throw StateError('leave failed');
        });
      } catch (_) {}
      await tester.pump();

      expect(find.textContaining('leave failed'), findsOneWidget);
      RunClubDetailController.leaveMutation.reset(container);
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      container.dispose();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('CreateRunClubScreen picks and previews a cover image', (
      tester,
    ) async {
      const transparentPixel =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==';
      final fakeImageUploadRepository = FakeImageUploadRepository(
        pickedImage: XFile.fromData(
          base64Decode(transparentPixel),
          name: 'run-club-cover-test.png',
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
            home: const CreateRunClubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add cover photo'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('CreateRunClubScreen shows mutation errors inline', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateRunClubScreen(),
          ),
        ),
      );
      await tester.pump();

      try {
        await CreateRunClubController.submitMutation.run(container, (tx) async {
          throw StateError('create failed');
        });
      } catch (_) {}
      await tester.pumpAndSettle();

      expect(find.textContaining('create failed'), findsOneWidget);
    });

    testWidgets(
      'CreateRunClubScreen validates and pops after a successful submit',
      (tester) async {
        final fakeRepository = FakeRunClubsRepository();
        final fakeImageUploadRepository = FakeImageUploadRepository(
          pickedImage: XFile('/tmp/club-cover.jpg'),
        );
        final container = ProviderContainer(
          overrides: [
            runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
            imageUploadRepositoryProvider.overrideWith(
              (ref) => fakeImageUploadRepository,
            ),
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
            appUserStreamProvider.overrideWith(
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
        final appUserSubscription = container.listen(
          appUserStreamProvider,
          (_, _) {},
          fireImmediately: true,
        );
        addTearDown(appUserSubscription.close);
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
                          builder: (_) => const CreateRunClubScreen(),
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
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Create club'));
        await tester.tap(find.text('Create club'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a club name'), findsOneWidget);
        expect(find.text('Please select a city'), findsOneWidget);
        expect(find.text('Please enter an area'), findsOneWidget);
        expect(find.text('Please add a description'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Club name'),
          'Sunset Striders',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Area / neighbourhood'),
          'Bandra',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Description'),
          'Easy social club',
        );

        await tester.tap(
          find.byWidgetPredicate((widget) => widget is DropdownButtonFormField),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mumbai').last);
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Create club'));
        await tester.tap(find.text('Create club'));
        await tester.pumpAndSettle();

        expect(find.text('Open create screen'), findsOneWidget);
        expect(fakeRepository.lastCreateCall, isNotNull);
        expect(fakeRepository.lastCreateCall!.name, 'Sunset Striders');
      },
    );
  });
}
