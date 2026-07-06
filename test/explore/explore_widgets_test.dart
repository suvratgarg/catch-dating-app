import 'dart:async';
import 'dart:convert';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen_state.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_dock.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_list_tile.dart';
import 'package:catch_dating_app/clubs/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/shared/club_transition_tags.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/external_event.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_map_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/catch_cover_story.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_body.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_city_picker.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_event_type_browse_grid.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_events_section.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_filter_rail.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_header.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_list.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_controller.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/create_club_screen.dart';
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

import '../clubs/clubs_test_helpers.dart';
import '../events/events_test_helpers.dart' as event_test;
import '../test_pump_helpers.dart';

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

ExploreCityPickerState _testCityPickerState({
  CityData? selectedCity,
  Iterable<CityData> cities = _testCities,
  bool cityListLoading = false,
  Object? cityListError,
}) {
  return ExploreCityPickerState.from(
    selectedCity: selectedCity ?? _testCities.first,
    cities: cities,
    cityListLoading: cityListLoading,
    cityListError: cityListError,
  );
}

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

Widget _exploreBodySliverGroup({
  required ExploreViewModel clubsViewModel,
  AsyncValue<ExploreFeedViewModel> feedAsync = const AsyncData(
    ExploreFeedViewModel(items: []),
  ),
  ExploreFilterSelection filters = const ExploreFilterSelection(),
  String searchQuery = '',
  Object? clubSectionError,
  VoidCallback onRetryFeed = _noop,
  VoidCallback onRetryClubs = _noop,
  VoidCallback onClearSearch = _noop,
  VoidCallback onClearFilters = _noop,
  ValueChanged<ExploreTimeFilter> onSetTimeFilter = _noopTimeFilter,
  ValueChanged<ActivityKind> onActivitySelected = _noopActivityKind,
  ExploreEventSelected onEventSelected = _noopExploreEventSelected,
  ValueChanged<ExploreExternalEventItem> onExternalEventOpened =
      _noopExternalEventOpened,
  bool includeJoinedClubsRail = true,
  bool includeClubDirectory = true,
}) {
  return Builder(
    builder: (context) => SliverMainAxisGroup(
      slivers: buildExploreBodySlivers(
        context: context,
        feedAsync: feedAsync,
        clubsViewModel: clubsViewModel,
        filters: filters,
        searchQuery: searchQuery,
        clubSectionError: clubSectionError,
        onRetryFeed: onRetryFeed,
        onRetryClubs: onRetryClubs,
        onClearSearch: onClearSearch,
        onClearFilters: onClearFilters,
        onSetTimeFilter: onSetTimeFilter,
        onActivitySelected: onActivitySelected,
        onEventSelected: onEventSelected,
        onExternalEventOpened: onExternalEventOpened,
        includeJoinedClubsRail: includeJoinedClubsRail,
        includeClubDirectory: includeClubDirectory,
        pinnedExploreDayHeaders: false,
      ),
    ),
  );
}

ExploreEventsSection _exploreEventsSection({
  AsyncValue<ExploreFeedViewModel> feedAsync = const AsyncData(
    ExploreFeedViewModel(items: []),
  ),
  ExploreFilterSelection filters = const ExploreFilterSelection(),
  String searchQuery = '',
  VoidCallback onRetry = _noop,
  VoidCallback onClearSearch = _noop,
  VoidCallback onClearFilters = _noop,
  ValueChanged<ExploreTimeFilter> onSetTimeFilter = _noopTimeFilter,
  ExploreEventSelected onEventSelected = _noopExploreEventSelected,
  ValueChanged<ExploreExternalEventItem> onExternalEventOpened =
      _noopExternalEventOpened,
}) {
  return ExploreEventsSection(
    feedAsync: feedAsync,
    filters: filters,
    searchQuery: searchQuery,
    onRetry: onRetry,
    onClearSearch: onClearSearch,
    onClearFilters: onClearFilters,
    onSetTimeFilter: onSetTimeFilter,
    onEventSelected: onEventSelected,
    onExternalEventOpened: onExternalEventOpened,
  );
}

List<Widget> _exploreEventsSlivers({
  AsyncValue<ExploreFeedViewModel> feedAsync = const AsyncData(
    ExploreFeedViewModel(items: []),
  ),
  ExploreFilterSelection filters = const ExploreFilterSelection(),
  String searchQuery = '',
  VoidCallback onRetry = _noop,
  VoidCallback onClearSearch = _noop,
  VoidCallback onClearFilters = _noop,
  ValueChanged<ExploreTimeFilter> onSetTimeFilter = _noopTimeFilter,
  ExploreEventSelected onEventSelected = _noopExploreEventSelected,
  ValueChanged<ExploreExternalEventItem> onExternalEventOpened =
      _noopExternalEventOpened,
  bool pinnedDayHeaders = true,
  List<Club> candidateClubs = const [],
  Set<String> joinedClubIds = const {},
}) {
  return buildExploreEventsSlivers(
    feedAsync,
    filters: filters,
    searchQuery: searchQuery,
    onRetry: onRetry,
    onClearSearch: onClearSearch,
    onClearFilters: onClearFilters,
    onSetTimeFilter: onSetTimeFilter,
    onEventSelected: onEventSelected,
    onExternalEventOpened: onExternalEventOpened,
    pinnedDayHeaders: pinnedDayHeaders,
    candidateClubs: candidateClubs,
    joinedClubIds: joinedClubIds,
  );
}

ExploreDiscoveryCoverHeader _exploreCoverHeader({
  String query = '',
  ExploreEventItem? featuredItem,
  ValueChanged<String> onQueryChanged = _noopString,
  ValueChanged<ExploreEventItem> onFeaturedEventSelected =
      _noopFeaturedEventSelected,
}) {
  return ExploreDiscoveryCoverHeader(
    query: query,
    featuredItem: featuredItem,
    cityPickerState: _testCityPickerState(),
    onCitySelected: (_) {},
    onQueryChanged: onQueryChanged,
    onFeaturedEventSelected: onFeaturedEventSelected,
  );
}

void _noop() {}
void _noopString(String _) {}
void _noopTimeFilter(ExploreTimeFilter _) {}
void _noopActivityKind(ActivityKind _) {}
void _noopExploreEventSelected(ExploreEventItem item, String source) {}
void _noopFeaturedEventSelected(ExploreEventItem _) {}
void _noopExternalEventOpened(ExploreExternalEventItem _) {}

