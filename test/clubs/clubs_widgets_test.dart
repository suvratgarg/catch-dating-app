import 'dart:async';
import 'dart:convert';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
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
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/city_picker.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_list_tile.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_filter_rail.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list_body.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_sliver_header.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_event_type_browse_grid.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_events_section.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_peek_rail.dart';
import 'package:catch_dating_app/clubs/presentation/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_transition_tags.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/device_motion.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_draggable_sheet_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_viewport_curve_frame.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
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

import '../events/events_test_helpers.dart' as event_test;
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

final _emptyExploreFeedOverride = exploreFeedViewModelProvider
    .overrideWithValue(const AsyncData(ExploreFeedViewModel(items: [])));

class _NoDeviceLocation extends DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async => null;
}

class _FakeDeviceMotionSource implements DeviceMotionSource {
  final _controller = StreamController<DeviceMotionSample>.broadcast();

  @override
  Stream<DeviceMotionSample> watchMotion() => _controller.stream;

  void add(DeviceMotionSample sample) => _controller.add(sample);

  Future<void> dispose() => _controller.close();
}

Future<void> _pumpClubsSlivers(
  WidgetTester tester,
  List<Widget> slivers,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(null)),
        _emptyExploreFeedOverride,
      ],
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

Finder _exploreListScrollable() {
  return find.descendant(
    of: find.byKey(const ValueKey('explore-list-scroll-view')),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    ),
  );
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
            _emptyExploreFeedOverride,
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

      expect(find.text('No clubs in Mumbai yet'), findsOneWidget);
      expect(
        find.text(
          'Try another city from the location control, or create the first '
          'club when you are ready to host.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('ClubsList shows search-specific empty copy', (tester) async {
      final sourceClub = buildClub(id: 'source-club', name: 'Bandra Pacers');
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          watchClubsByLocationProvider(
            'mumbai',
          ).overrideWith((ref) => Stream.value([sourceClub])),
          clubsListViewModelProvider.overrideWithValue(
            const AsyncData(ClubsListViewModel(joinedClubs: [], allClubs: [])),
          ),
          _emptyExploreFeedOverride,
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

      expect(find.text('No clubs match this search'), findsOneWidget);
      expect(
        find.text('Try another club, neighborhood, host, or tag.'),
        findsOneWidget,
      );
      expect(find.text('Clear search'), findsOneWidget);
      expect(find.text('No clubs in Mumbai yet'), findsNothing);

      await tester.tap(find.text('Clear search'));
      await tester.pump();

      expect(container.read(clubSearchQueryProvider), isEmpty);
    });

    testWidgets('ClubsList shows filter-specific empty copy', (tester) async {
      final sourceClub = buildClub(id: 'source-club', name: 'Bandra Pacers');
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          watchClubsByLocationProvider(
            'mumbai',
          ).overrideWith((ref) => Stream.value([sourceClub])),
          clubsListViewModelProvider.overrideWithValue(
            const AsyncData(ClubsListViewModel(joinedClubs: [], allClubs: [])),
          ),
          _emptyExploreFeedOverride,
        ],
      );
      addTearDown(container.dispose);
      container.read(clubBrowseFiltersProvider.notifier).toggleHighRatedOnly();

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

      expect(find.text('No clubs match these filters'), findsOneWidget);
      expect(
        find.text(
          'Clear one or more filters to bring nearby clubs back into view.',
        ),
        findsOneWidget,
      );
      expect(find.text('Clear filters'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pump();

      expect(container.read(clubBrowseFiltersProvider).hasActiveFilters, false);
    });

    testWidgets(
      'ClubsContent renders personal rail and mixed discovery cards',
      (tester) async {
        await _pumpClubsSlivers(tester, [
          ClubsListBody(
            includeClubDirectory: false,
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
        expect(find.text('Club directory'), findsNothing);
        expect(find.text('You host'), findsNothing);
      },
    );

    testWidgets('ExploreEventsSection renders event-first content', (
      tester,
    ) async {
      final club = buildClub(
        id: 'club-event',
        name: 'Pace Social',
        area: 'Necklace Road',
      );
      final event = event_test.buildEvent(
        id: 'event-upcoming',
        clubId: club.id,
        meetingPoint: 'People Plaza',
        bookedCount: 8,
        capacityLimit: 12,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreFeedViewModelProvider.overrideWithValue(
              AsyncData(
                ExploreFeedViewModel(
                  items: [
                    ExploreEventItem(
                      event: event,
                      club: club,
                      availability: resolveViewerEventAvailability(
                        event: event,
                        userProfile: null,
                      ),
                      status: EventTileStatus.open,
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: CustomScrollView(slivers: [ExploreEventsSection()]),
            ),
          ),
        ),
      );
      await tester.pump();

      // Sparse markets should keep the regular Explore feed and skip the
      // weekly strip until there are enough day-level picks to justify it.
      expect(find.text('This week'), findsNothing);
      expect(find.textContaining('COMING UP'), findsNothing);
      expect(find.textContaining(event.title), findsWidgets);
      expect(find.textContaining('Pace Social'), findsWidgets);
      expect(find.text('8 going · 4 spots left'), findsOneWidget);
      expect(find.textContaining('5km'), findsOneWidget);
    });

    testWidgets('Explore club card and detail hero share media padding', (
      tester,
    ) async {
      final club = buildClub(
        id: 'club-padding',
        name: 'Padding Pacers',
        imageUrl: 'https://example.com/club.jpg',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreFeedViewModelProvider.overrideWithValue(
              const AsyncData(ExploreFeedViewModel(items: [])),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) => MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: CustomScrollView(
                  slivers: buildExploreEventsSlivers(
                    ref,
                    pinnedDayHeaders: false,
                    candidateClubs: [club],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final cardPadding = tester.widget<Padding>(
        find.byKey(const ValueKey('explore-club-polaroid-padding')),
      );
      expect(cardPadding.padding, clubInteractionMediaPadding);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [ClubHeroAppBar(club: club, isHost: false)],
            ),
          ),
        ),
      );
      await _pumpClubUi(tester);

      final detailPadding = tester.widget<Padding>(
        find.byKey(const ValueKey('club-detail-hero-padding')),
      );
      expect(detailPadding.padding, cardPadding.padding);
      final curveFrame = tester.widget<CatchViewportCurveFrame>(
        find.byKey(const ValueKey('club-detail-viewport-curve-frame')),
      );
      expect(curveFrame.padding, clubInteractionMediaPadding);
    });

    testWidgets(
      'ExploreEventsSection shows enough top recommendations by day',
      (tester) async {
        final club = buildClub(
          id: 'club-week',
          name: 'Weekenders',
          area: 'Indiranagar',
        );
        final today = DateUtils.dateOnly(DateTime.now());
        final dinner = event_test.buildEvent(
          id: 'event-week-dinner',
          clubId: club.id,
          startTime: today.add(const Duration(days: 1, hours: 19)),
          meetingPoint: 'Long table room',
          eventFormat: EventFormatSnapshot.custom(
            label: 'long table',
            interactionModel: EventInteractionModel.seatedTable,
          ),
        );
        final run = event_test.buildEvent(
          id: 'event-week-run',
          clubId: club.id,
          startTime: today.add(const Duration(days: 2, hours: 6)),
          meetingPoint: 'Cubbon Park',
        );
        final art = event_test.buildEvent(
          id: 'event-week-art',
          clubId: club.id,
          startTime: today.add(const Duration(days: 3, hours: 16)),
          meetingPoint: 'NGMA',
          eventFormat: EventFormatSnapshot.custom(
            label: 'sketching strangers',
            interactionModel: EventInteractionModel.openFormat,
          ),
        );
        final brunch = event_test.buildEvent(
          id: 'event-week-brunch',
          clubId: club.id,
          startTime: today.add(const Duration(days: 4, hours: 11)),
          meetingPoint: 'Koramangala',
          eventFormat: EventFormatSnapshot.fromActivityKind(
            ActivityKind.dinner,
          ),
        );
        final pickleball = event_test.buildEvent(
          id: 'event-week-pickleball',
          clubId: club.id,
          startTime: today.add(const Duration(days: 5, hours: 18)),
          meetingPoint: 'Court 2',
          eventFormat: EventFormatSnapshot.fromActivityKind(
            ActivityKind.pickleball,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              exploreFeedViewModelProvider.overrideWithValue(
                AsyncData(
                  ExploreFeedViewModel(
                    items: [
                      for (final event in [
                        dinner,
                        run,
                        art,
                        brunch,
                        pickleball,
                      ])
                        ExploreEventItem(
                          event: event,
                          club: club,
                          availability: resolveViewerEventAvailability(
                            event: event,
                            userProfile: null,
                          ),
                          status: EventTileStatus.open,
                        ),
                    ],
                  ),
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const Scaffold(
                body: CustomScrollView(slivers: [ExploreEventsSection()]),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('This week'), findsOneWidget);
        expect(find.text('COMING UP · 5'), findsOneWidget);
        expect(find.textContaining('Long Table'), findsOneWidget);
        expect(find.textContaining('Run'), findsOneWidget);
        expect(find.textContaining('Sketching Strangers'), findsOneWidget);
        expect(find.textContaining('Dinner'), findsWidgets);
        expect(find.textContaining('Pickleball'), findsWidgets);
        expect(find.byType(EventDateRailCard), findsNWidgets(5));
        expect(find.byType(CatchEventSpotlightCard), findsNothing);
      },
    );

    testWidgets('ExploreEventsSection does not duplicate full status meta', (
      tester,
    ) async {
      final club = buildClub(
        id: 'club-full',
        name: 'Pace Social',
        area: 'Necklace Road',
      );
      final featuredEvent = event_test.buildEvent(
        id: 'event-featured',
        clubId: club.id,
        meetingPoint: 'People Plaza',
        bookedCount: 2,
        capacityLimit: 6,
      );
      final event = event_test.buildEvent(
        id: 'event-full',
        clubId: club.id,
        meetingPoint: 'People Plaza',
        bookedCount: 6,
        capacityLimit: 6,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreFeedViewModelProvider.overrideWithValue(
              AsyncData(
                ExploreFeedViewModel(
                  items: [
                    ExploreEventItem(
                      event: featuredEvent,
                      club: club,
                      availability: resolveViewerEventAvailability(
                        event: featuredEvent,
                        userProfile: null,
                      ),
                      status: EventTileStatus.open,
                    ),
                    ExploreEventItem(
                      event: event,
                      club: club,
                      availability: resolveViewerEventAvailability(
                        event: event,
                        userProfile: null,
                      ),
                      status: EventTileStatus.full,
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: CustomScrollView(slivers: [ExploreEventsSection()]),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('6 going · full'), findsOneWidget);
      expect(find.text('FULL'), findsNothing);
      expect(find.byType(EventCapacityProgress), findsNothing);
    });

    testWidgets('Explore event type browse grid updates the activity filter', (
      tester,
    ) async {
      final club = buildClub(
        id: 'club-event-types',
        name: 'Pace Social',
        area: 'Necklace Road',
      );
      final event = event_test.buildEvent(
        id: 'event-dinner',
        clubId: club.id,
        eventFormat: EventFormatSnapshot.fromActivityKind(ActivityKind.dinner),
      );
      final container = ProviderContainer(
        overrides: [
          exploreFeedViewModelProvider.overrideWithValue(
            AsyncData(
              ExploreFeedViewModel(
                items: [
                  ExploreEventItem(
                    event: event,
                    club: club,
                    status: EventTileStatus.open,
                  ),
                ],
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
            home: const Scaffold(
              body: SingleChildScrollView(child: ExploreEventTypeBrowseGrid()),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Browse by event type'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('1 EVENT'), findsOneWidget);

      await tester.tap(find.text('Dinner'));
      await tester.pump();

      expect(
        container.read(clubBrowseFiltersProvider).activityTag,
        ActivityKind.dinner.name,
      );
      expect(find.text('Filtered'), findsOneWidget);
    });

    testWidgets('Explore event type browse grid fits iPhone width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final club = buildClub(
        id: 'club-event-types-fit',
        name: 'Pace Social',
        area: 'Necklace Road',
      );
      final event = event_test.buildEvent(
        id: 'event-social-run',
        clubId: club.id,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreFeedViewModelProvider.overrideWithValue(
              AsyncData(
                ExploreFeedViewModel(
                  items: [
                    ExploreEventItem(
                      event: event,
                      club: club,
                      status: EventTileStatus.open,
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: SingleChildScrollView(child: ExploreEventTypeBrowseGrid()),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Browse by event type'), findsOneWidget);
      expect(find.text('Social run'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ExploreEventsSection empty state can broaden time filter', (
      tester,
    ) async {
      WidgetRef? capturedRef;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreFeedViewModelProvider.overrideWithValue(
              const AsyncData(ExploreFeedViewModel(items: [])),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              capturedRef = ref;
              return MaterialApp(
                theme: AppTheme.light,
                home: const Scaffold(
                  body: CustomScrollView(slivers: [ExploreEventsSection()]),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Nothing this week'), findsOneWidget);
      await tester.tap(find.text('See anytime'));
      await tester.pump();

      expect(
        capturedRef!.read(clubBrowseFiltersProvider).timeFilter,
        ExploreTimeFilter.anytime,
      );
    });

    testWidgets(
      'ExploreEventsSection empty state clears search and filters together',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            exploreFeedViewModelProvider.overrideWithValue(
              const AsyncData(ExploreFeedViewModel(items: [])),
            ),
          ],
        );
        addTearDown(container.dispose);
        container.read(clubSearchQueryProvider.notifier).setQuery('tempo');
        container
            .read(clubBrowseFiltersProvider.notifier)
            .toggleHighRatedOnly();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: const Scaffold(
                body: CustomScrollView(slivers: [ExploreEventsSection()]),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('No events match this search'), findsOneWidget);
        await tester.tap(find.text('Clear search and filters'));
        await tester.pump();

        expect(container.read(clubSearchQueryProvider), isEmpty);
        expect(
          container.read(clubBrowseFiltersProvider).hasActiveFilters,
          false,
        );
      },
    );

    testWidgets('ClubsHeader expands search and updates the search query', (
      tester,
    ) async {
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
                  slivers: [
                    ...ClubsSliverHeader().buildSlivers(context),
                    const SliverToBoxAdapter(child: SizedBox(height: 700)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await _pumpClubUi(tester);

      final initialCityTriggerSize = tester.getSize(find.byType(CityPicker));
      expect(initialCityTriggerSize.width, initialCityTriggerSize.height);
      expect(initialCityTriggerSize.width, lessThanOrEqualTo(60));
      final initialTitleTop = tester.getTopLeft(find.text('Explore')).dy;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pump();

      expect(find.text('Explore').hitTestable(), findsOneWidget);
      expect(find.byType(CityPicker).hitTestable(), findsOneWidget);
      final scrolledTitleTop = tester.getTopLeft(find.text('Explore')).dy;
      expect(scrolledTitleTop, greaterThanOrEqualTo(0));
      expect(scrolledTitleTop, lessThanOrEqualTo(initialTitleTop));
      expect(find.byType(CatchTextField), findsNothing);

      await tester.tap(find.byIcon(CatchIcons.search));
      await tester.pump();
      final midSearchMorphFrame = Duration(
        milliseconds: CatchMotion.base.inMilliseconds ~/ 2,
      );
      await tester.pump(midSearchMorphFrame);

      final morphingSearchWidth = tester
          .getSize(find.byType(CatchTextField))
          .width;
      expect(
        morphingSearchWidth,
        greaterThan(CatchTextField.compactControlHeight),
      );

      await _pumpClubUi(tester);

      final expandedSearchWidth = tester
          .getSize(find.byType(CatchTextField))
          .width;
      expect(expandedSearchWidth, greaterThan(morphingSearchWidth));
      expect(
        tester.getSize(find.byType(CatchTextField)).height,
        CatchTextField.compactControlHeight,
      );
      expect(find.byIcon(CatchIcons.arrowBackRounded), findsNothing);
      expect(find.byIcon(CatchIcons.keyboardHideRounded), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).textInputAction,
        TextInputAction.done,
      );

      await tester.enterText(find.byType(TextField), 'asha');
      await tester.pump();

      expect(container.read(clubSearchQueryProvider), 'asha');

      await tester.tap(find.byIcon(CatchIcons.closeRounded));
      await tester.pump();

      expect(container.read(clubSearchQueryProvider), isEmpty);

      final searchField = tester.widget<TextField>(find.byType(TextField));
      expect(searchField.controller!.text, isEmpty);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _pumpClubUi(tester);

      expect(find.byType(CatchTextField), findsNothing);
    });

    testWidgets('CityPicker renders a circular city trigger', (tester) async {
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          cityListProvider.overrideWith(
            (ref) async => const [
              CityData(
                name: 'hyderabad',
                label: 'Hyderabad',
                latitude: 17.3850,
                longitude: 78.4867,
              ),
            ],
          ),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          uidProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(selectedClubCityProvider.notifier)
          .setCity(
            const CityData(
              name: 'hyderabad',
              label: 'Hyderabad',
              latitude: 17.3850,
              longitude: 78.4867,
            ),
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: Center(child: CityPicker())),
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.byIcon(CatchIcons.locationOnOutlined), findsOneWidget);
      expect(find.text('HYD'), findsNothing);
      expect(find.text('Hyderabad'), findsNothing);
      final triggerSize = tester.getSize(find.byType(CityPicker));
      expect(triggerSize.width, triggerSize.height);
      expect(triggerSize.width, lessThanOrEqualTo(60));
    });

    testWidgets('CityPicker changes city and clears the club search query', (
      tester,
    ) async {
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          cityListProvider.overrideWith((ref) async => _testCities),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          uidProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);
      container.read(clubSearchQueryProvider.notifier).setQuery('asha');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(body: Center(child: CityPicker())),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.tap(find.byType(CityPicker));
      await _pumpClubUi(tester);
      await tester.tap(find.text('Delhi').hitTestable());
      await _pumpClubUi(tester);

      expect(container.read(selectedClubCityProvider).name, 'delhi');
      expect(container.read(clubSearchQueryProvider), isEmpty);
    });

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
            watchClubsOwnedByProvider(
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

      await tester.tap(find.byIcon(CatchIcons.add));
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
        imageUrl: 'https://example.com/club-cover.jpg',
        profileImageUrl: 'https://example.com/club-logo.jpg',
        rating: 4.8,
        reviewCount: 12,
        nextEventLabel: 'Race Course Road Main Gate',
      );

      await pumpTestApp(
        tester,
        Column(
          children: [
            Expanded(child: ClubListTile(club: club, isJoined: true)),
            ClubListTile(
              club: club,
              variant: ClubListTileVariant.avatarChip,
              showLiveBadge: true,
            ),
          ],
        ),
      );

      // The directory card keeps cover art and club identity separate:
      // imageUrl is the cover, profileImageUrl is the logo crest. Rating
      // belongs with the title, not as a duplicate review/meta row.
      expect(find.text('Night Pacers'), findsNWidgets(2));
      expect(find.text('Joined'), findsOneWidget); // corner sash
      expect(find.text('Join'), findsNothing);
      expect(find.text('SOCIAL'), findsOneWidget); // tag chip
      expect(find.text('INDORE'), findsNothing);
      expect(find.text('1\nmember'), findsOneWidget); // member seal
      expect(find.text('RACE COURSE ROAD MAIN GATE'), findsOneWidget);
      expect(
        find.text('4.8 · 12 reviews'),
        findsNothing,
      ); // removed duplicate review/meta row
      expect(find.text('4.8'), findsOneWidget); // title rating
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is NetworkImage &&
              (widget.image as NetworkImage).url ==
                  'https://example.com/club-cover.jpg',
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is NetworkImage &&
              (widget.image as NetworkImage).url ==
                  'https://example.com/club-logo.jpg',
        ),
        findsWidgets,
      );
    });

    testWidgets('ClubListTile labels hosted clubs distinctly from joined', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        ClubListTile(
          club: buildClub(name: 'Host Club'),
          isJoined: true,
          isHost: true,
        ),
      );

      // Host > Joined > Join: hosts get the "You host" sash; the
      // legacy "Joined" sash is suppressed; the Join CTA is hidden.
      expect(find.text('You host'), findsOneWidget);
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
                buildEvent(bookedCount: 1),
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
      expect(find.byType(CatchMetricStrip), findsOneWidget);
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
              club: buildClub(),
              isHost: true,
              onShareClub: (_, club) async {
                sharedClubId = club.id;
              },
            ),
          ],
        ),
      );

      await tester.tap(find.byTooltip('Share club'));
      await _pumpClubUi(tester);

      expect(sharedClubId, 'club-1');
    });

    testWidgets(
      'ClubHeroAppBar shows club identity and pops back from the detail route',
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

        expect(find.text('Rated Club'), findsOneWidget);
        expect(find.text('Bandra, Mumbai'), findsOneWidget);
        expect(find.text('4.8'), findsNothing);
        expect(
          find.byKey(const ValueKey('club-detail-hero-frame')),
          findsOneWidget,
        );
        final heroFrame = tester.widget<CatchSurface>(
          find.byKey(const ValueKey('club-detail-hero-frame')),
        );
        expect(heroFrame.backgroundColor, CatchTokens.sunsetLight.surface);
        final expandedTitle = tester.widget<Text>(
          find.byKey(const ValueKey('club-detail-expanded-title')),
        );
        expect(
          expandedTitle.style?.fontFamily,
          contains(CatchFonts.serifFamily.split(' ').first),
        );

        await tester.tap(find.byIcon(CatchIcons.arrowBackIosNewRounded));
        await _pumpClubUi(tester);

        expect(find.text('Open hero'), findsOneWidget);
      },
    );

    testWidgets(
      'ClubHeroAppBar keeps long title location outside the clipped media frame',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(402, 874);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        final club = buildClub(
          name: 'Vijay Nagar Event Collective',
          area: 'Vijay Nagar',
          location: 'indore',
          imageUrl: 'https://example.com/club.jpg',
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light,
              home: MediaQuery(
                data: const MediaQueryData(
                  size: Size(402, 874),
                  padding: EdgeInsets.only(top: 59, bottom: 34),
                  viewPadding: EdgeInsets.only(top: 59, bottom: 34),
                ),
                child: Scaffold(
                  body: CustomScrollView(
                    slivers: [ClubHeroAppBar(club: club, isHost: false)],
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpClubUi(tester);

        final mediaFrame = find.byKey(
          const ValueKey('club-detail-viewport-curve-frame'),
        );
        final caption = find.byKey(const ValueKey('club-detail-hero-caption'));
        final expandedTitle = find.byKey(
          const ValueKey('club-detail-expanded-title'),
        );
        final location = find.descendant(
          of: caption,
          matching: find.text('Vijay Nagar, Indore'),
        );

        expect(mediaFrame, findsOneWidget);
        expect(caption, findsOneWidget);
        expect(expandedTitle, findsOneWidget);
        expect(location, findsOneWidget);
        expect(
          find.descendant(of: mediaFrame, matching: expandedTitle),
          findsNothing,
        );
        expect(
          tester.getBottomLeft(location).dy,
          lessThan(tester.getBottomLeft(caption).dy),
        );

        final module = tester.widget<ColoredBox>(
          find.byKey(const ValueKey('club-detail-hero-module')),
        );
        expect(module.color, CatchTokens.sunsetLight.surface);
      },
    );

    testWidgets('ClubDetailBody keeps a one-line hero tight to stats', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(402, 874);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final club = buildClub(
        name: 'Sea Face Social',
        imageUrl: 'https://example.com/club.jpg',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(402, 874),
                padding: EdgeInsets.only(top: 59, bottom: 34),
                viewPadding: EdgeInsets.only(top: 59, bottom: 34),
              ),
              child: Scaffold(
                body: ClubDetailBody(
                  club: club,
                  upcoming: const [],
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
          ),
        ),
      );
      await _pumpClubUi(tester);

      final gap =
          tester.getTopLeft(find.byType(StatsStrip)).dy -
          tester.getBottomLeft(find.text('Bandra, Mumbai')).dy;
      expect(gap, greaterThan(0));
      expect(gap, lessThanOrEqualTo(CatchSpacing.s8));
    });

    testWidgets('ClubHeroAppBar uses clean fallback without a cover image', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        CustomScrollView(
          slivers: [
            ClubHeroAppBar(
              club: buildClub(name: 'Morning Miles'),
              isHost: false,
            ),
          ],
        ),
      );

      expect(find.byType(ClubPolaroidArtwork), findsNothing);
      expect(find.text('MM'), findsNothing);
      expect(find.text('Morning Miles'), findsOneWidget);
      expect(find.text('Bandra, Mumbai'), findsOneWidget);
    });

    testWidgets(
      'ClubHeroAppBar reveals the club name in the collapsed toolbar',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(430, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await pumpTestApp(
          tester,
          CustomScrollView(
            slivers: [
              ClubHeroAppBar(
                club: buildClub(
                  name: 'Vijay Nagar Event Collective',
                  imageUrl: 'https://example.com/club.jpg',
                ),
                isHost: false,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 900)),
            ],
          ),
        );

        expect(
          find.byKey(const ValueKey('club-detail-collapsed-title')),
          findsNothing,
        );

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -520));
        await _pumpClubUi(tester);

        final collapsedTitle = find.byKey(
          const ValueKey('club-detail-collapsed-title'),
        );
        expect(collapsedTitle, findsOneWidget);
        expect(tester.getTopLeft(collapsedTitle).dy, lessThan(96));
        final collapsedTitleText = tester.widget<Text>(collapsedTitle);
        expect(
          collapsedTitleText.style?.fontFamily,
          contains(CatchFonts.serifFamily.split(' ').first),
        );
      },
    );

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
          club: buildClub(name: 'No Cover Club', area: 'Signal Hill'),
        ),
      );

      expect(find.byType(ClubPolaroidArtwork), findsWidgets);
      expect(find.text('NC'), findsNothing);
      expect(find.byIcon(CatchIcons.locationOnRounded), findsOneWidget);
      // Directory cards use the area as the caption when no next event is set;
      // the fallback crest itself should not add a duplicate footer label.
      expect(find.text('SIGNAL HILL / MUMBAI'), findsOneWidget);
    });

    testWidgets('ClubDetailBody host view exposes edit and create navigation', (
      tester,
    ) async {
      final club = buildClub(
        id: 'club-host',
        area: 'Saket',
        hostName: 'Asha Host',
      );
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
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.text('Join club'), findsNothing);
      expect(find.text('Leave club'), findsNothing);
      final scrollBackground = tester.widget<ColoredBox>(
        find
            .ancestor(
              of: find.byType(CustomScrollView),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(scrollBackground.color, CatchTokens.sunsetLight.surface);
      expect(find.byIcon(CatchIcons.platformShare()), findsOneWidget);
      expect(find.text('Share'), findsNothing);
      expect(find.text('Hosted by Asha Host'), findsOneWidget);
      expect(find.text('View profile'), findsOneWidget);
      expect(find.text('Club host'), findsNothing);
      expect(find.text('Hosts events in Saket'), findsNothing);

      await tester.scrollUntilVisible(find.text('Booked'), 240);
      await _pumpClubUi(tester);

      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('HOST TOOLS'), findsOneWidget);
      expect(find.text('Edit club'), findsOneWidget);
      expect(find.text('Add event'), findsOneWidget);

      await tester.ensureVisible(find.text('Edit club'));
      await _pumpClubUi(tester);
      await tester.tap(find.text('Edit club'));
      await _pumpClubUi(tester);

      expect(find.text('Edit club-host'), findsOneWidget);

      router.go('/');
      await _pumpClubUi(tester);

      await tester.ensureVisible(find.text('Add event'));
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

      expect(find.text('Host'), findsNothing);
      expect(find.text('Hosted by Asha Shah'), findsOneWidget);
      expect(find.text('View profile'), findsOneWidget);
      expect(find.text('Club host'), findsNothing);
      expect(find.text('Hosts events in Bandra'), findsNothing);

      await tester.tap(find.text('Hosted by Asha Shah'));
      await _pumpClubUi(tester);

      expect(find.text('Profile host-42'), findsOneWidget);
    });

    testWidgets('ClubDetailBody shows multiple hosts and messages a host', (
      tester,
    ) async {
      final fakeRepository = FakeClubsRepository()
        ..nextHostConversationMatchId = 'host-inquiry-1';
      final club = buildClub(
        id: 'club-multi-host',
        hostUserId: 'owner-1',
        ownerUserId: 'owner-1',
        hostUserIds: const ['owner-1', 'host-2'],
        hostProfiles: const [
          ClubHostProfile(
            uid: 'owner-1',
            displayName: 'Owner Host',
            role: ClubHostRole.owner,
          ),
          ClubHostProfile(uid: 'host-2', displayName: 'Co Host'),
        ],
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
            path: '/chat/:matchId',
            name: Routes.chatScreen.name,
            builder: (_, state) => Text(
              'Chat ${state.pathParameters['matchId']}',
              textDirection: TextDirection.ltr,
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
      final container = ProviderContainer(
        overrides: [
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
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.text('Hosted by Owner Host'), findsOneWidget);
      expect(find.text('Hosted by Co Host'), findsOneWidget);
      expect(find.text('Owner'), findsOneWidget);
      expect(find.text('Host'), findsOneWidget);
      expect(find.byTooltip('Message host'), findsNWidgets(2));

      await tester.tap(findLastByTooltip('Message host'));
      await _pumpClubUi(tester);

      expect(fakeRepository.startedConversationClubId, club.id);
      expect(fakeRepository.startedConversationHostUid, 'host-2');
      expect(find.text('Chat host-inquiry-1'), findsOneWidget);
    });

    testWidgets('ClubDetailBody owner sees host team management actions', (
      tester,
    ) async {
      final club = buildClub(
        id: 'club-owner-hosts',
        hostUserId: 'owner-1',
        ownerUserId: 'owner-1',
        hostUserIds: const ['owner-1', 'host-2'],
        hostProfiles: const [
          ClubHostProfile(
            uid: 'owner-1',
            displayName: 'Owner Host',
            role: ClubHostRole.owner,
          ),
          ClubHostProfile(uid: 'host-2', displayName: 'Co Host'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('owner-1')),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: ClubDetailBody(
                club: club,
                upcoming: const [],
                reviews: const [],
                userProfile: buildUser(uid: 'owner-1'),
                uid: 'owner-1',
                isHost: true,
                isMember: true,
                isMutating: false,
                clubPushNotificationsEnabled: false,
                isClubPushMutating: false,
                isAuthenticated: true,
              ),
            ),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.scrollUntilVisible(find.text('Host team'), 240);
      await _pumpClubUi(tester);

      expect(find.text('Host team'), findsOneWidget);
      expect(find.byTooltip('Add host'), findsOneWidget);
      expect(find.text('Owner Host'), findsWidgets);
      expect(find.text('Co Host'), findsWidgets);

      await tester.ensureVisible(findLastByTooltip('Host actions'));
      await _pumpClubUi(tester);
      await tester.tap(findLastByTooltip('Host actions'));
      await _pumpClubUi(tester);

      expect(find.text('Transfer ownership'), findsOneWidget);
      expect(find.text('Remove host'), findsOneWidget);
    });

    testWidgets(
      'ClubDetailBody keeps club review aggregate read-only below schedule',
      (tester) async {
        final club = buildClub(id: 'club-reviews');
        final reviews = [
          buildReview(comment: 'Most recent.'),
          buildReview(id: 'review-2', comment: 'Second recent.'),
          buildReview(id: 'review-3', comment: 'Third recent.'),
          buildReview(id: 'review-4', comment: 'Fourth hidden.'),
        ];

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
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
        ProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await _pumpClubUi(tester);

      await tester.tap(find.text('START'));
      await _pumpClubUi(tester);

      expect(find.text('Event event-42'), findsOneWidget);
    });

    testWidgets(
      'ClubsListScreen renders club discovery without directory join',
      (tester) async {
        final club = buildClub(id: 'club-99', name: 'Pace Social');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cityListProvider.overrideWith((ref) async => _testCities),
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
              uidProvider.overrideWith((ref) => Stream.value(null)),
              watchClubsByLocationProvider(
                club.location,
              ).overrideWith((ref) => Stream.value([club])),
              _emptyExploreFeedOverride,
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ClubsListScreen(),
            ),
          ),
        );
        await _pumpClubUi(tester);

        expect(find.text('Pace Social'), findsOneWidget);
        expect(find.text('Club directory'), findsNothing);
        expect(find.text('Your clubs'), findsNothing);
        expect(_catchButtonWithLabel('Join'), findsNothing);
      },
    );

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
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubsListScreen(),
          ),
        ),
      );
      await tester.pump();

      // Loading sheet renders a 3-card skeleton column inside the sheet,
      // not the old multi-piece per-card skeleton. The exact count is a
      // visual choice; assert "at least one" so future tightening doesn't
      // re-break the test.
      expect(find.byType(CatchSkeleton), findsAtLeastNWidgets(1));
      expect(find.byType(CatchTextField), findsNothing);
    });

    testWidgets(
      'ClubsListScreen keeps search reachable when the selected city is empty',
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
              _emptyExploreFeedOverride,
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ClubsListScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CityPicker), findsOneWidget);
        expect(find.byIcon(CatchIcons.locationOnOutlined), findsOneWidget);
        expect(find.byType(CatchTextField), findsNothing);
        expect(find.text('No clubs in Mumbai yet'), findsOneWidget);

        await tester.tap(find.byTooltip('Search events or clubs'));
        await _pumpClubUi(tester);

        expect(find.byType(CatchTextField), findsOneWidget);
      },
    );

    testWidgets('ClubsListScreen filters discover cards from the chip rail', (
      tester,
    ) async {
      final socialClub = buildClub(
        id: 'social-club',
        name: 'Bandra Pacers',
        rating: 4.2,
      );
      final tempoClub = buildClub(
        id: 'tempo-club',
        name: 'Tempo Queens',
        area: 'Juhu',
        tags: const ['tempo'],
        rating: 4.8,
        reviewCount: 9,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            uidProvider.overrideWith((ref) => Stream.value(null)),
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value([socialClub, tempoClub])),
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubsListScreen(),
          ),
        ),
      );
      await _pumpClubUi(tester);

      // New short filter rail: time pills (tonight/tomorrow/weekend/this
      // week/anytime), compact distance chips (1/3/5/10 km), Joined toggle.
      // High-rated, activity-tag, and area chips were intentionally retired
      // from this rail — they pushed the primary filters off screen.
      expect(find.text('Tonight'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('Weekend'), findsOneWidget);
      expect(find.text('3 km'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Anytime'), findsOneWidget);
      expect(find.text('Joined'), findsOneWidget);
      expect(find.text('Rated 4.5+'), findsNothing);
      expect(find.text('Tempo Queens'), findsOneWidget);

      // Default time filter selection means the Clear chip should appear
      // only once the user has changed something. Toggle tonight to make
      // sure the chip rail tracks the change.
      await tester.tap(find.text('Tonight'));
      await _pumpClubUi(tester);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('ClubsListScreen opens map and drags back to feed', (
      tester,
    ) async {
      final club = buildClub(id: 'club-map', name: 'Bandra Pacers');
      final event = event_test.buildEvent(
        id: 'event-map',
        clubId: club.id,
        meetingPoint: 'Race Course Road main gate',
        startingPointLat: 19.07,
        startingPointLng: 72.88,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            uidProvider.overrideWith((ref) => Stream.value(null)),
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value([club])),
            eventMapViewModelProvider.overrideWith(
              (ref) => AsyncData(
                EventMapViewModel(events: [event], pinnedEvents: [event]),
              ),
            ),
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubsListScreen(enableEventMapNetworkTiles: false),
          ),
        ),
      );
      await _pumpClubUi(tester);

      // Cold load: feed visible, snap toggle reads "Map".
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Bandra Pacers'), findsOneWidget);
      final mapPill = find.widgetWithText(InkWell, 'Map');
      expect(mapPill, findsOneWidget);

      // Tap to drop to the map detent. The open affordance disappears in map
      // mode; closing is owned by dragging the sheet back up.
      await tester.tap(mapPill);
      await _pumpClubUi(tester);
      expect(find.widgetWithText(InkWell, 'List'), findsNothing);
      expect(find.widgetWithText(InkWell, 'Map'), findsNothing);
      // The legacy "Explore map / Pins show…" tooltip is gone — the top
      // chrome (city + Explore + filter rail) lives above the map instead.
      expect(find.text('Explore map'), findsNothing);
      expect(find.text('Pins show upcoming events'), findsNothing);
      // Top chrome stays visible regardless of snap state.
      expect(find.text('Explore'), findsOneWidget);

      await tester.drag(
        find.byKey(const ValueKey('explore-list-scroll-view')),
        const Offset(0, -900),
      );
      await _pumpClubUi(tester);

      expect(find.widgetWithText(InkWell, 'Map'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Bandra Pacers'), findsOneWidget);
    });

    testWidgets(
      'ClubsListScreen keeps the closed feed below safe-area chrome',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final club = buildClub(id: 'club-safe-area', name: 'Bandra Pacers');
        final event = event_test.buildEvent(
          id: 'event-safe-area',
          clubId: club.id,
          startTime: DateTime(2026, 5, 28, 7),
          meetingPoint: 'Race Course Road main gate',
          startingPointLat: 19.07,
          startingPointLng: 72.88,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cityListProvider.overrideWith((ref) async => _testCities),
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
              uidProvider.overrideWith((ref) => Stream.value(null)),
              watchClubsByLocationProvider(
                'mumbai',
              ).overrideWith((ref) => Stream.value([club])),
              exploreFeedViewModelProvider.overrideWithValue(
                AsyncData(
                  ExploreFeedViewModel(
                    items: [
                      ExploreEventItem(
                        event: event,
                        club: club,
                        availability: resolveViewerEventAvailability(
                          event: event,
                          userProfile: null,
                        ),
                        status: EventTileStatus.open,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const MediaQuery(
                data: MediaQueryData(
                  size: Size(390, 844),
                  padding: EdgeInsets.only(top: 54),
                  viewPadding: EdgeInsets.only(top: 54),
                ),
                child: ClubsListScreen(enableEventMapNetworkTiles: false),
              ),
            ),
          ),
        );
        await _pumpClubUi(tester);

        final shellTop = tester
            .getTopLeft(find.byType(CatchDraggableSheetShell))
            .dy;
        final chromeBottom = tester
            .getBottomLeft(find.byType(ClubsFilterRail))
            .dy;
        final topLidRect = tester.getRect(
          find.byKey(const ValueKey('explore-top-lid')),
        );
        expect(topLidRect.top, 0);
        expect(topLidRect.bottom, greaterThanOrEqualTo(chromeBottom));
        expect(shellTop, greaterThanOrEqualTo(chromeBottom));

        await tester.drag(_exploreListScrollable(), const Offset(0, -520));
        await _pumpClubUi(tester);

        expect(
          tester.getTopLeft(find.byType(CatchDraggableSheetShell)).dy,
          greaterThanOrEqualTo(chromeBottom),
        );

        await tester.tap(find.widgetWithText(InkWell, 'Map · 1'));
        await _pumpClubUi(tester);

        expect(
          tester.getTopLeft(find.byType(CatchDraggableSheetShell)).dy,
          greaterThan(chromeBottom),
        );
      },
    );

    testWidgets('ClubsListScreen reveals map after wrist-lift motion', (
      tester,
    ) async {
      final club = buildClub(id: 'club-motion', name: 'Bandra Pacers');
      final motionSource = _FakeDeviceMotionSource();
      addTearDown(motionSource.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            deviceMotionSourceProvider.overrideWithValue(motionSource),
            uidProvider.overrideWith((ref) => Stream.value(null)),
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value([club])),
            eventMapViewModelProvider.overrideWith(
              (ref) => const AsyncData(
                EventMapViewModel(events: [], pinnedEvents: []),
              ),
            ),
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubsListScreen(enableEventMapNetworkTiles: false),
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.widgetWithText(InkWell, 'Map'), findsOneWidget);

      final timestamp = DateTime(2026);
      motionSource
        ..add(
          DeviceMotionSample(
            timestamp: timestamp,
            userAccelerationX: 0.1,
            userAccelerationY: 1.1,
            userAccelerationZ: 0.2,
            rotationX: 2.7,
            rotationY: 0.5,
            rotationZ: 0.2,
          ),
        )
        ..add(
          DeviceMotionSample(
            timestamp: timestamp.add(const Duration(milliseconds: 80)),
            userAccelerationX: 0.1,
            userAccelerationY: 1.3,
            userAccelerationZ: 0.2,
            rotationX: 2.9,
            rotationY: 0.4,
            rotationZ: 0.2,
          ),
        );
      await _pumpClubUi(tester);

      expect(find.widgetWithText(InkWell, 'Map'), findsNothing);
      expect(find.text('Explore'), findsOneWidget);
    });

    testWidgets('ClubsListScreen peek sheet shows a collapsed event summary', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final club = buildClub(
        id: 'club-peek',
        name: 'Pace Social',
        area: 'Necklace Road',
      );
      final event = event_test.buildEvent(
        id: 'event-peek',
        clubId: club.id,
        meetingPoint: 'People Plaza',
        bookedCount: 8,
        capacityLimit: 12,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            uidProvider.overrideWith((ref) => Stream.value(null)),
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value([club])),
            eventMapViewModelProvider.overrideWith(
              (ref) => const AsyncData(
                EventMapViewModel(events: [], pinnedEvents: []),
              ),
            ),
            exploreFeedViewModelProvider.overrideWithValue(
              AsyncData(
                ExploreFeedViewModel(
                  items: [
                    ExploreEventItem(
                      event: event,
                      club: club,
                      status: EventTileStatus.open,
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ClubsListScreen(enableEventMapNetworkTiles: false),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.drag(
        find.byKey(const ValueKey('explore-list-scroll-view')),
        const Offset(0, 1200),
      );
      await _pumpClubUi(tester);

      // Peek state keeps the map dominant: just aggregate copy, no tiny card
      // rail or "See all" action competing with the handle.
      expect(find.text('1 event nearby'), findsOneWidget);
      expect(find.text('Mumbai · This week'), findsOneWidget);
      expect(find.byTooltip('See all nearby events'), findsNothing);
      expect(find.widgetWithText(InkWell, 'List'), findsNothing);
    });

    testWidgets(
      'ClubsListScreen selected pin opens the half-sheet event card',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final club = buildClub(
          id: 'club-selected-pin',
          name: 'Pace Social',
          area: 'Necklace Road',
        );
        final events = [
          for (var index = 0; index < 6; index += 1)
            event_test.buildEvent(
              id: 'event-pin-$index',
              clubId: club.id,
              meetingPoint: 'Point $index',
              startTime: DateTime.now().add(Duration(days: index + 1)),
              startingPointLat: 19.0,
              startingPointLng: 72.0 + (index * 0.01),
            ),
        ];
        final selectedEvent = events.last;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cityListProvider.overrideWith((ref) async => _testCities),
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
              uidProvider.overrideWith((ref) => Stream.value(null)),
              watchClubsByLocationProvider(
                'mumbai',
              ).overrideWith((ref) => Stream.value([club])),
              eventMapViewModelProvider.overrideWith(
                (ref) => const AsyncData(
                  EventMapViewModel(events: [], pinnedEvents: []),
                ),
              ),
              exploreFeedViewModelProvider.overrideWithValue(
                AsyncData(
                  ExploreFeedViewModel(
                    items: [
                      for (final event in events)
                        ExploreEventItem(
                          event: event,
                          club: club,
                          status: EventTileStatus.open,
                        ),
                    ],
                  ),
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ClubsListScreen(enableEventMapNetworkTiles: false),
            ),
          ),
        );
        await _pumpClubUi(tester);

        await tester.tap(find.widgetWithText(InkWell, 'Map · 6'));
        await _pumpClubUi(tester);

        await tester.drag(
          find.byKey(const ValueKey('explore-list-scroll-view')),
          const Offset(0, 420),
        );
        await _pumpClubUi(tester);

        // Tap the placeholder pin for the selected event via its semantic
        // label. (Network tiles are disabled in this test so the placeholder
        // map is used; each pin exposes a `Select <locationName>` semantic.)
        await tester.tap(
          find.bySemanticsLabel('Select ${selectedEvent.locationName}'),
        );
        await _pumpClubUi(tester);

        // Pin selection animates the sheet upward to the selected event ticket
        // instead of promoting every selected pin into spotlight styling.
        expect(
          find.byKey(ValueKey('explore-selected-${selectedEvent.id}')),
          findsOneWidget,
        );
        expect(find.byType(CatchEventTicketCard), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Hero &&
                widget.tag ==
                    eventTicketHeroTag(selectedEvent.id, 'map_selected_card'),
          ),
          findsOneWidget,
        );
        expect(find.text('6 events nearby'), findsNothing);
      },
    );

    testWidgets('selected spotlight pin keeps spotlight styling', (
      tester,
    ) async {
      final club = buildClub(
        id: 'club-selected-spotlight',
        name: 'Spotlight Club',
      );
      final spotlight = event_test.buildEvent(
        id: 'event-spotlight-pin',
        clubId: club.id,
        meetingPoint: 'Spotlight Point',
        startTime: DateTime.now().add(const Duration(days: 1)),
      );
      final other = event_test.buildEvent(
        id: 'event-other-pin',
        clubId: club.id,
        meetingPoint: 'Other Point',
        startTime: DateTime.now().add(const Duration(days: 2)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreFeedViewModelProvider.overrideWithValue(
              AsyncData(
                ExploreFeedViewModel(
                  items: [
                    ExploreEventItem(
                      event: spotlight,
                      club: club,
                      status: EventTileStatus.recommended,
                    ),
                    ExploreEventItem(
                      event: other,
                      club: club,
                      status: EventTileStatus.open,
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              return MaterialApp(
                theme: AppTheme.light,
                home: Scaffold(
                  body: CustomScrollView(
                    slivers: buildExploreMapSheetLeadSlivers(
                      ref: ref,
                      selectedEventId: spotlight.id,
                      cameraCenter: null,
                      filters: const ClubBrowseFilterSelection(),
                      scopeLabel: 'Mumbai',
                      leadMode: ExploreMapSheetLeadMode.selectedEvent,
                      onEventTapped: (_) {},
                      onSeeAll: () {},
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(ValueKey('explore-selected-${spotlight.id}')),
        findsOneWidget,
      );
      expect(find.byType(CatchEventSpotlightCard), findsOneWidget);
      expect(find.byType(CatchEventTicketCard), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Hero &&
              widget.tag ==
                  eventSpotlightHeroTag(spotlight.id, 'map_selected_card'),
        ),
        findsOneWidget,
      );
    });

    test('explore map summary switches to map area after a large pan', () {
      final mumbai = _testCities.first;

      expect(exploreMapScopeLabel(city: mumbai, cameraCenter: null), 'Mumbai');
      expect(
        exploreMapScopeLabel(
          city: mumbai,
          cameraCenter: const LocationCoordinate(19.08, 72.88),
        ),
        'Mumbai',
      );
      expect(
        exploreMapScopeLabel(
          city: mumbai,
          cameraCenter: const LocationCoordinate(19.45, 73.35),
        ),
        'Map area',
      );
    });

    testWidgets('Explore peek rail loading skeleton scrolls on narrow sheets', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreFeedViewModelProvider.overrideWithValue(
              const AsyncLoading<ExploreFeedViewModel>(),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              return MaterialApp(
                theme: AppTheme.light,
                home: Scaffold(
                  body: CustomScrollView(
                    slivers: buildExploreMapSheetLeadSlivers(
                      ref: ref,
                      selectedEventId: null,
                      cameraCenter: null,
                      filters: const ClubBrowseFilterSelection(),
                      scopeLabel: 'Mumbai',
                      leadMode: ExploreMapSheetLeadMode.nearbyRail,
                      onEventTapped: (_) {},
                      onSeeAll: () {},
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(CatchSkeleton), findsNWidgets(3));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets(
      'Explore peek rail resets to nearest events after camera reorder',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final club = buildClub(
          id: 'club-camera-sort',
          name: 'Camera Sort Club',
        );
        final events = [
          for (var index = 0; index < 6; index += 1)
            event_test.buildEvent(
              id: 'camera-event-$index',
              clubId: club.id,
              meetingPoint: 'Camera Point $index',
              startTime: DateTime.now().add(Duration(days: index + 1)),
              startingPointLat: 19.0,
              startingPointLng: 72.0 + (index * 0.01),
            ),
        ];
        var cameraCenter = const LocationCoordinate(19.0, 72.0);
        late void Function(LocationCoordinate center) updateCamera;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              exploreFeedViewModelProvider.overrideWithValue(
                AsyncData(
                  ExploreFeedViewModel(
                    items: [
                      for (final event in events)
                        ExploreEventItem(
                          event: event,
                          club: club,
                          status: EventTileStatus.open,
                        ),
                    ],
                  ),
                ),
              ),
            ],
            child: StatefulBuilder(
              builder: (context, setState) {
                updateCamera = (center) =>
                    setState(() => cameraCenter = center);
                return Consumer(
                  builder: (context, ref, _) {
                    return MaterialApp(
                      theme: AppTheme.light,
                      home: Scaffold(
                        body: CustomScrollView(
                          slivers: buildExploreMapSheetLeadSlivers(
                            ref: ref,
                            selectedEventId: null,
                            cameraCenter: cameraCenter,
                            filters: const ClubBrowseFilterSelection(),
                            scopeLabel: 'Mumbai',
                            leadMode: ExploreMapSheetLeadMode.nearbyRail,
                            onEventTapped: (_) {},
                            onSeeAll: () {},
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
        await tester.pump();

        final railScrollable = find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        );
        expect(railScrollable, findsOneWidget);

        await tester.drag(find.byType(ListView), const Offset(-520, 0));
        await tester.pump();
        expect(
          tester.state<ScrollableState>(railScrollable).position.pixels,
          greaterThan(0),
        );

        updateCamera(const LocationCoordinate(19.0, 72.05));
        await tester.pump();
        await tester.pump(CatchMotion.fast);

        expect(
          tester.state<ScrollableState>(railScrollable).position.pixels,
          0,
        );
        expect(
          find.byKey(ValueKey('explore-peek-${events.last.id}')),
          findsOneWidget,
        );
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
            _emptyExploreFeedOverride,
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
          _emptyExploreFeedOverride,
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

    testWidgets('CreateClubScreen picks and previews club photos', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      const transparentPixel =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==';
      final fakeImageUploadRepository = FakeImageUploadRepository(
        pickedImages: [
          XFile.fromData(
            base64Decode(transparentPixel),
            name: 'club-photo-test.png',
            mimeType: 'image/png',
          ),
        ],
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

      // Cover picker sits below the fold in the create form — scroll it into
      // view before tapping (standard for a long scrollable form).
      await tester.ensureVisible(find.text('Add club photos'));
      await _pumpClubUi(tester);
      await tester.tap(find.text('Add club photos'));
      await _pumpClubUi(tester);

      expect(find.bySemanticsLabel('Photo 1'), findsOneWidget);
    });

    testWidgets('CreateClubScreen shows mutation errors inline', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [uidProvider.overrideWith((ref) => Stream.value(null))],
      );
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

      expect(find.text('Club basics'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Morning Miles'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Palasia'), findsOneWidget);
      expect(find.text('Indore'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await _pumpClubUi(tester);

      expect(find.text('Next'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Indore morning loops.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Next'));
      await _pumpClubUi(tester);

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Default event policy'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await _pumpClubUi(tester);

      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Default event success'), findsOneWidget);
    });

    testWidgets(
      'CreateClubScreen clears optional contact fields in edit mode',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final fakeRepository = FakeClubsRepository();
        final club = buildClub(
          ownerUserId: 'host-1',
          instagramHandle: '@morningmiles',
          phoneNumber: '9876543210',
          email: 'hello@morningmiles.test',
        );
        final container = ProviderContainer(
          overrides: [
            clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
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
              home: CreateClubScreen(initialClub: club),
            ),
          ),
        );
        await _pumpClubUi(tester);

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);

        await _enterCreateClubText(tester, 'Instagram handle', '');
        await _enterCreateClubText(tester, 'Phone number', '');
        await _enterCreateClubText(tester, 'Email', '');

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);
        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);
        await tester.tap(find.text('Save changes'));
        await _pumpClubUi(tester);

        expect(fakeRepository.lastUpdatedClubId, club.id);
        expect(fakeRepository.lastUpdatedFields!['instagramHandle'], isNull);
        expect(fakeRepository.lastUpdatedFields!['phoneNumber'], isNull);
        expect(fakeRepository.lastUpdatedFields!['email'], isNull);
      },
    );

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
        final cityDropdownIcon = find.byIcon(CatchIcons.expandMoreRounded);
        await tester.ensureVisible(cityDropdownIcon);
        await tester.tap(cityDropdownIcon);
        await _pumpClubUi(tester);
        await tester.tap(find.text('Mumbai').hitTestable());
        await _pumpClubUi(tester);

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);

        expect(find.text('Please add a description'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(CatchTextField, 'Description'),
          'Easy social club',
        );
        tester.testTextInput.hide();
        await tester.pump();

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);

        expect(find.text('Default event policy'), findsOneWidget);

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);

        expect(find.text('Default event success'), findsOneWidget);

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

Future<void> _enterCreateClubText(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = find.widgetWithText(CatchTextField, label);
  await tester.ensureVisible(field);
  await tester.pump();
  await tester.enterText(field, value);
  await tester.pump();
}
