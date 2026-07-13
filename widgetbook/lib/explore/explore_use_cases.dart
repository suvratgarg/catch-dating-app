import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/external_event.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_map_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/catch_cover_story.dart';
import 'package:catch_dating_app/explore/presentation/widgets/catch_cross_paths_card.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_body.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_city_picker.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_event_type_browse_grid.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_events_section.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_filter_rail.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_header.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_list.dart';
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

ExploreCityPickerState _cityPickerState({
  CityData? selectedCity,
  Iterable<CityData> cities = const [_mumbai, _delhi],
  bool cityListLoading = false,
  Object? cityListError,
}) {
  return ExploreCityPickerState.from(
    selectedCity: selectedCity ?? _mumbai,
    cities: cities,
    cityListLoading: cityListLoading,
    cityListError: cityListError,
  );
}

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

final _externalFeedItem = ExploreExternalEventItem(
  event: _externalEvent(
    id: 'widgetbook-external-jazz-supper',
    title: 'Jazz supper table',
    startTime: DateTime(2026, 6, 25, 20),
    meetingPoint: 'Blue room terrace',
    activityKind: ActivityKind.dinner,
    priceDisplayText: 'Rs 1,800',
    sourcePlatform: 'luma',
  ),
  distanceFromUserKm: 2.4,
);

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
        child: _DeviceFrame(child: _ExploreScope(child: const ExploreScreen())),
      ),
      _StateCard(
        label: 'loading with sticky chrome',
        child: _DeviceFrame(
          height: 620,
          child: _ExploreScope(
            viewModel: const AsyncLoading<ExploreViewModel>(),
            feed: const AsyncLoading<ExploreFeedViewModel>(),
            child: const ExploreScreen(),
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
            child: const ExploreScreen(),
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
            child: const ExploreScreen(),
          ),
        ),
      ),
      _StateCard(
        label: 'anonymous guest',
        child: _DeviceFrame(
          child: _ExploreScope(uid: null, child: const ExploreScreen()),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _MediaOverride(
          textScaler: const TextScaler.linear(2),
          child: _DeviceFrame(
            height: 760,
            child: _ExploreScope(child: const ExploreScreen()),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _MediaOverride(
          disableAnimations: true,
          child: _DeviceFrame(
            child: _ExploreScope(child: const ExploreScreen()),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Skeleton list states',
  type: ExploreSkeletonList,
  path: '[Explore]/Sections',
)
Widget exploreSkeletonListStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreSkeletonList',
    catalogId: 'section.explore.skeleton_list',
    children: [
      _StateCard(
        label: 'route loading stack',
        child: const _DeviceFrame(
          height: 360,
          child: SingleChildScrollView(
            padding: CatchInsets.pageBody,
            child: ExploreSkeletonList(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Body sliver states',
  type: ExploreList,
  path: '[Explore]/Sections',
)
Widget exploreBodyStates(BuildContext context) {
  return _CatalogScreen(
    title: 'buildExploreBodySlivers',
    catalogId: 'section.explore.body_slivers',
    children: [
      _StateCard(
        label: 'mixed body',
        child: _SliverFrame(
          child: _ExploreScope(child: const _ExploreBodySliverPreview()),
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
  name: 'List empty state',
  type: ExploreListEmptyState,
  path: '[Explore]/Sections',
)
Widget exploreListEmptyStateStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreListEmptyState',
    catalogId: 'section.explore.list.empty_state',
    children: [
      _StateCard(
        label: 'city empty',
        child: _DeviceFrame(
          height: 360,
          child: _ExploreScope(
            child: const ExploreListEmptyState(
              cityLabel: 'Mumbai',
              hasSearch: false,
              filters: ExploreFilterSelection(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'search empty',
        child: _DeviceFrame(
          height: 360,
          child: _ExploreScope(
            child: const ExploreListEmptyState(
              cityLabel: 'Mumbai',
              hasSearch: true,
              filters: ExploreFilterSelection(),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'search and filters empty',
        child: _DeviceFrame(
          height: 360,
          child: _ExploreScope(
            child: const ExploreListEmptyState(
              cityLabel: 'Mumbai',
              hasSearch: true,
              filters: ExploreFilterSelection(
                distanceFilter: ExploreDistanceFilter.threeKm,
                activityTag: 'dinner',
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Directory skeleton list',
  type: ClubDirectorySkeletonList,
  path: '[Explore]/Sections',
)
Widget clubDirectorySkeletonListStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubDirectorySkeletonList',
    catalogId: 'section.explore.list.directory_skeleton_list',
    children: [
      _StateCard(
        label: 'loading stack',
        child: const _DeviceFrame(
          height: 640,
          child: SingleChildScrollView(
            padding: CatchInsets.pageBody,
            child: ClubDirectorySkeletonList(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Directory skeleton card',
  type: ClubDirectorySkeletonCard,
  path: '[Explore]/Sections',
)
Widget clubDirectorySkeletonCardStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubDirectorySkeletonCard',
    catalogId: 'section.explore.list.directory_skeleton_card',
    children: [
      _StateCard(
        label: 'single card',
        child: const _DeviceFrame(
          height: 360,
          child: Padding(
            padding: CatchInsets.pageBody,
            child: ClubDirectorySkeletonCard(),
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
        child: Center(
          child: ExploreCityPicker(
            state: _cityPickerState(),
            onSelected: _noopCity,
          ),
        ),
      ),
      _StateCard(
        label: 'city source loading',
        child: Center(
          child: ExploreCityPicker(
            state: _cityPickerState(cities: const [], cityListLoading: true),
            onSelected: _noopCity,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Trigger states',
  type: CityTrigger,
  path: '[Explore]/Controls',
)
Widget exploreCityTriggerStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'CityTrigger',
    catalogId: 'control.explore.city_trigger',
    children: [
      _StateCard(
        label: 'icon ready',
        child: Center(
          child: CityTrigger(city: _mumbai, focused: false, onTap: _noop),
        ),
      ),
      _StateCard(
        label: 'icon focused',
        child: Center(
          child: CityTrigger(city: _delhi, focused: true, onTap: _noop),
        ),
      ),
      _StateCard(
        label: 'scope label disabled',
        child: Center(
          child: CityTrigger(
            city: _mumbai,
            focused: false,
            enabled: false,
            presentation: ExploreCityPickerPresentation.scopeLabel,
            foregroundColor: t.ink,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'City picker sheet states',
  type: ExploreCityPickerSheet,
  path: '[Explore]/Controls',
)
Widget exploreCityPickerSheetStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreCityPickerSheet',
    catalogId: 'control.explore.city_picker_sheet',
    children: [
      _StateCard(
        label: 'default',
        child: _SheetFrame(
          child: ExploreCityPickerSheet(
            cities: const [_mumbai, _delhi],
            selectedCity: _mumbai,
            onSelected: (_) {},
          ),
        ),
      ),
      _StateCard(
        label: 'empty list',
        child: _SheetFrame(
          child: ExploreCityPickerSheet(
            cities: const [],
            selectedCity: _mumbai,
            onSelected: (_) {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'City option tile states',
  type: CityOptionTile,
  path: '[Explore]/Controls',
)
Widget cityOptionTileStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CityOptionTile',
    catalogId: 'control.explore.city_option_tile',
    children: [
      _StateCard(
        label: 'selected',
        child: CityOptionTile(city: _mumbai, selected: true, onTap: _noop),
      ),
      _StateCard(
        label: 'unselected',
        child: CityOptionTile(city: _delhi, selected: false, onTap: _noop),
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
          child: _ExploreScope(
            child: ExploreDiscoveryCoverHeader(
              cityPickerState: _cityPickerState(),
              onCitySelected: _noopCity,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'no featured event',
        child: _DeviceFrame(
          height: 180,
          child: _ExploreScope(
            feed: const AsyncData(ExploreFeedViewModel(items: [])),
            child: ExploreDiscoveryCoverHeader(
              cityPickerState: _cityPickerState(),
              onCitySelected: _noopCity,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cover chrome states',
  type: CoverStoryChrome,
  path: '[Explore]/Sections',
)
Widget exploreCoverStoryChromeStates(BuildContext context) {
  const d = CatchTokens.dark;
  final locationStory = CatchCoverStory(
    title: 'Tonight in Mumbai',
    location: 'Mumbai',
    showSearch: true,
    onLocation: _noop,
    onSearch: _noop,
  );
  const searchStory = CatchCoverStory(
    title: 'Tonight in Mumbai',
    showSearch: true,
  );

  Widget frame(Widget child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: d.bg,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
        child: child,
      ),
    );
  }

  return _CatalogScreen(
    title: 'CoverStoryChrome',
    catalogId: 'section.explore.cover_story_chrome',
    children: [
      _StateCard(
        label: 'location and search',
        child: frame(CoverStoryChrome(paper: d.ink, story: locationStory)),
      ),
      _StateCard(
        label: 'search only',
        child: frame(CoverStoryChrome(paper: d.ink, story: searchStory)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cover content states',
  type: CoverStoryContent,
  path: '[Explore]/Sections',
)
Widget exploreCoverStoryContentStates(BuildContext context) {
  const d = CatchTokens.dark;
  final dinner = ActivityPalette.resolve(context, ActivityKind.dinner);
  final dinnerStory = CatchCoverStory(
    activityKind: ActivityKind.dinner,
    kicker: 'Tonight',
    title: 'Jazz supper table',
    body: 'Eight seats, one long table, and an easy first round.',
    cta: 'Book',
    onCta: _noop,
    data: '8:00 PM · Rs 1,800',
    data2: '8 going · 4 left',
  );
  const neutralStory = CatchCoverStory(
    title: 'Plans that feel warm before they feel crowded',
    body: 'Browse hosted tables, runs, games, and coffee walks nearby.',
    data: 'Mumbai',
  );

  Widget frame(Widget child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: d.bg,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(padding: CatchInsets.contentRelaxed, child: child),
    );
  }

  return _CatalogScreen(
    title: 'CoverStoryContent',
    catalogId: 'section.explore.cover_story_content',
    children: [
      _StateCard(
        label: 'event CTA',
        child: frame(
          CoverStoryContent(
            paper: d.ink,
            accent: dinner.accent,
            story: dinnerStory,
          ),
        ),
      ),
      _StateCard(
        label: 'neutral hook',
        child: frame(
          CoverStoryContent(
            paper: d.ink,
            accent: d.primary,
            story: neutralStory,
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
  name: 'Filter option item states',
  type: CatchOptionGroupItem,
  path: '[Explore]/Controls',
)
Widget exploreFilterOptionItemStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchOptionGroupItem',
    catalogId: 'control.explore.filter_option_item',
    children: [
      _StateCard(
        label: 'time scope options',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchOptionGroupItem<ExploreTimeFilter>(
              option: const CatchOption(
                value: ExploreTimeFilter.tonight,
                label: 'Tonight',
              ),
              selected: true,
              onTap: _noop,
            ),
            gapW12,
            CatchOptionGroupItem<ExploreTimeFilter>(
              option: const CatchOption(
                value: ExploreTimeFilter.weekend,
                label: 'Weekend',
              ),
              selected: false,
              onTap: _noop,
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'long copy',
        child: CatchOptionGroupItem<ExploreTimeFilter>(
          option: const CatchOption(
            value: ExploreTimeFilter.thisWeek,
            label: 'This week',
          ),
          selected: false,
          onTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Counted filter action',
  type: CatchIconButton,
  path: '[Explore]/Controls',
)
Widget exploreCountedFilterActionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchIconButton.counted filter action',
    catalogId: 'catch.icon_button',
    children: [
      _StateCard(
        label: 'inactive',
        child: Center(
          child: CatchIconButton.counted(
            icon: CatchIcons.tuneRounded,
            count: 0,
            variant: CatchIconButtonVariant.plain,
            tooltip: 'Filters',
            onTap: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'active count',
        child: Center(
          child: CatchIconButton.counted(
            icon: CatchIcons.tuneRounded,
            count: 3,
            variant: CatchIconButtonVariant.plain,
            tooltip: 'Filters, 3 active',
            onTap: _noop,
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
  name: 'Cross paths card states',
  type: CatchCrossPathsCard,
  path: '[Explore]/Cards',
)
Widget catchCrossPathsCardStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchCrossPathsCard',
    catalogId: 'card.explore.cross_paths',
    children: [
      _StateCard(
        label: 'postcard',
        child: SizedBox(
          width: 340,
          child: CatchCrossPathsCard(
            activityKind: ActivityKind.socialRun,
            quote: 'I am going for coffee after the run.',
            displayName: 'Neha',
            age: 29,
            meta: 'Bandra · 2 km away',
            kicker: 'Crossed paths',
            onJoin: _noop,
            onLike: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'photo row',
        child: SizedBox(
          width: 340,
          child: CatchCrossPathsCard(
            activityKind: ActivityKind.dinner,
            quote: 'Ask me about the dessert menu.',
            displayName: 'Maya',
            age: 31,
            meta: 'Fort · Host friend',
            kicker: 'Also going',
            variant: CatchCrossPathsVariant.photo,
            onJoin: _noop,
            onLike: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cross paths portrait states',
  type: CrossPathsPortrait,
  path: '[Explore]/Cards',
)
Widget crossPathsPortraitStates(BuildContext context) {
  final activity = ActivityPalette.resolve(context, ActivityKind.socialRun);
  return _CatalogScreen(
    title: 'CrossPathsPortrait',
    catalogId: 'card.explore.cross_paths.portrait',
    children: [
      _StateCard(
        label: 'fallback and photo',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 112,
              height: 150,
              child: CrossPathsPortrait(activity: activity),
            ),
            gapW12,
            SizedBox(
              width: 112,
              height: 150,
              child: CrossPathsPortrait(
                activity: activity,
                photoUrl:
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240&q=80',
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cross paths polaroid states',
  type: CrossPathsPolaroidRail,
  path: '[Explore]/Cards',
)
Widget crossPathsPolaroidRailStates(BuildContext context) {
  final activity = ActivityPalette.resolve(context, ActivityKind.socialRun);
  return _CatalogScreen(
    title: 'CrossPathsPolaroidRail',
    catalogId: 'card.explore.cross_paths.polaroid_rail',
    children: [
      _StateCard(
        label: 'fallback and photo',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: CatchLayout.crossPathsRailColumnWidth,
              child: CrossPathsPolaroidRail(activity: activity),
            ),
            gapW24,
            SizedBox(
              width: CatchLayout.crossPathsRailColumnWidth,
              child: CrossPathsPolaroidRail(
                activity: activity,
                photoUrl:
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240&q=80',
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Cross paths CTA states',
  type: CrossPathsCtaRow,
  path: '[Explore]/Cards',
)
Widget crossPathsCtaRowStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CrossPathsCtaRow',
    catalogId: 'card.explore.cross_paths.cta_row',
    children: [
      _StateCard(
        label: 'join and like',
        child: CrossPathsCtaRow(
          cta: 'Join her there',
          onJoin: _noop,
          onLike: _noop,
        ),
      ),
      _StateCard(
        label: 'disabled actions',
        child: CrossPathsCtaRow(cta: 'Join waitlist'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'This week states',
  type: ThisWeekRecommendationsSection,
  path: '[Explore]/Sections',
)
Widget thisWeekRecommendationsSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ThisWeekRecommendationsSection',
    catalogId: 'section.explore.feed.this_week',
    children: [
      _StateCard(
        label: 'ticket strip',
        child: _ExploreScope(
          child: AbsorbPointer(
            child: ThisWeekRecommendationsSection(
              items: _feedItems.take(3).toList(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Event row states',
  type: ExploreFeedEventRow,
  path: '[Explore]/Rows',
)
Widget exploreFeedEventRowStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreFeedEventRow',
    catalogId: 'row.explore.feed.event',
    children: [
      _StateCard(
        label: 'open event',
        child: _ExploreScope(
          child: AbsorbPointer(child: ExploreFeedEventRow(item: _feedItems[1])),
        ),
      ),
      _StateCard(
        label: 'joined club recommendation',
        child: _ExploreScope(
          child: AbsorbPointer(
            child: ExploreFeedEventRow(
              item: _feedItems.first,
              analyticsSource: 'widgetbook_joined',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'External event row states',
  type: ExploreExternalEventRow,
  path: '[Explore]/Rows',
)
Widget exploreExternalEventRowStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreExternalEventRow',
    catalogId: 'row.explore.feed.external_event',
    children: [
      _StateCard(
        label: 'source link available',
        child: _ExploreScope(
          child: AbsorbPointer(
            child: ExploreExternalEventRow(item: _externalFeedItem),
          ),
        ),
      ),
      _StateCard(
        label: 'missing source link',
        child: _ExploreScope(
          child: AbsorbPointer(
            child: ExploreExternalEventRow(
              item: ExploreExternalEventItem(
                event: _externalFeedItem.event.copyWith(externalLinks: []),
                distanceFromUserKm: null,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Club polaroid states',
  type: ExploreClubPolaroidCard,
  path: '[Explore]/Cards',
)
Widget exploreClubPolaroidCardStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreClubPolaroidCard',
    catalogId: 'card.explore.feed.club_polaroid',
    children: [
      _StateCard(
        label: 'image-backed club',
        child: AbsorbPointer(child: ExploreClubPolaroidCard(club: _clubs[1])),
      ),
      _StateCard(
        label: 'fallback artwork',
        child: AbsorbPointer(
          child: ExploreClubPolaroidCard(
            club: _clubs[2].copyWith(imageUrl: null),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Club row states',
  type: ExploreFeedClubRow,
  path: '[Explore]/Rows',
)
Widget exploreFeedClubRowStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreFeedClubRow',
    catalogId: 'row.explore.feed.club',
    children: [
      _StateCard(
        label: 'compact club',
        child: AbsorbPointer(child: ExploreFeedClubRow(club: _clubs[0])),
      ),
      _StateCard(
        label: 'host unknown',
        child: AbsorbPointer(child: ExploreFeedClubRow(club: _clubs[2])),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Club cover states',
  type: ExploreClubCover,
  path: '[Explore]/Cards',
)
Widget exploreClubCoverStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreClubCover',
    catalogId: 'card.explore.feed.club_cover',
    children: [
      _StateCard(
        label: 'graded image',
        child: SizedBox(
          width: 260,
          height: 260,
          child: ExploreClubCover(club: _clubs[0]),
        ),
      ),
      _StateCard(
        label: 'compact fallback',
        child: SizedBox.square(
          dimension: 96,
          child: ExploreClubCover(
            club: _clubs[2].copyWith(imageUrl: null),
            compact: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Club tags states',
  type: ExploreClubTags,
  path: '[Explore]/Cards',
)
Widget exploreClubTagsStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreClubTags',
    catalogId: 'card.explore.feed.club_tags',
    children: [
      _StateCard(
        label: 'visible tags',
        child: ExploreClubTags(
          state: ExploreClubCardState.from(_clubs[0], isSynthetic: false),
        ),
      ),
      _StateCard(
        label: 'member fallback',
        child: ExploreClubTags(
          state: ExploreClubCardState.from(
            _clubs[0].copyWith(tags: []),
            isSynthetic: false,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Mono label states',
  type: ExploreMonoLabel,
  path: '[Explore]/Cards',
)
Widget exploreMonoLabelStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'ExploreMonoLabel',
    catalogId: 'card.explore.feed.mono_label',
    children: [
      _StateCard(
        label: 'result count',
        child: ExploreMonoLabel('10 PLANS - JUN 24-30', color: t.ink3),
      ),
      _StateCard(
        label: 'accent row kicker',
        child: ExploreMonoLabel('CLUB TO KNOW', color: t.accent),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Loading sliver states',
  type: ExploreEventsLoadingSliver,
  path: '[Explore]/Sections',
)
Widget exploreEventsLoadingSliverStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ExploreEventsLoadingSliver',
    catalogId: 'section.explore.feed.loading',
    children: [
      _StateCard(
        label: 'bounded skeleton',
        child: _SliverFrame(
          height: 240,
          child: CustomScrollView(slivers: [ExploreEventsLoadingSliver()]),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Empty states',
  type: CatchEmptyState,
  path: '[Explore]/Sections',
)
Widget exploreEmptyStateStates(BuildContext context) {
  return _CatalogScreen(
    title: 'Explore empty states',
    catalogId: 'section.explore.empty_error',
    children: [
      _StateCard(
        label: 'empty city',
        child: CatchEmptyState(
          icon: CatchIcons.groupsOutlined,
          title: 'No clubs in Mumbai yet',
          message:
              'Try another city from the location control, or create the first '
              'club when you are ready to host.',
          action: _secondaryAction('Try another city'),
        ),
      ),
      _StateCard(
        label: 'search only',
        child: CatchEmptyState(
          icon: CatchIcons.groupsOutlined,
          title: 'No clubs match this search',
          message: 'Try another club, neighborhood, host, or tag.',
          action: _secondaryAction('Clear search'),
        ),
      ),
      _StateCard(
        label: 'filter only',
        child: CatchEmptyState(
          icon: CatchIcons.groupsOutlined,
          title: 'No clubs match these filters',
          message:
              'Clear one or more filters to bring nearby clubs back into view.',
          action: _secondaryAction('Clear filters'),
        ),
      ),
      _StateCard(
        label: 'search plus filters',
        child: CatchEmptyState(
          icon: CatchIcons.groupsOutlined,
          title: 'No clubs match this search',
          message:
              'Clear the search or filters to bring nearby clubs back into view.',
          action: _secondaryAction('Clear search and filters'),
        ),
      ),
      _StateCard(
        label: 'offline copy candidate',
        child: CatchEmptyState(
          icon: CatchIcons.groupsOutlined,
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
  name: 'Route empty states',
  type: ExploreScreenEmptyState,
  path: '[Explore]/Sections',
)
Widget exploreScreenEmptyStateStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreScreenEmptyState',
    catalogId: 'section.explore.empty_error',
    children: [
      _StateCard(
        label: 'no source clubs',
        child: ExploreScreenEmptyState(
          state: const ExploreDiscoveryEmptyState(
            kind: ExploreDiscoveryEmptyKind.noSourceClubs,
            cityLabel: 'Mumbai',
            action: ExploreDiscoveryEmptyAction.none,
          ),
          onClearSearch: _noop,
          onClearFilters: _noop,
        ),
      ),
      _StateCard(
        label: 'search plus filters',
        child: ExploreScreenEmptyState(
          state: const ExploreDiscoveryEmptyState(
            kind: ExploreDiscoveryEmptyKind.noFilteredSearchResults,
            cityLabel: 'Mumbai',
            action: ExploreDiscoveryEmptyAction.clearSearchAndFilters,
          ),
          onClearSearch: _noop,
          onClearFilters: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Clear action states',
  type: ExploreClearAction,
  path: '[Explore]/Controls',
)
Widget exploreClearActionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreClearAction',
    catalogId: 'control.explore.clear_action',
    children: [
      _StateCard(
        label: 'clear search',
        child: ExploreClearAction(
          clearSearch: true,
          clearFilters: false,
          onClearSearch: _noop,
        ),
      ),
      _StateCard(
        label: 'clear filters',
        child: ExploreClearAction(
          clearSearch: false,
          clearFilters: true,
          onClearFilters: _noop,
        ),
      ),
      _StateCard(
        label: 'clear search and filters',
        child: ExploreClearAction(
          clearSearch: true,
          clearFilters: true,
          onClearSearch: _noop,
          onClearFilters: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Feed empty sliver states',
  type: ExploreEventsEmptySliver,
  path: '[Explore]/Sections',
)
Widget exploreEventsEmptySliverStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ExploreEventsEmptySliver',
    catalogId: 'section.explore.empty_error',
    children: [
      _StateCard(
        label: 'clear search',
        child: _SliverFrame(
          height: 280,
          child: CustomScrollView(
            slivers: [
              ExploreEventsEmptySliver(
                state: ExploreEventsEmptyState.from(
                  filters: const ExploreFilterSelection(),
                  searchQuery: 'pickleball supper',
                ),
                onClearSearch: _noop,
                onClearFilters: _noop,
              ),
            ],
          ),
        ),
      ),
      _StateCard(
        label: 'broaden time filter',
        child: _SliverFrame(
          height: 280,
          child: CustomScrollView(
            slivers: [
              ExploreEventsEmptySliver(
                state: ExploreEventsEmptyState.from(
                  filters: const ExploreFilterSelection(
                    timeFilter: ExploreTimeFilter.tonight,
                  ),
                  searchQuery: '',
                ),
                onSetTimeFilter: (_) {},
              ),
            ],
          ),
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
  name: 'Activity content states',
  type: EventTypeBrowseContent,
  path: '[Explore]/Sections',
)
Widget eventTypeBrowseContentStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventTypeBrowseContent',
    catalogId: 'section.explore.activity_grid.content',
    children: [
      _StateCard(
        label: 'collapsed preview',
        child: EventTypeBrowseContent(
          items: _feedItems,
          activeActivityTag: ActivityKind.dinner.name,
          expanded: false,
          onCategoryTap: _ignoreActivityKind,
          onExpand: _noop,
        ),
      ),
      _StateCard(
        label: 'expanded list',
        child: EventTypeBrowseContent(
          items: _feedItems,
          activeActivityTag: null,
          expanded: true,
          onCategoryTap: _ignoreActivityKind,
          onExpand: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Activity rows states',
  type: ActivityTypeRows,
  path: '[Explore]/Sections',
)
Widget activityTypeRowsStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ActivityTypeRows',
    catalogId: 'section.explore.activity_grid.rows',
    children: [
      _StateCard(
        label: 'single column',
        child: SizedBox(
          width: 280,
          child: ActivityTypeRows(
            slots: _activitySlots,
            activeActivityTag: ActivityKind.socialRun.name,
            onCategoryTap: _ignoreActivityKind,
            onExpand: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'two columns',
        child: SizedBox(
          width: 560,
          child: ActivityTypeRows(
            slots: _activitySlots,
            activeActivityTag: ActivityKind.pickleball.label,
            onCategoryTap: _ignoreActivityKind,
            onExpand: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Activity slot states',
  type: ActivitySlotView,
  path: '[Explore]/Sections',
)
Widget activitySlotViewStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ActivitySlotView',
    catalogId: 'section.explore.activity_grid.slot',
    children: [
      _StateCard(
        label: 'activity entry',
        child: ActivitySlotView(
          slot: const ActivitySlot.entry(_socialRunActivityEntry),
          activeActivityTag: ActivityKind.socialRun.name,
          onCategoryTap: _ignoreActivityKind,
          onExpand: _noop,
        ),
      ),
      _StateCard(
        label: 'more slot',
        child: ActivitySlotView(
          slot: const ActivitySlot.more(3),
          activeActivityTag: null,
          onCategoryTap: _ignoreActivityKind,
          onExpand: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Activity row states',
  type: ActivityTypeRow,
  path: '[Explore]/Rows',
)
Widget activityTypeRowStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ActivityTypeRow',
    catalogId: 'row.explore.activity_type',
    children: [
      _StateCard(
        label: 'inactive row',
        child: ActivityTypeRow(
          entry: _dinnerActivityEntry,
          active: false,
          onTap: _noop,
        ),
      ),
      _StateCard(
        label: 'active row',
        child: ActivityTypeRow(
          entry: _socialRunActivityEntry,
          active: true,
          onTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'More row states',
  type: MoreActivityTypesRow,
  path: '[Explore]/Rows',
)
Widget moreActivityTypesRowStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'MoreActivityTypesRow',
    catalogId: 'row.explore.activity_type.more',
    children: [
      _StateCard(
        label: 'collapsed overflow',
        child: MoreActivityTypesRow(remainingCount: 3, onTap: _noop),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Activity skeleton states',
  type: EventTypeBrowseSkeleton,
  path: '[Explore]/Sections',
)
Widget eventTypeBrowseSkeletonStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'EventTypeBrowseSkeleton',
    catalogId: 'section.explore.activity_grid.skeleton',
    children: [
      _StateCard(label: 'loading rows', child: EventTypeBrowseSkeleton()),
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
          child: CatchCountPill.label(
            label: 'Map',
            icon: CatchIcons.map,
            semanticLabel: 'Map',
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'with count',
        child: _MapPillFrame(
          child: CatchCountPill.label(
            label: 'Map',
            icon: CatchIcons.map,
            count: 6,
            semanticLabel: 'Map, 6 events',
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'pressed review target',
        child: _MapPillFrame(
          child: CatchCountPill.label(
            label: 'Map',
            icon: CatchIcons.map,
            count: 12,
            semanticLabel: 'Map, 12 events',
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _MediaOverride(
          textScaler: const TextScaler.linear(2),
          child: _MapPillFrame(
            child: CatchCountPill.label(
              label: 'Map',
              icon: CatchIcons.map,
              count: 12,
              semanticLabel: 'Map, 12 events',
              onPressed: _noop,
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
        label: 'selected event card',
        child: _DeviceFrame(
          height: 520,
          child: _ExploreScope(
            child: ExploreMapScreen(
              enableNetworkTiles: false,
              initialSelectedEventId: _feedItems.first.event.id,
            ),
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
        label: 'no exact pins',
        child: _DeviceFrame(
          height: 420,
          child: _ExploreScope(
            feed: AsyncData(
              ExploreFeedViewModel(
                items: [
                  ExploreEventItem(
                    event: _feedItems.first.event.copyWith(
                      meetingLocation: null,
                    ),
                    club: _feedItems.first.club,
                    availability: _feedItems.first.availability,
                    distanceFromUserKm: _feedItems.first.distanceFromUserKm,
                  ),
                ],
              ),
            ),
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
        exploreClubsViewModelProvider.overrideWithValue(effectiveViewModel),
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

class _ExploreBodySliverPreview extends ConsumerWidget {
  const _ExploreBodySliverPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(exploreFiltersProvider);
    return CustomScrollView(
      slivers: buildExploreBodySlivers(
        context: context,
        feedAsync: ref.watch(exploreFeedViewModelProvider),
        clubsViewModel: ExploreViewModel.partition(
          clubs: _clubs,
          joinedClubIds: _joinedClubIds,
        ),
        filters: filters,
        searchQuery: ref.watch(exploreSearchQueryProvider).trim(),
        onRetryFeed: () => ref.invalidate(exploreFeedViewModelProvider),
        onClearSearch: () =>
            ref.read(exploreSearchQueryProvider.notifier).clear(),
        onClearFilters: () => ref.read(exploreFiltersProvider.notifier).clear(),
        onSetTimeFilter: (filter) =>
            ref.read(exploreFiltersProvider.notifier).setTimeFilter(filter),
        onActivitySelected: (activityKind) => ref
            .read(exploreFiltersProvider.notifier)
            .toggleActivityTag(activityKind.name),
        onEventSelected: (_, _) {},
        onExternalEventOpened: (_) {},
        includeJoinedClubsRail: true,
        includeClubDirectory: true,
        pinnedExploreDayHeaders: false,
      ),
    );
  }
}

class _ExploreEventsSliverPreview extends ConsumerWidget {
  const _ExploreEventsSliverPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(exploreFiltersProvider);
    return CustomScrollView(
      slivers: buildExploreEventsSlivers(
        ref.watch(exploreFeedViewModelProvider),
        filters: filters,
        searchQuery: ref.watch(exploreSearchQueryProvider).trim(),
        onRetry: () => ref.invalidate(exploreFeedViewModelProvider),
        onClearSearch: () =>
            ref.read(exploreSearchQueryProvider.notifier).clear(),
        onClearFilters: () => ref.read(exploreFiltersProvider.notifier).clear(),
        onSetTimeFilter: (filter) =>
            ref.read(exploreFiltersProvider.notifier).setTimeFilter(filter),
        onEventSelected: (_, _) {},
        onExternalEventOpened: (_) {},
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
      now: _now,
    ),
    distanceFromUserKm: distanceFromUserKm,
    isJoinedClubMember: isJoinedClubMember,
  );
}

ExternalEvent _externalEvent({
  required String id,
  required String title,
  required DateTime startTime,
  required String meetingPoint,
  required ActivityKind activityKind,
  required String priceDisplayText,
  required String sourcePlatform,
}) {
  return ExternalEvent(
    id: id,
    canonicalHostId: 'widgetbook-external-host',
    compatibilityClubId: _clubs[1].id,
    title: title,
    description:
        'A reviewed external plan shown as read-only supply in Explore with outbound booking only.',
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 2)),
    timezone: 'Asia/Kolkata',
    meetingPoint: meetingPoint,
    locationDetails: 'Hosted outside Catch; confirm final details on source.',
    photoUrl: _clubs[1].imageUrl,
    latitude: _mumbai.latitude + 0.03,
    longitude: _mumbai.longitude + 0.03,
    activityKind: activityKind,
    interactionModel: activityKind.defaultInteractionModel,
    priceDisplayText: priceDisplayText,
    parsedPriceInPaise: 180000,
    status: 'active',
    publicationStatus: 'public',
    citySlug: _mumbai.name,
    sourcePlatform: sourcePlatform,
    externalLinks: [
      ExternalEventLink(
        platform: sourcePlatform,
        url: 'https://example.com/events/$id',
        linkType: 'booking',
        sourceEventKey: id,
        candidateId: 'candidate-$id',
        primary: true,
      ),
    ],
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

void _noopCity(CityData _) {}

void _ignoreActivityKind(ActivityKind _) {}

const _socialRunActivityEntry = ActivityEntry(
  activityKind: ActivityKind.socialRun,
  count: 3,
  firstSeenIndex: 0,
);

const _dinnerActivityEntry = ActivityEntry(
  activityKind: ActivityKind.dinner,
  count: 2,
  firstSeenIndex: 1,
);

const _pickleballActivityEntry = ActivityEntry(
  activityKind: ActivityKind.pickleball,
  count: 1,
  firstSeenIndex: 2,
);

const _activitySlots = [
  ActivitySlot.entry(_socialRunActivityEntry),
  ActivitySlot.entry(_dinnerActivityEntry),
  ActivitySlot.entry(_pickleballActivityEntry),
  ActivitySlot.more(3),
];