/// Returns the network URL backing an [Image] widget, unwrapping the
/// [ResizeImage] that [CatchNetworkImage] applies for decode-sizing.
String? _networkImageUrl(Widget widget) {
  if (widget is! Image) return null;
  final image = widget.image;
  final provider = image is ResizeImage ? image.imageProvider : image;
  return provider is NetworkImage ? provider.url : null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  group('Explore and club discovery widgets', () {
    testWidgets('CatchPolaroid uses handoff title and arrow defaults', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        CatchPolaroid(
          media: const ColoredBox(color: Colors.black),
          caption: 'CLUB TO KNOW',
          title: 'Neighbourhood Club',
          onTap: () {},
        ),
      );

      final title = tester.widget<Text>(find.text('Neighbourhood Club'));
      expect(title.style?.fontSize, CatchLayout.clubPolaroidTitleSize);
      expect(title.style?.fontStyle, isNot(FontStyle.italic));
      expect(find.byIcon(CatchIcons.forwardArrow), findsOneWidget);

      await pumpTestApp(
        tester,
        const CatchPolaroid(
          media: ColoredBox(color: Colors.black),
          caption: 'CLUB TO KNOW',
          title: 'Neighbourhood Club',
          showArrow: false,
        ),
      );

      expect(find.byIcon(CatchIcons.forwardArrow), findsNothing);
    });

    testWidgets('ExploreList shows the empty state when there are no clubs', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchClubsByLocationProvider(
              'mumbai',
            ).overrideWith((ref) => Stream.value(const [])),
            exploreClubsViewModelProvider.overrideWithValue(
              const AsyncData(ExploreViewModel(joinedClubs: [], allClubs: [])),
            ),
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: CustomScrollView(slivers: [ExploreList()]),
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

    testWidgets('ExploreList shows search-specific empty copy', (tester) async {
      final sourceClub = buildClub(id: 'source-club', name: 'Bandra Pacers');
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          watchClubsByLocationProvider(
            'mumbai',
          ).overrideWith((ref) => Stream.value([sourceClub])),
          exploreClubsViewModelProvider.overrideWithValue(
            const AsyncData(ExploreViewModel(joinedClubs: [], allClubs: [])),
          ),
          _emptyExploreFeedOverride,
        ],
      );
      addTearDown(container.dispose);
      container.read(exploreSearchQueryProvider.notifier).setQuery('tempo');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: CustomScrollView(slivers: [ExploreList()]),
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

      expect(container.read(exploreSearchQueryProvider), isEmpty);
    });

    testWidgets('ExploreList shows filter-specific empty copy', (tester) async {
      final sourceClub = buildClub(id: 'source-club', name: 'Bandra Pacers');
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          watchClubsByLocationProvider(
            'mumbai',
          ).overrideWith((ref) => Stream.value([sourceClub])),
          exploreClubsViewModelProvider.overrideWithValue(
            const AsyncData(ExploreViewModel(joinedClubs: [], allClubs: [])),
          ),
          _emptyExploreFeedOverride,
        ],
      );
      addTearDown(container.dispose);
      container.read(exploreFiltersProvider.notifier).toggleHighRatedOnly();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: CustomScrollView(slivers: [ExploreList()]),
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

      expect(container.read(exploreFiltersProvider).hasActiveFilters, false);
    });

    testWidgets(
      'ClubsContent renders personal rail and mixed discovery cards',
      (tester) async {
        await _pumpClubsSlivers(tester, [
          _exploreBodySliverGroup(
            includeClubDirectory: false,
            clubsViewModel: ExploreViewModel(
              joinedClubs: [
                buildClub(id: 'joined-1', nextEventLabel: 'Sat 6:30 AM'),
              ],
              allClubs: [
                buildClub(id: 'joined-1', nextEventLabel: 'Sat 6:30 AM'),
                buildClub(id: 'discover-1'),
              ],
              joinedClubIds: {'joined-1'},
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
      final featuredEvent = event_test.buildEvent(
        id: 'event-featured',
        clubId: club.id,
        meetingPoint: 'People Plaza',
        bookedCount: 8,
        capacityLimit: 12,
      );
      final bodyEvent = event_test.buildEvent(
        id: 'event-body',
        clubId: club.id,
        startTime: DateTime.now().add(const Duration(hours: 4)),
        meetingPoint: 'Library steps',
        bookedCount: 8,
        capacityLimit: 12,
        eventFormat: EventFormatSnapshot.custom(
          label: 'board games',
          interactionModel: EventInteractionModel.openFormat,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                _exploreEventsSection(
                  feedAsync: AsyncData(
                    ExploreFeedViewModel(
                      items: [
                        ExploreEventItem(
                          event: featuredEvent,
                          club: club,
                          availability: resolveViewerEventAvailability(
                            event: featuredEvent,
                            userProfile: null,
                            now: DateTime.now(),
                          ),
                          status: EventTileStatus.open,
                        ),
                        ExploreEventItem(
                          event: bodyEvent,
                          club: club,
                          availability: resolveViewerEventAvailability(
                            event: bodyEvent,
                            userProfile: null,
                            now: DateTime.now(),
                          ),
                          status: EventTileStatus.open,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // Sparse markets should keep the regular Explore feed and skip the
      // weekly strip until there are enough day-level picks to justify it.
      expect(find.text('This week'), findsNothing);
      expect(find.textContaining('COMING UP'), findsNothing);
      expect(find.textContaining('1 PLAN'), findsOneWidget);
      expect(find.byType(CatchCoverStory), findsNothing);
      expect(find.textContaining(featuredEvent.title), findsNothing);
      expect(find.textContaining(bodyEvent.title), findsWidgets);
      expect(find.text('8 going · 4 spots left'), findsOneWidget);
    });

    testWidgets('Explore body slivers keep feed visible when clubs fail', (
      tester,
    ) async {
      final club = buildClub(id: 'club-feed-only', name: 'Pace Social');
      final featuredEvent = event_test.buildEvent(
        id: 'event-feed-featured',
        clubId: club.id,
        meetingPoint: 'People Plaza',
        bookedCount: 8,
        capacityLimit: 12,
      );
      final bodyEvent = event_test.buildEvent(
        id: 'event-feed-only',
        clubId: club.id,
        startTime: DateTime.now().add(const Duration(hours: 4)),
        meetingPoint: 'People Plaza',
        bookedCount: 8,
        capacityLimit: 12,
      );

      await _pumpClubsSlivers(tester, [
        _exploreBodySliverGroup(
          clubsViewModel: const ExploreViewModel(joinedClubs: [], allClubs: []),
          feedAsync: AsyncData(
            ExploreFeedViewModel(
              items: [
                ExploreEventItem(
                  event: featuredEvent,
                  club: club,
                  availability: resolveViewerEventAvailability(
                    event: featuredEvent,
                    userProfile: null,
                    now: DateTime.now(),
                  ),
                  status: EventTileStatus.open,
                ),
                ExploreEventItem(
                  event: bodyEvent,
                  club: club,
                  availability: resolveViewerEventAvailability(
                    event: bodyEvent,
                    userProfile: null,
                    now: DateTime.now(),
                  ),
                  status: EventTileStatus.open,
                ),
              ],
            ),
          ),
          clubSectionError: StateError('clubs failed'),
        ),
      ]);

      expect(find.textContaining(bodyEvent.title), findsWidgets);
      expect(find.byType(CatchInlineErrorState), findsOneWidget);
    });

    testWidgets('ExploreDiscoveryCoverHeader CTA delegates featured item', (
      tester,
    ) async {
      final club = buildClub(id: 'club-cover', name: 'Pace Social');
      final event = event_test.buildEvent(
        id: 'event-cover',
        clubId: club.id,
        bookedCount: 8,
        capacityLimit: 12,
      );
      final item = ExploreEventItem(
        event: event,
        club: club,
        availability: resolveViewerEventAvailability(
          event: event,
          userProfile: null,
          now: DateTime.now(),
        ),
        status: EventTileStatus.open,
      );
      ExploreEventItem? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: _exploreCoverHeader(
              featuredItem: item,
              onFeaturedEventSelected: (item) => selectedItem = item,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(event.title), findsOneWidget);

      await tester.tap(find.text('Claim a seat'));
      await tester.pump();

      expect(selectedItem?.event.id, 'event-cover');
    });

    testWidgets('ExploreDiscoveryCoverHeader paints through the top inset', (
      tester,
    ) async {
      const topInset = 47.0;
      final club = buildClub(id: 'club-cover-safe', name: 'Pace Social');
      final event = event_test.buildEvent(
        id: 'event-cover-safe',
        clubId: club.id,
        meetingPoint: 'People Plaza',
      );
      final item = ExploreEventItem(
        event: event,
        club: club,
        availability: resolveViewerEventAvailability(
          event: event,
          userProfile: null,
          now: DateTime.now(),
        ),
        status: EventTileStatus.open,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreFeedViewModelProvider.overrideWithValue(
              AsyncData(ExploreFeedViewModel(items: [item])),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.only(top: topInset),
              ),
              child: Scaffold(body: _exploreCoverHeader(featuredItem: item)),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.getTopLeft(find.byType(ExploreDiscoveryCoverHeader)).dy, 0);
      expect(
        tester.getSize(find.byType(ExploreDiscoveryCoverHeader)).height,
        greaterThan(topInset),
      );

      final searchIcon = find.byIcon(CatchIcons.searchRounded);
      expect(searchIcon, findsOneWidget);
      final searchHitTargetTop =
          tester.getCenter(searchIcon).dy -
          CatchLayout.coverStorySearchExtent / 2;
      expect(searchHitTargetTop, greaterThanOrEqualTo(topInset));
    });

    testWidgets('ExploreDiscoveryCoverHeader uses compact row without hero', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(body: _exploreCoverHeader()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Explore'), findsOneWidget);
      expect(find.byIcon(CatchIcons.search), findsOneWidget);
      expect(find.text('Find an event worth showing up for.'), findsOneWidget);
      expect(find.byType(CatchCoverStory), findsNothing);
    });

    testWidgets('ExploreDiscoveryCoverHeader search opens the compact field', (
      tester,
    ) async {
      final club = buildClub(id: 'club-cover-search', name: 'Pace Social');
      final event = event_test.buildEvent(
        id: 'event-cover-search',
        clubId: club.id,
      );
      final item = ExploreEventItem(
        event: event,
        club: club,
        availability: resolveViewerEventAvailability(
          event: event,
          userProfile: null,
          now: DateTime.now(),
        ),
        status: EventTileStatus.open,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(body: _exploreCoverHeader(featuredItem: item)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CatchCoverStory), findsOneWidget);
      expect(find.text(event.title), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.bySemanticsLabel('Search'));
      await tester.pump();
      await _pumpClubUi(tester);

      expect(find.byType(CatchCoverStory), findsNothing);
      expect(_topLevelSearchField(), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(
        tester.getSize(find.byType(ExploreCityPicker)).height,
        CatchIconButton.navSize,
      );
      expect(
        tester.getSize(_topLevelSearchField()).height,
        CatchIconButton.navSize,
      );
      expect(find.text(event.title), findsNothing);
    });

    testWidgets('CatchCoverStory data block stays within narrow widths', (
      tester,
    ) async {
      // Regression guard: the data block must yield to the Expanded CTA (ellipsis)
      // rather than overflow the Row on narrow widths / large text scales.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(1.6)),
                    // Vertical scroll keeps the (intentionally tall) cover from
                    // a height overflow so the probe isolates the horizontal
                    // data-Row constraint under test.
                    child: const SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CatchCoverStory(
                          kicker: "This week's pick",
                          title:
                              'Long-table supper for strangers in Bandra West',
                          body:
                              'Pace Social - Carter Road - 5km easy run - 5km',
                          cta: 'View event',
                          data: '7:30 AM · ₹1,200',
                          data2: '12 going · 4 spots left',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('CatchCoverStory labels tappable location chrome', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CatchCoverStory(
              title: 'Tonight in Mumbai',
              location: 'Mumbai',
              onLocation: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byTooltip('Change location'), findsOneWidget);
      expect(find.bySemanticsLabel('Change location, Mumbai'), findsOneWidget);

      await tester.tap(find.text('MUMBAI'));
      await tester.pump();

      expect(tapped, isTrue);
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
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: _exploreEventsSlivers(
                pinnedDayHeaders: false,
                candidateClubs: [club],
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
      expect(
        find.byKey(const ValueKey('club-detail-viewport-curve-frame')),
        findsOneWidget,
      );
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
        final quiz = event_test.buildEvent(
          id: 'event-week-quiz',
          clubId: club.id,
          startTime: today.add(const Duration(days: 6, hours: 20)),
          meetingPoint: 'Trivia room',
          eventFormat: EventFormatSnapshot.fromActivityKind(
            ActivityKind.pubQuiz,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  _exploreEventsSection(
                    feedAsync: AsyncData(
                      ExploreFeedViewModel(
                        items: [
                          for (final event in [
                            dinner,
                            run,
                            art,
                            brunch,
                            pickleball,
                            quiz,
                          ])
                            ExploreEventItem(
                              event: event,
                              club: club,
                              availability: resolveViewerEventAvailability(
                                event: event,
                                userProfile: null,
                                now: DateTime.now(),
                              ),
                              status: EventTileStatus.open,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('This week'), findsOneWidget);
        expect(find.text('COMING UP · 5'), findsOneWidget);
        expect(find.textContaining('Long Table'), findsNothing);
        expect(find.textContaining('Run'), findsOneWidget);
        expect(find.textContaining('Sketching Strangers'), findsOneWidget);
        expect(find.textContaining('Dinner'), findsWidgets);
        expect(find.textContaining('Pickleball'), findsWidgets);
        expect(find.textContaining('Pub Quiz'), findsWidgets);
        expect(find.byType(EventDateRailCard), findsNWidgets(5));
        expect(find.byType(CatchCoverStory), findsNothing);
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
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                _exploreEventsSection(
                  feedAsync: AsyncData(
                    ExploreFeedViewModel(
                      items: [
                        ExploreEventItem(
                          event: featuredEvent,
                          club: club,
                          availability: resolveViewerEventAvailability(
                            event: featuredEvent,
                            userProfile: null,
                            now: DateTime.now(),
                          ),
                          status: EventTileStatus.open,
                        ),
                        ExploreEventItem(
                          event: event,
                          club: club,
                          availability: resolveViewerEventAvailability(
                            event: event,
                            userProfile: null,
                            now: DateTime.now(),
                          ),
                          status: EventTileStatus.full,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('6 going · full'), findsOneWidget);
      expect(find.text('FULL'), findsNothing);
    });

    testWidgets('Explore event type browse index updates the activity filter', (
      tester,
    ) async {
      final club = buildClub(
        id: 'club-event-types',
        name: 'Pace Social',
        area: 'Necklace Road',
      );
      final activityKinds = [
        ActivityKind.socialRun,
        ActivityKind.dinner,
        ActivityKind.pubQuiz,
        ActivityKind.pickleball,
        ActivityKind.walking,
        ActivityKind.padel,
        ActivityKind.tennis,
        ActivityKind.yoga,
        ActivityKind.barCrawl,
        ActivityKind.dinner,
        ActivityKind.socialRun,
        ActivityKind.socialRun,
      ];
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final items = [
        for (var index = 0; index < activityKinds.length; index += 1)
          ExploreEventItem(
            event: event_test.buildEvent(
              id: 'event-type-$index',
              clubId: club.id,
              eventFormat: EventFormatSnapshot.fromActivityKind(
                activityKinds[index],
              ),
            ),
            club: club,
            status: EventTileStatus.open,
          ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExploreEventTypeBrowseGrid(
                items: items,
                onCategoryTap: (kind) => container
                    .read(exploreFiltersProvider.notifier)
                    .toggleActivityTag(kind.name),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('BY ACTIVITY'), findsOneWidget);
      expect(find.text('Social run'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Pub quiz'), findsOneWidget);
      expect(find.text('Pickleball'), findsOneWidget);
      expect(find.text('Walking'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('+ 4 MORE TYPES'), findsOneWidget);
      expect(find.text('Padel'), findsNothing);

      await tester.tap(find.text('Dinner'));
      await tester.pump();

      expect(
        container.read(exploreFiltersProvider).activityTag,
        ActivityKind.dinner.name,
      );

      await tester.tap(find.text('+ 4 MORE TYPES'));
      await tester.pump();

      expect(find.text('Padel'), findsOneWidget);
      expect(find.text('+ 4 MORE TYPES'), findsNothing);
    });

    testWidgets('Explore event type browse index fits iPhone width', (
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
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExploreEventTypeBrowseGrid(
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
        ),
      );
      await tester.pump();

      expect(find.text('BY ACTIVITY'), findsOneWidget);
      expect(find.text('Social run'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ExploreEventsSection empty state can broaden time filter', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                _exploreEventsSection(
                  filters: container.read(exploreFiltersProvider),
                  onSetTimeFilter: (filter) => container
                      .read(exploreFiltersProvider.notifier)
                      .setTimeFilter(filter),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Nothing this week'), findsOneWidget);
      await tester.tap(find.text('See anytime'));
      await tester.pump();

      expect(
        container.read(exploreFiltersProvider).timeFilter,
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
        container.read(exploreSearchQueryProvider.notifier).setQuery('tempo');
        container.read(exploreFiltersProvider.notifier).toggleHighRatedOnly();

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  _exploreEventsSection(
                    filters: container.read(exploreFiltersProvider),
                    searchQuery: container.read(exploreSearchQueryProvider),
                    onClearSearch: () => container
                        .read(exploreSearchQueryProvider.notifier)
                        .clear(),
                    onClearFilters: () =>
                        container.read(exploreFiltersProvider.notifier).clear(),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('No events match this search'), findsOneWidget);
        await tester.tap(find.text('Clear search and filters'));
        await tester.pump();

        expect(container.read(exploreSearchQueryProvider), isEmpty);
        expect(container.read(exploreFiltersProvider).hasActiveFilters, false);
      },
    );

    testWidgets('Explore header expands search and updates the search query', (
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
                    ...CatchSliverHeader(
                      title: const SizedBox.shrink(),
                      bottomHeight: CatchLayout.browseHeaderHeight,
                      bottom: ExploreBrowseHeaderContent(
                        query: container.read(exploreSearchQueryProvider),
                        onQueryChanged: (value) => container
                            .read(exploreSearchQueryProvider.notifier)
                            .setQuery(value),
                      ),
                    ).buildSlivers(context),
                    const SliverToBoxAdapter(child: SizedBox(height: 700)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await _pumpClubUi(tester);

      final initialCityTriggerSize = tester.getSize(
        find.byType(ExploreCityPicker),
      );
      expect(initialCityTriggerSize.width, initialCityTriggerSize.height);
      expect(initialCityTriggerSize.width, lessThanOrEqualTo(60));
      final initialTitleTop = tester.getTopLeft(find.text('Explore')).dy;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -220));
      await tester.pump();

      expect(find.text('Explore').hitTestable(), findsOneWidget);
      expect(find.byType(ExploreCityPicker).hitTestable(), findsOneWidget);
      final scrolledTitleTop = tester.getTopLeft(find.text('Explore')).dy;
      expect(scrolledTitleTop, greaterThanOrEqualTo(0));
      expect(scrolledTitleTop, lessThanOrEqualTo(initialTitleTop));
      expect(_topLevelSearchField(), findsOneWidget);
      expect(
        tester.getSize(_topLevelSearchField()).width,
        lessThanOrEqualTo(CatchIconButton.navSize),
      );
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byIcon(CatchIcons.search));
      await tester.pump();
      final midSearchMorphFrame = Duration(
        milliseconds: CatchMotion.base.inMilliseconds ~/ 2,
      );
      await tester.pump(midSearchMorphFrame);

      final morphingSearchWidth = tester.getSize(_topLevelSearchField()).width;
      expect(morphingSearchWidth, greaterThan(CatchIconButton.navSize));

      await _pumpClubUi(tester);

      final expandedSearchWidth = tester.getSize(_topLevelSearchField()).width;
      expect(expandedSearchWidth, greaterThanOrEqualTo(morphingSearchWidth));
      expect(
        tester.getSize(_topLevelSearchField()).height,
        CatchIconButton.navSize,
      );
      expect(find.byIcon(CatchIcons.arrowBackRounded), findsNothing);
      expect(find.byIcon(CatchIcons.keyboardHideRounded), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).textInputAction,
        TextInputAction.done,
      );

      await tester.enterText(find.byType(TextField), 'asha');
      await tester.pump();

      expect(container.read(exploreSearchQueryProvider), 'asha');

      await tester.tap(find.byIcon(CatchIcons.clearCircle));
      await tester.pump();

      expect(container.read(exploreSearchQueryProvider), isEmpty);

      final searchField = tester.widget<TextField>(find.byType(TextField));
      expect(searchField.controller!.text, isEmpty);

      await tester.tap(find.byIcon(CatchIcons.close));
      await _pumpClubUi(tester);

      expect(_topLevelSearchField(), findsOneWidget);
      expect(
        tester.getSize(_topLevelSearchField()).width,
        lessThanOrEqualTo(CatchIconButton.navSize),
      );
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('ExploreCityPicker renders a circular city trigger', (
      tester,
    ) async {
      const hyderabad = CityData(
        name: 'hyderabad',
        label: 'Hyderabad',
        latitude: 17.3850,
        longitude: 78.4867,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: ExploreCityPicker(
                state: ExploreCityPickerState.from(
                  selectedCity: hyderabad,
                  cities: const [hyderabad],
                  cityListLoading: false,
                  cityListError: null,
                ),
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.byIcon(CatchIcons.locationOnOutlined), findsOneWidget);
      expect(find.text('HYD'), findsNothing);
      expect(find.text('Hyderabad'), findsNothing);
      final triggerSize = tester.getSize(find.byType(ExploreCityPicker));
      expect(triggerSize.width, triggerSize.height);
      expect(triggerSize.width, lessThanOrEqualTo(60));
    });

    testWidgets(
      'ExploreCityPicker changes city and clears the Explore search query',
      (tester) async {
        final container = ProviderContainer(retry: (_, _) => null);
        addTearDown(container.dispose);
        container.read(exploreSearchQueryProvider.notifier).setQuery('asha');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: Center(
                  child: ExploreCityPicker(
                    state: _testCityPickerState(),
                    onSelected: (city) => container
                        .read(selectedExploreCityProvider.notifier)
                        .setCity(city),
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpClubUi(tester);

        await tester.tap(find.byType(ExploreCityPicker));
        await _pumpClubUi(tester);
        await tester.tap(find.text('Delhi').hitTestable());
        await _pumpClubUi(tester);

        expect(container.read(selectedExploreCityProvider).name, 'delhi');
        expect(container.read(exploreSearchQueryProvider), isEmpty);
      },
    );

    testWidgets('Explore header hides create-club action in consumer app', (
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
                  slivers: const CatchSliverHeader(
                    title: SizedBox.shrink(),
                    bottomHeight: CatchLayout.browseHeaderHeight,
                    bottom: ExploreBrowseHeaderContent(),
                  ).buildSlivers(context),
                ),
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => Stream.value('host-1')),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.byIcon(CatchIcons.add), findsNothing);
      expect(find.text('Create club'), findsNothing);
    });

    testWidgets('club index row and avatar chip render club metadata', (
      tester,
    ) async {
      final club = buildClub(
        name: 'Night Pacers',
        location: 'in-mp-indore',
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
            Expanded(child: ClubIndexRow(club: club, isJoined: true)),
            AvatarChip(club: club, showLiveBadge: true),
          ],
        ),
      );

      // The index row keeps cover art and rail identity separate:
      // imageUrl is the row thumbnail, profileImageUrl is the avatar-chip image.
      expect(find.text('Night Pacers'), findsNWidgets(2));
      expect(find.text('Joined'), findsOneWidget);
      expect(find.text('Join'), findsNothing);
      expect(find.text('SOCIAL RUN'), findsOneWidget);
      expect(find.text('BANDRA / INDORE · 1 MEMBER'), findsOneWidget);
      expect(find.text('RACE COURSE ROAD MAIN GATE'), findsNothing);
      expect(find.text('4.8'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              _networkImageUrl(widget) == 'https://example.com/club-cover.jpg',
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              _networkImageUrl(widget) == 'https://example.com/club-logo.jpg',
        ),
        findsWidgets,
      );
    });

    testWidgets('ClubIndexRow labels joined clubs without host state', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        ClubIndexRow(club: buildClub(name: 'Host Club'), isJoined: true),
      );

      expect(find.text('You host'), findsNothing);
      expect(find.text('Joined'), findsOneWidget);
      expect(find.text('Join'), findsNothing);
    });

    testWidgets(
      'ClubMembershipDock renders the correct action and pending state',
      (tester) async {
        await pumpTestApp(
          tester,
          Column(
            children: [
              ClubMembershipDock(
                club: buildClub(),
                isMember: false,
                isAuthenticated: true,
                isMutating: false,
                pushNotificationsEnabled: false,
                isPushMutating: false,
              ),
              ClubMembershipDock(
                club: buildClub(),
                isMember: true,
                isAuthenticated: true,
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
                  (widget) => widget is CatchButton && widget.label == 'Joined',
                ),
              )
              .isLoading,
          isTrue,
        );
      },
    );

    testWidgets(
      'ClubMembershipDock join and leave actions hit the repository',
      (tester) async {
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
              home: Scaffold(
                body: Column(
                  children: [
                    ClubMembershipDock(
                      club: buildClub(id: 'club-join'),
                      isMember: false,
                      isAuthenticated: true,
                      isMutating: false,
                      pushNotificationsEnabled: false,
                      isPushMutating: false,
                    ),
                    ClubMembershipDock(
                      club: buildClub(id: 'club-leave'),
                      isMember: true,
                      isAuthenticated: true,
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
        await tester.tap(find.text('Joined'));
        await _pumpClubUi(tester);

        expect(fakeRepository.joinedClubId, 'club-join');
        expect(fakeRepository.leftClubId, 'club-leave');
      },
    );

    testWidgets(
      'HostClubManagementPanel and metric strip show computed values',
      (tester) async {
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
              const CatchMetricStrip(
                items: [
                  CatchMetricStripItem(value: '24', label: 'members'),
                  CatchMetricStripItem(value: '4.7', label: 'rating'),
                  CatchMetricStripItem(value: '12', label: 'reviews'),
                  CatchMetricStripItem(value: 'JAN 2025', label: 'est.'),
                ],
              ),
            ],
          ),
        );

        expect(find.text('Booked'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('₹30'), findsOneWidget);
        expect(find.byType(CatchMetricStrip), findsOneWidget);
        expect(find.text('members'), findsOneWidget);
        expect(find.text('reviews'), findsOneWidget);
        expect(find.text('est.'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
        expect(find.text('JAN 2025'), findsOneWidget);
        expect(find.text('4.7'), findsOneWidget);
      },
    );

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
          location: 'in-mp-indore',
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
                  state: ClubDetailBodyState.fromDomain(
                    club: club,
                    userProfile: buildUser(uid: 'runner-1'),
                    uid: 'runner-1',
                    isMember: true,
                    isAuthenticated: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await _pumpClubUi(tester);

      final gap =
          tester.getTopLeft(find.byType(CatchMetricStrip)).dy -
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

    testWidgets('club index row and avatar chip navigate to detail routes', (
      tester,
    ) async {
      Future<void> pumpRow({
        required String id,
        required Widget Function(BuildContext context, Club club) childBuilder,
      }) async {
        final club = buildClub(
          id: id,
          name: 'Club $id',
          imageUrl: 'https://example.com/club.jpg',
        );
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) =>
                  Scaffold(body: Center(child: childBuilder(context, club))),
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
                (widget is ClubIndexRow && widget.club.id == club.id) ||
                (widget is AvatarChip && widget.club.id == club.id),
          ),
        );
        await _pumpClubUi(tester);

        expect(find.text('Detail ${club.id}'), findsOneWidget);
      }

      await pumpRow(
        id: 'index',
        childBuilder: (context, club) => ClubIndexRow(
          club: club,
          isJoined: true,
          onTap: () => context.pushNamed(
            Routes.clubDetailScreen.name,
            pathParameters: {'clubId': club.id},
            extra: club,
          ),
        ),
      );
      await pumpRow(
        id: 'avatar',
        childBuilder: (context, club) => AvatarChip(
          club: club,
          showLiveBadge: true,
          onTap: () => context.pushNamed(
            Routes.clubDetailScreen.name,
            pathParameters: {'clubId': club.id},
            extra: club,
          ),
        ),
      );
    });

    testWidgets('ClubIndexRow uses club cover fallback when image is absent', (
      tester,
    ) async {
      await pumpTestApp(
        tester,
        ClubIndexRow(
          club: buildClub(name: 'No Cover Club', area: 'Signal Hill'),
          isJoined: false,
        ),
      );

      expect(find.byType(ClubPolaroidArtwork), findsWidgets);
      expect(find.text('NC'), findsNothing);
      expect(find.byIcon(CatchIcons.locationOnRounded), findsOneWidget);
      // Index rows use the area/city/member line as the mono meta row; the
      // fallback artwork itself should not add a duplicate footer label.
      expect(find.text('SIGNAL HILL / MUMBAI · 1 MEMBER'), findsOneWidget);
    });

    testWidgets('ClubIndexRow surfaces directory join failures', (
      tester,
    ) async {
      final fakeRepository = FakeClubsRepository()
        ..joinError = StateError('join failed');
      final container = ProviderContainer(
        retry: (_, _) => null,
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
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(
                child: ClubIndexRow(
                  club: buildClub(id: 'club-fail', name: 'Fail Club'),
                  isJoined: false,
                ),
              ),
            ),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.tap(find.widgetWithText(CatchButton, 'Join'));
      await tester.pump();
      await _pumpClubUi(tester);

      expect(fakeRepository.joinedClubId, isNull);
      expect(find.text('join failed'), findsOneWidget);
    });

    testWidgets('ClubDetailBody host view stays a public club profile', (
      tester,
    ) async {
      AppConfig.configureEntrypointRole(AppRole.host);
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
                state: ClubDetailBodyState.fromDomain(
                  club: club,
                  upcomingEvents: [buildEvent(clubId: club.id)],
                  userProfile: buildUser(uid: 'host-1'),
                  uid: 'host-1',
                  isHost: true,
                  isMember: true,
                  isAuthenticated: true,
                  appRole: AppRole.host,
                ),
              ),
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
      expect(find.text('Asha Host'), findsOneWidget);
      expect(find.textContaining('OWNER · EST. JAN 2025'), findsOneWidget);
      expect(find.textContaining('VIEW PROFILE'), findsNothing);
      expect(find.text('Club host'), findsNothing);
      expect(find.text('Hosts events in Saket'), findsNothing);

      expect(find.text('HOST TOOLS'), findsNothing);
      expect(find.text('Edit club'), findsNothing);
      expect(find.text('Add event'), findsNothing);
      expect(find.text('Payouts'), findsNothing);
      expect(find.text('Set up payouts'), findsNothing);
      expect(find.text('Host team'), findsNothing);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
      await _pumpClubUi(tester);
      expect(find.text('HOSTED'), findsOneWidget);
    });

    testWidgets(
      'ClubDetailBody shows host identity without opening a dating profile',
      (tester) async {
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
                  state: ClubDetailBodyState.fromDomain(
                    club: club,
                    userProfile: buildUser(uid: 'runner-1'),
                    uid: 'runner-1',
                    isAuthenticated: true,
                  ),
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
        expect(find.text('Asha Shah'), findsOneWidget);
        expect(find.textContaining('OWNER · EST. JAN 2025'), findsOneWidget);
        expect(find.textContaining('VIEW PROFILE'), findsNothing);
        expect(find.text('Club host'), findsNothing);
        expect(find.text('Hosts events in Bandra'), findsNothing);

        await tester.ensureVisible(find.text('Asha Shah'));
        await _pumpClubUi(tester);

        await tester.tap(find.text('Asha Shah'));
        await _pumpClubUi(tester);

        expect(find.text('Profile host-42'), findsNothing);
      },
    );

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
            builder: (context, _) => Scaffold(
              body: ClubDetailBody(
                state: ClubDetailBodyState.fromDomain(
                  club: club,
                  userProfile: buildUser(uid: 'runner-1'),
                  uid: 'runner-1',
                  isAuthenticated: true,
                ),
                onMessageHost: (buttonContext, host) async {
                  final matchId = await fakeRepository
                      .startClubHostConversation(
                        clubId: club.id,
                        hostUid: host.uid,
                      );
                  if (!buttonContext.mounted) return;
                  await buttonContext.pushNamed<void>(
                    Routes.chatScreen.name,
                    pathParameters: {'matchId': matchId},
                  );
                },
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

      expect(find.text('Owner Host'), findsOneWidget);
      expect(find.text('Co Host'), findsOneWidget);
      expect(find.textContaining('OWNER · '), findsOneWidget);
      expect(find.textContaining('HOST · '), findsOneWidget);

      await tester.ensureVisible(find.text('Co Host'));
      await _pumpClubUi(tester);

      expect(find.byTooltip('Message host'), findsNWidgets(2));

      await tester.tap(findLastByTooltip('Message host'));
      await _pumpClubUi(tester);

      expect(fakeRepository.startedConversationClubId, club.id);
      expect(fakeRepository.startedConversationHostUid, 'host-2');
      expect(find.text('Chat host-inquiry-1'), findsOneWidget);
    });

    testWidgets(
      'ClubDetailBody owner does not see host team management actions',
      (tester) async {
        AppConfig.configureEntrypointRole(AppRole.host);
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
                  state: ClubDetailBodyState.fromDomain(
                    club: club,
                    userProfile: buildUser(uid: 'owner-1'),
                    uid: 'owner-1',
                    isHost: true,
                    isMember: true,
                    isAuthenticated: true,
                    appRole: AppRole.host,
                  ),
                ),
              ),
            ),
          ),
        );
        await _pumpClubUi(tester);

        expect(find.text('Host team'), findsNothing);
        expect(find.byTooltip('Add host'), findsNothing);
        expect(find.byTooltip('Host actions'), findsNothing);
        expect(find.text('Transfer ownership'), findsNothing);
        expect(find.text('Remove host'), findsNothing);

        await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
        await _pumpClubUi(tester);
        expect(
          find.text('Publish an event when this club is ready to meet.'),
          findsNothing,
        );
        expect(
          find.text(
            'Future events will appear here once the host publishes one.',
          ),
          findsOneWidget,
        );
      },
    );

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
                  state: ClubDetailBodyState.fromDomain(
                    club: club,
                    reviews: reviews,
                    userProfile: buildUser(uid: 'runner-1'),
                    uid: 'runner-1',
                    isMember: true,
                    isAuthenticated: true,
                  ),
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
        expect(scrollView.slivers[3], isA<CatchDetailSliverSectionList>());
        final trailingSections =
            scrollView.slivers[3] as CatchDetailSliverSectionList;
        expect(
          trailingSections.sections.whereType<CatchSection>().map(
            (section) => section.title,
          ),
          contains('Reviews'),
        );

        for (
          var i = 0;
          i < 12 && find.text('Most recent.').evaluate().isEmpty;
          i++
        ) {
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -400),
          );
          await _pumpClubUi(tester);
        }

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
            builder: (context, _) => Scaffold(
              body: ClubDetailBody(
                state: ClubDetailBodyState.fromDomain(
                  club: club,
                  upcomingEvents: [event],
                  userProfile: buildUser(uid: 'runner-1'),
                  uid: 'runner-1',
                  isMember: true,
                  isAuthenticated: true,
                ),
                onEventSelected: (selectedEvent) => unawaited(
                  context.pushNamed<void>(
                    Routes.eventDetailScreen.name,
                    pathParameters: {
                      'clubId': club.id,
                      'eventId': selectedEvent.id,
                    },
                  ),
                ),
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

    testWidgets('ExploreScreen renders club discovery without directory join', (
      tester,
    ) async {
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
            home: const ExploreScreen(),
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.text('Pace Social'), findsOneWidget);
      expect(find.text('Club directory'), findsNothing);
      expect(find.text('Your clubs'), findsNothing);
      expect(_catchButtonWithLabel('Join'), findsNothing);
    });

    testWidgets('ExploreScreen shows skeleton cards while loading', (
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
            exploreClubsViewModelProvider.overrideWithValue(
              const AsyncLoading(),
            ),
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ExploreScreen(),
          ),
        ),
      );
      await tester.pump();

      // Loading sheet renders a 3-card skeleton column inside the sheet,
      // not the old multi-piece per-card skeleton. The exact count is a
      // visual choice; assert "at least one" so future tightening doesn't
      // re-break the test.
      expect(find.byType(CatchSkeleton), findsAtLeastNWidgets(1));
      expect(_topLevelSearchField(), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets(
      'ExploreScreen keeps search reachable when the selected city is empty',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cityListProvider.overrideWith((ref) async => _testCities),
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
              watchClubsByLocationProvider(
                'mumbai',
              ).overrideWith((ref) => Stream.value(const [])),
              exploreClubsViewModelProvider.overrideWithValue(
                const AsyncData(
                  ExploreViewModel(joinedClubs: [], allClubs: []),
                ),
              ),
              _emptyExploreFeedOverride,
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ExploreScreen(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(ExploreCityPicker), findsOneWidget);
        expect(find.byIcon(CatchIcons.locationOnOutlined), findsOneWidget);
        expect(_topLevelSearchField(), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(find.text('No clubs in Mumbai yet'), findsOneWidget);

        await tester.tap(find.byTooltip('Search events or clubs'));
        await tester.pump();
        final midSearchMorphFrame = Duration(
          milliseconds: CatchMotion.base.inMilliseconds ~/ 2,
        );
        await tester.pump(midSearchMorphFrame);

        final morphingSearchWidth = tester
            .getSize(_topLevelSearchField())
            .width;
        expect(morphingSearchWidth, greaterThan(CatchIconButton.navSize));

        await _pumpClubUi(tester);

        final expandedSearchWidth = tester
            .getSize(_topLevelSearchField())
            .width;
        expect(expandedSearchWidth, greaterThanOrEqualTo(morphingSearchWidth));
        expect(_topLevelSearchField(), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets('ExploreScreen empty state clears search and filters', (
      tester,
    ) async {
      final sourceClub = buildClub(id: 'source-club', name: 'Bandra Pacers');
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          cityListProvider.overrideWith((ref) async => _testCities),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          exploreSourceClubsProvider.overrideWithValue(AsyncData([sourceClub])),
          exploreClubsViewModelProvider.overrideWithValue(
            const AsyncData(ExploreViewModel(joinedClubs: [], allClubs: [])),
          ),
          _emptyExploreFeedOverride,
        ],
      );
      addTearDown(container.dispose);
      container.read(exploreSearchQueryProvider.notifier).setQuery('tempo');
      container.read(exploreFiltersProvider.notifier).toggleHighRatedOnly();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ExploreScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No clubs match this search'), findsOneWidget);
      await tester.tap(find.text('Clear search and filters'));
      await tester.pump();

      expect(container.read(exploreSearchQueryProvider), isEmpty);
      expect(container.read(exploreFiltersProvider).hasActiveFilters, false);
    });

    testWidgets('ExploreScreen renders internal feed when clubs are empty', (
      tester,
    ) async {
      final club = buildClub(id: 'club-event-only', name: 'Pace Social');
      final event = event_test.buildEvent(id: 'event-only', clubId: club.id);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            uidProvider.overrideWith((ref) => Stream.value(null)),
            exploreSourceClubsProvider.overrideWithValue(
              const AsyncData(<Club>[]),
            ),
            exploreClubsViewModelProvider.overrideWithValue(
              const AsyncData(ExploreViewModel(joinedClubs: [], allClubs: [])),
            ),
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
                        now: DateTime.now(),
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
            home: const ExploreScreen(),
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.text(event.title), findsOneWidget);
      expect(find.byType(CatchCoverStory), findsOneWidget);
      expect(find.text('Map · 1'), findsOneWidget);
      expect(find.text('No clubs in Mumbai yet'), findsNothing);
    });

    testWidgets('ExploreScreen renders external feed when clubs are empty', (
      tester,
    ) async {
      final externalEvent = _buildExternalExploreEvent(
        id: 'external-event-only',
        title: 'District mixer night',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
            uidProvider.overrideWith((ref) => Stream.value(null)),
            exploreSourceClubsProvider.overrideWithValue(
              const AsyncData(<Club>[]),
            ),
            exploreClubsViewModelProvider.overrideWithValue(
              const AsyncData(ExploreViewModel(joinedClubs: [], allClubs: [])),
            ),
            exploreFeedViewModelProvider.overrideWithValue(
              AsyncData(
                ExploreFeedViewModel(
                  items: const [],
                  externalItems: [
                    ExploreExternalEventItem(event: externalEvent),
                  ],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ExploreScreen(),
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.byType(CatchCoverStory), findsNothing);
      expect(find.text(externalEvent.title), findsOneWidget);
      expect(find.text('READ-ONLY SUPPLY · NO CATCH BOOKING'), findsOneWidget);
      expect(find.text('Map · 1'), findsOneWidget);
      expect(find.text('No clubs in Mumbai yet'), findsNothing);
    });

    testWidgets('ExploreScreen filters discover cards from the chip rail', (
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
            exploreSourceClubsProvider.overrideWithValue(
              AsyncData([socialClub, tempoClub]),
            ),
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ExploreScreen(),
          ),
        ),
      );
      await _pumpClubUi(tester);

      // Handoff chrome: scope tabs stay visible, secondary filters move behind
      // the right-aligned filter glyph.
      expect(find.text('Tonight'), findsOneWidget);
      expect(find.text('Tomorrow'), findsNothing);
      expect(find.text('Weekend'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Anytime'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('explore-filter-button')),
        findsOneWidget,
      );
      expect(find.byIcon(CatchIcons.tuneRounded), findsOneWidget);
      expect(find.text('Filters'), findsNothing);
      expect(find.byType(CatchCountPill), findsOneWidget);
      expect(find.text('3 km'), findsNothing);
      expect(find.text('Joined clubs'), findsNothing);
      expect(find.text('Rated 4.5+'), findsNothing);

      await tester.tap(find.text('Tonight'));
      await _pumpClubUi(tester);

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('explore-filter-button')));
      await _pumpClubUi(tester);

      expect(find.text('Explore filters'), findsOneWidget);
      expect(find.text('3 km'), findsOneWidget);
      expect(find.text('Joined clubs'), findsOneWidget);
      expect(find.text('Rated 4.5+'), findsOneWidget);
      expect(find.text('ACTIVITY'), findsOneWidget);
      expect(find.text('AREA'), findsOneWidget);
      expect(_selectChip('3 km'), findsOneWidget);
      expect(_selectChip('Joined clubs'), findsOneWidget);
      expect(_selectChip('Rated 4.5+'), findsOneWidget);
      expect(_selectChip('Social run'), findsOneWidget);
      expect(_selectChip('Dinner'), findsOneWidget);
      expect(_selectChip('Bandra'), findsOneWidget);
      expect(_selectChip('Juhu'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('ExploreFilterSheet toggles secondary filter state', (
      tester,
    ) async {
      final bandraClub = buildClub(id: 'area-bandra', name: 'Bandra Pacers');
      final juhuClub = buildClub(
        id: 'area-juhu',
        name: 'Tempo Queens',
        area: 'Juhu',
      );
      var filters = const ExploreFilterSelection();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => ExploreFilterSheet(
                filters: filters,
                state: ExploreFilterSheetState.from(
                  filters: filters,
                  sourceClubs: [bandraClub, juhuClub],
                ),
                onToggleHighRatedOnly: () {
                  setState(() {
                    filters = filters.copyWith(
                      highRatedOnly: !filters.highRatedOnly,
                    );
                  });
                },
                onToggleActivityTag: (tag) {
                  setState(() {
                    filters = filters.copyWith(
                      activityTag: filters.activityTag == tag ? null : tag,
                    );
                  });
                },
                onToggleArea: (area) {
                  setState(() {
                    filters = filters.copyWith(
                      area: filters.area == area ? null : area,
                    );
                  });
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(_selectChip('Rated 4.5+', active: false), findsOneWidget);
      await tester.tap(_selectChip('Rated 4.5+'));
      await tester.pump();
      expect(filters.highRatedOnly, isTrue);
      expect(_selectChip('Rated 4.5+', active: true), findsOneWidget);

      await tester.ensureVisible(_selectChip('Dinner'));
      await tester.pump();
      await tester.tap(_selectChip('Dinner'));
      await tester.pump();
      expect(filters.activityTag, ActivityKind.dinner.name);
      expect(_selectChip('Dinner', active: true), findsOneWidget);

      await tester.ensureVisible(_selectChip('Juhu'));
      await tester.pump();
      await tester.tap(_selectChip('Juhu'));
      await tester.pump();
      expect(filters.area, 'Juhu');
      expect(_selectChip('Juhu', active: true), findsOneWidget);
    });

    testWidgets('ExploreFilterRail keeps labels whole at phone width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const filters = ExploreFilterSelection(highRatedOnly: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ExploreFilterRail(
              filters: filters,
              state: ExploreFilterRailState.from(filters),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Tonight'), findsOneWidget);
      expect(find.text('Weekend'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Anytime'), findsOneWidget);
      expect(find.byIcon(CatchIcons.tuneRounded), findsOneWidget);
      expect(find.text('Filters'), findsNothing);
      expect(find.text('1'), findsOneWidget);

      final iconCenter = tester.getCenter(find.byIcon(CatchIcons.tuneRounded));
      final badgeCenter = tester.getCenter(find.text('1'));
      expect(badgeCenter.dx, greaterThan(iconCenter.dx));
      expect(badgeCenter.dy, lessThan(iconCenter.dy));
    });

    testWidgets('ExploreScreen map pill opens the map route', (tester) async {
      final club = buildClub(id: 'club-map-pill', name: 'Bandra Pacers');
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const ExploreScreen()),
          GoRoute(
            path: '/map',
            name: Routes.exploreMapScreen.name,
            builder: (_, _) =>
                const ExploreMapScreen(enableNetworkTiles: false),
          ),
        ],
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
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubUi(tester);

      final mapPill = find.widgetWithText(CatchCountPill, 'Map');
      expect(mapPill, findsOneWidget);
      expect(find.byType(ExploreMapScreen), findsNothing);

      await tester.tap(mapPill);
      await _pumpClubUi(tester);

      expect(find.byType(ExploreMapScreen), findsOneWidget);
    });

    testWidgets('ExploreMapScreen can seed selected pin for captures', (
      tester,
    ) async {
      final club = buildClub(id: 'club-map-selected', name: 'Bandra Map Club');
      final selectedEvent = event_test.buildEvent(
        id: 'event-map-selected',
        clubId: club.id,
        meetingPoint: 'Selected Pin Point',
        startingPointLat: 19.0608,
        startingPointLng: 72.8365,
        startTime: DateTime.now().add(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            exploreFeedViewModelProvider.overrideWithValue(
              AsyncData(
                ExploreFeedViewModel(
                  items: [
                    ExploreEventItem(
                      event: selectedEvent,
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
            home: const ExploreMapScreen(
              enableNetworkTiles: false,
              initialSelectedEventId: 'event-map-selected',
            ),
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.selected == true,
        ),
        findsOneWidget,
      );
      expect(find.byType(EventDateRailCard), findsOneWidget);
      expect(find.text('BANDRA MAP CLUB'), findsOneWidget);
    });

    testWidgets('ExploreMapScreen selects pin before navigating from card', (
      tester,
    ) async {
      final club = buildClub(id: 'club-map-nav', name: 'Race Course Road Club');
      final event = event_test.buildEvent(
        id: 'event-map-nav',
        clubId: club.id,
        meetingPoint: 'Race Course Road main gate',
        startingPointLat: 19.0608,
        startingPointLng: 72.8365,
        startTime: DateTime.now().add(const Duration(days: 1)),
      );
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                const ExploreMapScreen(enableNetworkTiles: false),
          ),
          GoRoute(
            path: '/events/:clubId/:eventId',
            name: Routes.eventDetailScreen.name,
            builder: (_, state) {
              final extra = state.extra as EventDetailRouteExtra?;
              return Text(
                [
                  'Event ${state.pathParameters['eventId']}',
                  extra?.transition.name,
                  extra?.heroTag,
                ].whereType<Object>().join(' · '),
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
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
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await _pumpClubUi(tester);

      expect(find.byType(EventDateRailCard), findsNothing);
      expect(find.textContaining('Event event-map-nav'), findsNothing);

      await tester.tap(
        find.bySemanticsLabel('Select Race Course Road main gate'),
      );
      await tester.pump(CatchMotion.fast);

      expect(find.byType(EventDateRailCard), findsOneWidget);
      expect(find.text(event.title), findsOneWidget);
      expect(find.textContaining('Event event-map-nav'), findsNothing);

      await tester.tap(find.text(event.title));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Event event-map-nav · mapSelectedCard · event-ticket-map-event-map-nav',
        ),
        findsOneWidget,
      );
    });

    testWidgets('ExploreMapScreen background tap dismisses selected card', (
      tester,
    ) async {
      final club = buildClub(id: 'club-map-clear', name: 'Map Clear Club');
      final event = event_test.buildEvent(
        id: 'event-map-clear',
        clubId: club.id,
        meetingPoint: 'Clearable Pin Point',
        startingPointLat: 19.0608,
        startingPointLng: 72.8365,
        startTime: DateTime.now().add(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
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
            home: const ExploreMapScreen(enableNetworkTiles: false),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.tap(find.bySemanticsLabel('Select Clearable Pin Point'));
      await tester.pump(CatchMotion.fast);
      expect(find.byType(EventDateRailCard), findsOneWidget);

      await tester.tapAt(const Offset(24, 220));
      await tester.pumpAndSettle();

      expect(find.byType(EventDateRailCard), findsNothing);
    });

    testWidgets(
      'ExploreMapScreen clears selected card when feed refresh drops event',
      (tester) async {
        var showSelectedEvent = true;
        final club = buildClub(
          id: 'club-map-refresh',
          name: 'Map Refresh Club',
        );
        final event = event_test.buildEvent(
          id: 'event-map-refresh',
          clubId: club.id,
          meetingPoint: 'Refresh Pin Point',
          startingPointLat: 19.0608,
          startingPointLng: 72.8365,
          startTime: DateTime.now().add(const Duration(days: 1)),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cityListProvider.overrideWith((ref) async => _testCities),
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
              exploreFeedViewModelProvider.overrideWith((ref) {
                return AsyncData(
                  ExploreFeedViewModel(
                    items: showSelectedEvent
                        ? [
                            ExploreEventItem(
                              event: event,
                              club: club,
                              status: EventTileStatus.open,
                            ),
                          ]
                        : const <ExploreEventItem>[],
                  ),
                );
              }),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ExploreMapScreen(enableNetworkTiles: false),
            ),
          ),
        );
        await _pumpClubUi(tester);

        await tester.tap(find.bySemanticsLabel('Select Refresh Pin Point'));
        await tester.pump(CatchMotion.fast);
        expect(find.byType(EventDateRailCard), findsOneWidget);

        final ProviderContainer container = ProviderScope.containerOf(
          tester.element(find.byType(ExploreMapScreen)),
        );
        showSelectedEvent = false;
        container.invalidate(exploreFeedViewModelProvider);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(EventDateRailCard), findsNothing);
      },
    );

    testWidgets(
      'ExploreMapScreen clears selected card when selected event loses its pin',
      (tester) async {
        var showExactPin = true;
        final club = buildClub(id: 'club-map-pin-loss', name: 'Map Pin Club');
        final pinnedEvent = event_test.buildEvent(
          id: 'event-map-pin-loss',
          clubId: club.id,
          meetingPoint: 'Pin Loss Point',
          startingPointLat: 19.0608,
          startingPointLng: 72.8365,
          startTime: DateTime.now().add(const Duration(days: 1)),
        );
        final unpinnedEvent = event_test.buildEvent(
          id: pinnedEvent.id,
          clubId: club.id,
          meetingPoint: pinnedEvent.meetingPoint,
          startTime: pinnedEvent.startTime,
          endTime: pinnedEvent.endTime,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              cityListProvider.overrideWith((ref) async => _testCities),
              deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
              exploreFeedViewModelProvider.overrideWith((ref) {
                return AsyncData(
                  ExploreFeedViewModel(
                    items: [
                      ExploreEventItem(
                        event: showExactPin ? pinnedEvent : unpinnedEvent,
                        club: club,
                        status: EventTileStatus.open,
                      ),
                    ],
                  ),
                );
              }),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ExploreMapScreen(enableNetworkTiles: false),
            ),
          ),
        );
        await _pumpClubUi(tester);

        await tester.tap(find.bySemanticsLabel('Select Pin Loss Point'));
        await tester.pump(CatchMotion.fast);
        expect(find.byType(EventDateRailCard), findsOneWidget);

        final ProviderContainer container = ProviderScope.containerOf(
          tester.element(find.byType(ExploreMapScreen)),
        );
        showExactPin = false;
        container.invalidate(exploreFeedViewModelProvider);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(EventDateRailCard), findsNothing);
      },
    );

    testWidgets('ExploreScreen shows Explore-specific error copy', (
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
            exploreClubsViewModelProvider.overrideWithValue(
              const AsyncError(
                BackendOperationException(
                  code: 'failed-precondition',
                  message:
                      'This list is still getting set up. Please try again in a moment.',
                  debugMessage:
                      'Firestore query requires a composite required index.',
                  context: BackendErrorContext(
                    service: BackendService.firestore,
                    action: 'watch clubs by location',
                    resource: 'clubs',
                  ),
                  retryable: true,
                ),
                StackTrace.empty,
              ),
            ),
            _emptyExploreFeedOverride,
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ExploreScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Explore unavailable'), findsOneWidget);
      expect(
        find.text(
          'Explore is still getting set up. Please try again in a moment.',
        ),
        findsOneWidget,
      );
      expect(find.text('Reload Explore'), findsOneWidget);
      expect(find.text('Club unavailable'), findsNothing);
      expect(find.text('Reload club'), findsNothing);
    });

    testWidgets('ExploreScreen listens for follow mutation errors', (
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
          exploreClubsViewModelProvider.overrideWithValue(
            AsyncData(
              ExploreViewModel(
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
            home: const ExploreScreen(),
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
              watchClubMembershipProvider(
                club.id,
                'runner-1',
              ).overrideWith((ref) => Stream.value(null)),
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
            uidProvider.overrideWith((ref) => Stream.value(null)),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
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
            uidProvider.overrideWith((ref) => Stream.value(null)),
            watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
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
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
          ),
          watchClubMembershipProvider(
            'club-1',
            'runner-1',
          ).overrideWith((ref) => Stream.value(null)),
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
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(uid: 'runner-1')),
          ),
          watchClubMembershipProvider(
            'club-1',
            'runner-1',
          ).overrideWith((ref) => Stream.value(null)),
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
        ownerUserId: 'host-1',
        name: 'Morning Miles',
        area: 'Palasia',
        location: 'in-mp-indore',
        description: 'Indore morning loops.',
      );
      final container = ProviderContainer(
        overrides: [uidProvider.overrideWith((ref) => Stream.value('host-1'))],
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

      expect(find.text('Edit club'), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('Event defaults'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
      expect(find.widgetWithText(TextField, 'Morning Miles'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Palasia'), findsOneWidget);
      expect(find.text('Indore'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Indore morning loops.'),
        findsOneWidget,
      );
      expect(find.text('Default event policy'), findsOneWidget);
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

        await _enterCreateClubText(tester, 'Instagram', '');
        await _enterCreateClubText(tester, 'Phone', '');
        await _enterCreateClubText(tester, 'Email', '');

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
          find.widgetWithText(CatchField, 'Club name'),
          'Sunset Striders',
        );
        await tester.enterText(
          find.widgetWithText(CatchField, 'Area / neighbourhood'),
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
          find.widgetWithText(CatchField, 'Description'),
          'Easy social club',
        );
        tester.testTextInput.hide();
        await tester.pump();

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);

        expect(find.text('Default event policy'), findsOneWidget);
        expect(_field('Cohort caps'), findsOneWidget);
        expect(_selectChip('OPEN', active: true), findsOneWidget);

        await tester.tap(find.text('Next'));
        await _pumpClubUi(tester);

        expect(find.text('Default event success'), findsOneWidget);
        expect(_field('Default event success'), findsOneWidget);

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

Finder _topLevelSearchField() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CatchSearchField && widget.mode != CatchSearchFieldMode.field,
  );
}

Finder _selectChip(String label, {bool? active}) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CatchSelectChip &&
        widget.label == label &&
        (active == null || widget.active == active),
  );
}

ExternalEvent _buildExternalExploreEvent({
  required String id,
  required String title,
}) {
  final startTime = DateTime(2026, 7, 8, 19);
  return ExternalEvent(
    id: id,
    canonicalHostId: 'host-afterfly',
    compatibilityClubId: 'club-afterfly',
    title: title,
    description: 'A reviewed external event.',
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 2)),
    meetingPoint: 'Bandra Amphitheatre',
    activityKind: ActivityKind.singlesMixer,
    interactionModel: EventInteractionModel.freeFormMixer,
    status: 'active',
    publicationStatus: 'public',
    citySlug: 'mumbai',
    externalLinks: const [
      ExternalEventLink(
        platform: 'district',
        url: 'https://district.example/events/external-event-only',
        linkType: 'booking_or_event_page',
        sourceEventKey: 'external-source-key',
        candidateId: 'candidate-external',
        primary: true,
      ),
    ],
  );
}

Finder _field(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == label,
  );
}

Future<void> _enterCreateClubText(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == label,
  );
  await tester.ensureVisible(field);
  await tester.pump();
  await tester.enterText(field, value);
  await tester.pump();
}
