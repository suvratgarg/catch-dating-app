import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_map_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_body.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_city_picker.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_empty_state.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_event_type_browse_grid.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_events_section.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_filter_rail.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_header.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_list.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_peek_rail.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _viewerUid = 'widgetbook-explore-viewer';
final _now = DateTime(2026, 6, 22, 9);

const _mumbai = CityData(
  name: 'mumbai',
  label: 'Mumbai',
  latitude: 19.076,
  longitude: 72.8777,
);

const _delhi = CityData(
  name: 'delhi',
  label: 'Delhi',
  latitude: 28.7041,
  longitude: 77.1025,
);

final _viewer = UserProfile(
  uid: _viewerUid,
  name: 'Neha Kapoor',
  firstName: 'Neha',
  lastName: 'Kapoor',
  displayName: 'Neha',
  dateOfBirth: DateTime(1996, 4, 12),
  gender: Gender.woman,
  phoneNumber: '+919876543210',
  profileComplete: true,
  city: 'Mumbai',
  interestedInGenders: const [Gender.man],
);

final _clubs = [
  _club(
    id: 'widgetbook-sea-face-social',
    name: 'Sea Face Social',
    area: 'Bandra',
    hostName: 'Mira Shah',
    memberCount: 412,
    rating: 4.9,
    reviewCount: 73,
    nextEventAt: DateTime(2026, 6, 24, 6, 30),
    nextEventLabel: 'Wed 6:30 AM',
    tags: const ['running', 'coffee', 'new members'],
    photoSeed: '1502904550040-7534597429ae',
  ),
  _club(
    id: 'widgetbook-long-table-club',
    name: 'Long Table Club',
    area: 'Fort',
    hostName: 'Ira Mehta',
    memberCount: 96,
    rating: 4.8,
    reviewCount: 31,
    nextEventAt: DateTime(2026, 6, 24, 20),
    nextEventLabel: 'Wed 8:00 PM',
    tags: const ['dinner', 'conversation', 'first-timers'],
    photoSeed: '1517245386807-bb43f82c33c4',
  ),
  _club(
    id: 'widgetbook-open-court',
    name: 'Open Court',
    area: 'Juhu',
    hostName: null,
    memberCount: 188,
    rating: 4.7,
    reviewCount: 24,
    nextEventAt: DateTime(2026, 6, 25, 18),
    nextEventLabel: 'Thu 6:00 PM',
    tags: const ['pickleball', 'padel', 'teams'],
    photoSeed: '1521412644187-c49fa049e84d',
  ),
];

final _joinedClubIds = {_clubs.first.id};

final _feedItems = [
  _item(
    event: _event(
      id: 'widgetbook-seaface-run',
      club: _clubs[0],
      startTime: DateTime(2026, 6, 24, 6, 30),
      meetingPoint: 'Carter Road Jetty',
      activityKind: ActivityKind.socialRun,
      bookedCount: 9,
      capacityLimit: 12,
      distanceKm: 5,
      distanceFromUserKm: 1.2,
    ),
    club: _clubs[0],
    distanceFromUserKm: 1.2,
    isJoinedClubMember: true,
  ),
  _item(
    event: _event(
      id: 'widgetbook-long-table-dinner',
      club: _clubs[1],
      startTime: DateTime(2026, 6, 24, 20),
      meetingPoint: 'Kala Ghoda table room',
      activityKind: ActivityKind.dinner,
      bookedCount: 10,
      capacityLimit: 12,
      priceInPaise: 140000,
      distanceKm: 0,
      distanceFromUserKm: 3.6,
    ),
    club: _clubs[1],
    distanceFromUserKm: 3.6,
  ),
  _item(
    event: _event(
      id: 'widgetbook-open-court-pickleball',
      club: _clubs[2],
      startTime: DateTime(2026, 6, 25, 18),
      meetingPoint: 'Juhu court 2',
      activityKind: ActivityKind.pickleball,
      bookedCount: 16,
      capacityLimit: 20,
      distanceKm: 0,
      distanceFromUserKm: 4.1,
    ),
    club: _clubs[2],
    distanceFromUserKm: 4.1,
  ),
  _item(
    event: _event(
      id: 'widgetbook-seaface-walk',
      club: _clubs[0],
      startTime: DateTime(2026, 6, 26, 7),
      meetingPoint: 'Bandra Fort gate',
      activityKind: ActivityKind.walking,
      bookedCount: 21,
      capacityLimit: 28,
      distanceKm: 3,
      distanceFromUserKm: 1.8,
    ),
    club: _clubs[0],
    distanceFromUserKm: 1.8,
    isJoinedClubMember: true,
  ),
  _item(
    event: _event(
      id: 'widgetbook-brunch',
      club: _clubs[1],
      startTime: DateTime(2026, 6, 27, 11),
      meetingPoint: 'Colaba reading room',
      activityKind: ActivityKind.pubQuiz,
      bookedCount: 6,
      capacityLimit: 10,
      priceInPaise: 90000,
      distanceKm: 0,
      distanceFromUserKm: 4.8,
    ),
    club: _clubs[1],
    distanceFromUserKm: 4.8,
  ),
];

@widgetbook.UseCase(
  name: 'Screen states',
  type: ExploreScreen,
  path: '[Explore]/Screen',
)
Widget exploreScreenStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreScreen',
    catalogId: 'screen.explore.discovery',
    children: [
      _StateCard(
        label: 'discovery feed',
        description:
            'Default browse chrome with mixed event/club discovery and map pill count.',
        child: _DeviceFrame(
          child: _ExploreScope(
            child: const ExploreScreen(enableEventMapNetworkTiles: false),
          ),
        ),
      ),
      _StateCard(
        label: 'loading with sticky chrome',
        child: _DeviceFrame(
          height: 620,
          child: _ExploreScope(
            viewModel: const AsyncLoading<ExploreViewModel>(),
            feed: const AsyncLoading<ExploreFeedViewModel>(),
            child: const ExploreScreen(enableEventMapNetworkTiles: false),
          ),
        ),
      ),
      _StateCard(
        label: 'club source error',
        child: _DeviceFrame(
          height: 620,
          child: _ExploreScope(
            sourceClubs: AsyncError<List<Club>>(
              StateError('Widgetbook club source failed'),
              StackTrace.empty,
            ),
            viewModel: AsyncError<ExploreViewModel>(
              StateError('Widgetbook club source failed'),
              StackTrace.empty,
            ),
            child: const ExploreScreen(enableEventMapNetworkTiles: false),
          ),
        ),
      ),
      _StateCard(
        label: 'search and filters empty',
        child: _DeviceFrame(
          height: 620,
          child: _ExploreScope(
            searchQuery: 'supperclub for marathoners near worli',
            seedFilters: const _FilterSeed(
              distance: ExploreDistanceFilter.threeKm,
              activity: ActivityKind.dinner,
            ),
            viewModel: const AsyncData(
              ExploreViewModel(joinedClubs: [], allClubs: []),
            ),
            feed: const AsyncData(ExploreFeedViewModel(items: [])),
            child: const ExploreScreen(enableEventMapNetworkTiles: false),
          ),
        ),
      ),
      _StateCard(
        label: 'anonymous guest',
        child: _DeviceFrame(
          child: _ExploreScope(
            uid: null,
            child: const ExploreScreen(enableEventMapNetworkTiles: false),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _MediaOverride(
          textScaler: const TextScaler.linear(2),
          child: _DeviceFrame(
            height: 760,
            child: _ExploreScope(
              child: const ExploreScreen(enableEventMapNetworkTiles: false),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _MediaOverride(
          disableAnimations: true,
          child: _DeviceFrame(
            child: _ExploreScope(
              child: const ExploreScreen(enableEventMapNetworkTiles: false),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Body sliver states',
  type: ExploreBody,
  path: '[Explore]/Sections',
)
Widget exploreBodyStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreBody',
    catalogId: 'section.explore.body',
    children: [
      _StateCard(
        label: 'mixed body',
        child: _SliverFrame(
          child: _ExploreScope(
            child: CustomScrollView(
              slivers: [
                ExploreBody(
                  viewModel: ExploreViewModel.partition(
                    clubs: _clubs,
                    joinedClubIds: _joinedClubIds,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'List sliver states',
  type: ExploreList,
  path: '[Explore]/Sections',
)
Widget exploreListStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreList',
    catalogId: 'section.explore.list',
    children: [
      _StateCard(
        label: 'provider-backed list',
        child: _SliverFrame(
          child: _ExploreScope(
            child: CustomScrollView(slivers: [ExploreList()]),
          ),
        ),
      ),
      _StateCard(
        label: 'empty search',
        child: _SliverFrame(
          height: 320,
          child: _ExploreScope(
            searchQuery: 'silent supper cycling crew',
            viewModel: const AsyncData(
              ExploreViewModel(joinedClubs: [], allClubs: []),
            ),
            child: CustomScrollView(slivers: [ExploreList()]),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'City picker states',
  type: ExploreCityPicker,
  path: '[Explore]/Controls',
)
Widget exploreCityPickerStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreCityPicker',
    catalogId: 'control.explore.city_picker',
    children: [
      _StateCard(
        label: 'ready',
        child: _ExploreScope(child: const Center(child: ExploreCityPicker())),
      ),
      _StateCard(
        label: 'city source loading',
        child: _ExploreScope(
          child: ProviderScope(
            overrides: [
              cityListProvider.overrideWith(
                (ref) => Future<List<CityData>>.delayed(
                  const Duration(minutes: 1),
                  () => const [_mumbai],
                ),
              ),
            ],
            child: const Center(child: ExploreCityPicker()),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cover header states',
  type: ExploreDiscoveryCoverHeader,
  path: '[Explore]/Sections',
)
Widget exploreDiscoveryCoverHeaderStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreDiscoveryCoverHeader',
    catalogId: 'section.explore.discovery_cover_header',
    children: [
      _StateCard(
        label: 'featured event',
        child: _DeviceFrame(
          height: 360,
          child: _ExploreScope(child: const ExploreDiscoveryCoverHeader()),
        ),
      ),
      _StateCard(
        label: 'no featured event',
        child: _DeviceFrame(
          height: 180,
          child: _ExploreScope(
            feed: const AsyncData(ExploreFeedViewModel(items: [])),
            child: const ExploreDiscoveryCoverHeader(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Filter sheet states',
  type: ExploreFilterSheet,
  path: '[Explore]/Controls',
)
Widget exploreFilterSheetStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreFilterSheet',
    catalogId: 'control.explore.filter_sheet',
    children: [
      _StateCard(
        label: 'default',
        child: _SheetFrame(
          child: _ExploreScope(
            child: const AbsorbPointer(child: ExploreFilterSheet()),
          ),
        ),
      ),
      _StateCard(
        label: 'active filters',
        child: _SheetFrame(
          child: _ExploreScope(
            seedFilters: const _FilterSeed(
              distance: ExploreDistanceFilter.threeKm,
              joinedOnly: true,
            ),
            child: const AbsorbPointer(child: ExploreFilterSheet()),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Peek rail states',
  type: ExplorePeekRailContent,
  path: '[Explore]/Sections',
)
Widget explorePeekRailContentStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExplorePeekRailContent',
    catalogId: 'section.explore.peek_rail_content',
    children: [
      _StateCard(
        label: 'nearby rail',
        child: _ExploreScope(
          child: ExplorePeekRailContent(
            items: _feedItems,
            selectedEventId: null,
            onEventTapped: (_) {},
            onSeeAll: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'selected event',
        child: _ExploreScope(
          child: ExplorePeekRailContent(
            items: _feedItems,
            selectedEventId: _feedItems.first.event.id,
            onEventTapped: (_) {},
            onSeeAll: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Chrome states',
  type: ExploreBrowseHeaderContent,
  path: '[Explore]/Sections',
)
Widget exploreBrowseHeaderContentStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreBrowseHeaderContent',
    catalogId: 'section.explore.chrome',
    children: [
      _StateCard(
        label: 'default',
        child: _ExploreScope(child: const ExploreBrowseHeaderContent()),
      ),
      _StateCard(
        label: 'search active',
        child: _ExploreScope(
          searchQuery: 'pickleball dinner after work',
          child: const ExploreBrowseHeaderContent(),
        ),
      ),
      _StateCard(
        label: 'long search',
        child: _ExploreScope(
          searchQuery: 'long-table supper for first timers in south mumbai',
          child: const ExploreBrowseHeaderContent(),
        ),
      ),
      _StateCard(
        label: 'city control only',
        child: _ExploreScope(
          child: const ExploreBrowseHeaderContent(showSearchAction: false),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Filter states',
  type: ExploreFilterRail,
  path: '[Explore]/Sections',
)
Widget exploreFilterRailStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreFilterRail',
    catalogId: 'section.explore.filters',
    children: [
      _StateCard(
        label: 'default time scope',
        child: _ExploreScope(child: const ExploreFilterRail()),
      ),
      _StateCard(
        label: 'active distance and activity',
        child: _ExploreScope(
          seedFilters: const _FilterSeed(
            time: ExploreTimeFilter.weekend,
            distance: ExploreDistanceFilter.threeKm,
            activity: ActivityKind.pickleball,
            highRatedOnly: true,
          ),
          child: const ExploreFilterRail(),
        ),
      ),
      _StateCard(
        label: 'joined only',
        child: _ExploreScope(
          seedFilters: const _FilterSeed(joinedOnly: true),
          child: const ExploreFilterRail(),
        ),
      ),
      _StateCard(
        label: 'sheet content',
        description:
            'The same public sheet widget the rail opens from the filter pill.',
        child: _SheetFrame(
          child: _ExploreScope(
            seedFilters: const _FilterSeed(
              distance: ExploreDistanceFilter.fiveKm,
              joinedOnly: true,
            ),
            child: const AbsorbPointer(child: ExploreFilterSheet()),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Feed states',
  type: ExploreEventsSection,
  path: '[Explore]/Sections',
)
Widget exploreEventsSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreEventsSection',
    catalogId: 'section.explore.feed',
    children: [
      _StateCard(
        label: 'mixed event and club feed',
        child: _SliverFrame(
          child: _ExploreScope(
            child: const AbsorbPointer(child: _ExploreEventsSliverPreview()),
          ),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: _SliverFrame(
          height: 320,
          child: _ExploreScope(
            feed: const AsyncLoading<ExploreFeedViewModel>(),
            child: const _ExploreEventsSliverPreview(),
          ),
        ),
      ),
      _StateCard(
        label: 'feed error',
        child: _SliverFrame(
          height: 300,
          child: _ExploreScope(
            feed: AsyncError<ExploreFeedViewModel>(
              StateError('Widgetbook Explore feed failed'),
              StackTrace.empty,
            ),
            child: const _ExploreEventsSliverPreview(),
          ),
        ),
      ),
      _StateCard(
        label: 'search-only empty',
        child: _SliverFrame(
          height: 300,
          child: _ExploreScope(
            searchQuery: 'silent supper cycling crew',
            feed: const AsyncData(ExploreFeedViewModel(items: [])),
            child: const _ExploreEventsSliverPreview(),
          ),
        ),
      ),
      _StateCard(
        label: 'filter-only empty',
        child: _SliverFrame(
          height: 300,
          child: _ExploreScope(
            seedFilters: const _FilterSeed(
              time: ExploreTimeFilter.weekend,
              distance: ExploreDistanceFilter.tenKm,
            ),
            feed: const AsyncData(ExploreFeedViewModel(items: [])),
            child: const _ExploreEventsSliverPreview(),
          ),
        ),
      ),
      _StateCard(
        label: 'combined empty',
        child: _SliverFrame(
          height: 300,
          child: _ExploreScope(
            searchQuery: 'late-night padel supper',
            seedFilters: const _FilterSeed(
              distance: ExploreDistanceFilter.threeKm,
              activity: ActivityKind.padel,
            ),
            feed: const AsyncData(ExploreFeedViewModel(items: [])),
            child: const _ExploreEventsSliverPreview(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Empty states',
  type: ExploreEmptyState,
  path: '[Explore]/Sections',
)
Widget exploreEmptyStateStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreEmptyState',
    catalogId: 'section.explore.empty_error',
    children: [
      _StateCard(
        label: 'empty city',
        child: ExploreEmptyState(
          cityLabel: 'Mumbai',
          action: _secondaryAction('Try another city'),
        ),
      ),
      _StateCard(
        label: 'search only',
        child: ExploreEmptyState.noSearchResults(
          hasFilters: false,
          action: _secondaryAction('Clear search'),
        ),
      ),
      _StateCard(
        label: 'filter only',
        child: ExploreEmptyState.noFilterResults(
          action: _secondaryAction('Clear filters'),
        ),
      ),
      _StateCard(
        label: 'search plus filters',
        child: ExploreEmptyState.noFilteredSearchResults(
          action: _secondaryAction('Clear search and filters'),
        ),
      ),
      _StateCard(
        label: 'offline copy candidate',
        child: ExploreEmptyState.generic(
          title: 'Explore is offline',
          message:
              'Check your connection and try again to reload clubs and events.',
          action: _secondaryAction('Retry'),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Activity states',
  type: ExploreEventTypeBrowseGrid,
  path: '[Explore]/Sections',
)
Widget exploreEventTypeBrowseGridStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreEventTypeBrowseGrid',
    catalogId: 'section.explore.activity_grid',
    children: [
      _StateCard(
        label: 'counts ready',
        child: _ExploreScope(child: const ExploreEventTypeBrowseGrid()),
      ),
      _StateCard(
        label: 'active activity',
        child: _ExploreScope(
          seedFilters: const _FilterSeed(activity: ActivityKind.dinner),
          child: const ExploreEventTypeBrowseGrid(),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: _ExploreScope(
          feed: const AsyncLoading<ExploreFeedViewModel>(),
          child: const ExploreEventTypeBrowseGrid(),
        ),
      ),
      _StateCard(
        label: 'narrow width',
        child: SizedBox(
          width: 280,
          child: _ExploreScope(child: const ExploreEventTypeBrowseGrid()),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Map launcher states',
  type: CatchCountPill,
  path: '[Explore]/Sections',
)
Widget exploreMapLauncherStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchCountPill map launcher',
    catalogId: 'section.explore.map_launcher',
    children: [
      _StateCard(
        label: 'empty count',
        child: _MapPillFrame(
          child: CatchCountPill(
            label: 'Map',
            icon: CatchIcons.map,
            semanticLabel: 'Map',
          ),
        ),
      ),
      _StateCard(
        label: 'with count',
        child: _MapPillFrame(
          child: CatchCountPill(
            label: 'Map · 6',
            icon: CatchIcons.map,
            semanticLabel: 'Map, 6 events',
          ),
        ),
      ),
      _StateCard(
        label: 'pressed review target',
        child: _MapPillFrame(
          child: CatchCountPill(
            label: 'Map · 12',
            icon: CatchIcons.map,
            semanticLabel: 'Map, 12 events',
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _MediaOverride(
          textScaler: const TextScaler.linear(2),
          child: _MapPillFrame(
            child: CatchCountPill(
              label: 'Map · 12',
              icon: CatchIcons.map,
              semanticLabel: 'Map, 12 events',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Map route states',
  type: ExploreMapScreen,
  path: '[Explore]/Sections',
)
Widget exploreMapRouteStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreMapScreen',
    catalogId: 'section.explore.map_route',
    children: [
      _StateCard(
        label: 'pins ready',
        child: _DeviceFrame(
          height: 520,
          child: _ExploreScope(
            child: const ExploreMapScreen(enableNetworkTiles: false),
          ),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: _DeviceFrame(
          height: 420,
          child: _ExploreScope(
            feed: const AsyncLoading<ExploreFeedViewModel>(),
            child: const ExploreMapScreen(enableNetworkTiles: false),
          ),
        ),
      ),
      _StateCard(
        label: 'empty',
        child: _DeviceFrame(
          height: 420,
          child: _ExploreScope(
            feed: const AsyncData(ExploreFeedViewModel(items: [])),
            child: const ExploreMapScreen(enableNetworkTiles: false),
          ),
        ),
      ),
      _StateCard(
        label: 'error',
        child: _DeviceFrame(
          height: 420,
          child: _ExploreScope(
            feed: AsyncError<ExploreFeedViewModel>(
              StateError('Widgetbook map feed failed'),
              StackTrace.empty,
            ),
            child: const ExploreMapScreen(enableNetworkTiles: false),
          ),
        ),
      ),
      _StateCard(
        label: 'distance ring active',
        child: _DeviceFrame(
          height: 520,
          child: _ExploreScope(
            seedFilters: const _FilterSeed(
              distance: ExploreDistanceFilter.threeKm,
            ),
            child: const ExploreMapScreen(enableNetworkTiles: false),
          ),
        ),
      ),
    ],
  );
}

class _ExploreScope extends StatelessWidget {
  const _ExploreScope({
    required this.child,
    this.searchQuery,
    this.seedFilters = const _FilterSeed(),
    this.sourceClubs,
    this.viewModel,
    this.feed,
    this.uid = _viewerUid,
  });

  final Widget child;
  final String? searchQuery;
  final _FilterSeed seedFilters;
  final AsyncValue<List<Club>>? sourceClubs;
  final AsyncValue<ExploreViewModel>? viewModel;
  final AsyncValue<ExploreFeedViewModel>? feed;
  final String? uid;

  @override
  Widget build(BuildContext context) {
    final effectiveSourceClubs =
        sourceClubs ?? AsyncData<List<Club>>(List.unmodifiable(_clubs));
    final effectiveViewModel =
        viewModel ??
        AsyncData(
          ExploreViewModel.partition(
            clubs: _clubs,
            joinedClubIds: _joinedClubIds,
          ),
        );
    final effectiveFeed =
        feed ??
        AsyncData(ExploreFeedViewModel(items: List.unmodifiable(_feedItems)));
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream<String?>.value(uid)),
        watchUserProfileProvider.overrideWith(
          (ref) => Stream<UserProfile?>.value(uid == null ? null : _viewer),
        ),
        cityListProvider.overrideWith((ref) async => const [_mumbai, _delhi]),
        deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
        exploreSourceClubsProvider.overrideWithValue(effectiveSourceClubs),
        exploreViewModelProvider.overrideWithValue(effectiveViewModel),
        exploreFeedViewModelProvider.overrideWithValue(effectiveFeed),
      ],
      child: _SeedExploreState(
        searchQuery: searchQuery,
        seedFilters: seedFilters,
        child: child,
      ),
    );
  }
}

class _SeedExploreState extends ConsumerStatefulWidget {
  const _SeedExploreState({
    required this.child,
    this.searchQuery,
    this.seedFilters = const _FilterSeed(),
  });

  final Widget child;
  final String? searchQuery;
  final _FilterSeed seedFilters;

  @override
  ConsumerState<_SeedExploreState> createState() => _SeedExploreStateState();
}

class _SeedExploreStateState extends ConsumerState<_SeedExploreState> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(selectedExploreCityProvider.notifier).setCity(_mumbai);
      final query = widget.searchQuery;
      if (query != null) {
        ref.read(exploreSearchQueryProvider.notifier).setQuery(query);
      }
      widget.seedFilters.apply(ref.read(exploreFiltersProvider.notifier));
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FilterSeed {
  const _FilterSeed({
    this.time,
    this.distance,
    this.activity,
    this.joinedOnly = false,
    this.highRatedOnly = false,
  });

  final ExploreTimeFilter? time;
  final ExploreDistanceFilter? distance;
  final ActivityKind? activity;
  final bool joinedOnly;
  final bool highRatedOnly;

  void apply(ExploreFilters notifier) {
    final seedTime = time;
    if (seedTime != null) notifier.setTimeFilter(seedTime);
    final seedDistance = distance;
    if (seedDistance != null) notifier.setDistanceFilter(seedDistance);
    final seedActivity = activity;
    if (seedActivity != null) notifier.toggleActivityTag(seedActivity.name);
    if (joinedOnly) notifier.toggleJoinedOnly();
    if (highRatedOnly) notifier.toggleHighRatedOnly();
  }
}

class _NoDeviceLocation extends DeviceLocation {
  @override
  Future<LocationCoordinate?> build() async => null;
}

class _ExploreEventsSliverPreview extends ConsumerWidget {
  const _ExploreEventsSliverPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: buildExploreEventsSlivers(
        ref,
        pinnedDayHeaders: false,
        candidateClubs: _clubs,
        joinedClubIds: _joinedClubIds,
      ),
    );
  }
}

class _CatalogScreen extends StatelessWidget {
  const _CatalogScreen({
    required this.title,
    required this.catalogId,
    required this.children,
  });

  final String title;
  final String catalogId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CatchInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CatchTextStyles.titleL(context)),
              gapH4,
              Text(
                catalogId,
                style: CatchTextStyles.monoLabel(context, color: t.ink2),
              ),
              gapH24,
              for (final child in children) ...[child, gapH20],
            ],
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.label,
    required this.child,
    this.description,
  });

  final String label;
  final Widget child;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            if (description != null) ...[
              gapH6,
              Text(
                description!,
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ],
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child, this.height = 720});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: height, child: child),
          ),
        ),
      ),
    );
  }
}

class _SliverFrame extends StatelessWidget {
  const _SliverFrame({required this.child, this.height = 560});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.bg,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: SizedBox(height: height, child: child),
        ),
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: child,
        ),
      ),
    );
  }
}

class _MapPillFrame extends StatelessWidget {
  const _MapPillFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.bg,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: SizedBox(
        width: 220,
        height: 96,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(CatchSpacing.s4),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _MediaOverride extends StatelessWidget {
  const _MediaOverride({
    required this.child,
    this.textScaler,
    this.disableAnimations,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool? disableAnimations;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: textScaler ?? media.textScaler,
        disableAnimations: disableAnimations ?? media.disableAnimations,
      ),
      child: child,
    );
  }
}

Club _club({
  required String id,
  required String name,
  required String area,
  required String? hostName,
  required int memberCount,
  required double rating,
  required int reviewCount,
  required DateTime nextEventAt,
  required String nextEventLabel,
  required List<String> tags,
  required String photoSeed,
}) {
  return Club(
    id: id,
    name: name,
    description:
        'A low-pressure club for consistent plans, friendly hosts, and people who make room for first-timers.',
    location: _mumbai.name,
    area: area,
    hostUserId: hostName == null ? null : 'host-$id',
    hostName: hostName,
    ownerUserId: hostName == null ? null : 'host-$id',
    createdAt: DateTime(2025, 9, 12),
    imageUrl: 'https://images.unsplash.com/photo-$photoSeed?w=1200&q=80',
    clubPhotos: [_photo('club-$id', 0, photoSeed)],
    tags: tags,
    memberCount: memberCount,
    rating: rating,
    reviewCount: reviewCount,
    nextEventAt: nextEventAt,
    nextEventLabel: nextEventLabel,
  );
}

Event _event({
  required String id,
  required Club club,
  required DateTime startTime,
  required String meetingPoint,
  required ActivityKind activityKind,
  required int bookedCount,
  required int capacityLimit,
  required double distanceKm,
  required double distanceFromUserKm,
  int priceInPaise = 0,
}) {
  return Event(
    id: id,
    clubId: club.id,
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 1, minutes: 45)),
    meetingPoint: meetingPoint,
    meetingLocation: EventMeetingLocation.legacy(
      name: meetingPoint,
      latitude: _mumbai.latitude + distanceFromUserKm / 100,
      longitude: _mumbai.longitude + distanceFromUserKm / 100,
      notes: club.area,
    ),
    photoUrl: club.imageUrl,
    eventPhotos: [
      _photo('event-$id-main', 0, '1500530855697-b586d89ba3ee'),
      _photo('event-$id-group', 1, '1529156069898-49953e39b3ac'),
    ],
    eventFormat: EventFormatSnapshot.fromActivityKind(activityKind),
    distanceKm: distanceKm,
    pace: PaceLevel.easy,
    capacityLimit: capacityLimit,
    description:
        'A hosted plan with clear arrival cues, a welcoming first ten minutes, and enough structure to keep the room moving.',
    priceInPaise: priceInPaise,
    bookedCount: bookedCount,
    waitlistedCount: 2,
    eventPolicy: EventPolicyBundle.openEvent(
      capacityLimit: capacityLimit,
      basePriceInPaise: priceInPaise,
    ),
  );
}

ExploreEventItem _item({
  required Event event,
  required Club club,
  required double distanceFromUserKm,
  bool isJoinedClubMember = false,
}) {
  return ExploreEventItem(
    event: event,
    club: club,
    availability: resolveViewerEventAvailability(
      event: event,
      userProfile: _viewer,
    ),
    distanceFromUserKm: distanceFromUserKm,
    isJoinedClubMember: isJoinedClubMember,
  );
}

UploadedPhoto _photo(String id, int position, String seed) {
  return UploadedPhoto.fromUpload(
    url: 'https://images.unsplash.com/photo-$seed?w=800&q=80',
    storagePath: 'widgetbook/explore/$id.jpg',
    position: position,
    now: _now.add(Duration(minutes: position)),
  );
}

Widget _secondaryAction(String label) {
  return CatchButton(
    label: label,
    variant: CatchButtonVariant.secondary,
    onPressed: _noop,
  );
}

void _noop() {}
