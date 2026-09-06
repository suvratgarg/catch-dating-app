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
import 'package:catch_dating_app/clubs/shared/catch_club_cover.dart';
import 'package:catch_dating_app/clubs/shared/catch_organizer_poster.dart';
import 'package:catch_dating_app/clubs/shared/club_transition_tags.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/data/city_repository.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_day_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_distance_ring.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_option_card.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/external_event.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/explore/domain/explore_event_recommendation.dart';
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
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode;

import '../clubs/clubs_test_helpers.dart';
import '../events/events_test_helpers.dart' as event_test;
import '../support/profile_readiness_fixtures.dart';
import '../test_pump_helpers.dart';
import 'explore_device_location_fakes.dart';

part 'explore_discovery_widgets_tests.dart';
part 'explore_club_cards_tests.dart';
part 'explore_club_detail_tests.dart';
part 'explore_screen_filters_tests.dart';
part 'explore_map_tests.dart';
part 'explore_errors_and_creation_tests.dart';

final _l10n = AppLocalizationsEn();

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

class _NoDeviceLocation extends NoDeviceLocation {}

class _FixedDeviceLocation extends FixedDeviceLocation {}

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
        home: Scaffold(
          body: CustomScrollView(
            key: const ValueKey('explore-test-scroll-view'),
            slivers: slivers,
          ),
        ),
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
  VoidCallback? onLoadMore,
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
        onLoadMore: onLoadMore,
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
  bool promoteFeaturedItem = false,
  DateTime? now,
  List<Club> candidateClubs = const [],
  Set<String> joinedClubIds = const {},
}) {
  return buildExploreEventsSlivers(
    feedAsync,
    l10n: _l10n,
    filters: filters,
    searchQuery: searchQuery,
    onRetry: onRetry,
    onClearSearch: onClearSearch,
    onClearFilters: onClearFilters,
    onSetTimeFilter: onSetTimeFilter,
    onEventSelected: onEventSelected,
    onExternalEventOpened: onExternalEventOpened,
    pinnedDayHeaders: pinnedDayHeaders,
    promoteFeaturedItem: promoteFeaturedItem,
    now: now,
    candidateClubs: candidateClubs,
    joinedClubIds: joinedClubIds,
  );
}

ExploreDiscoveryCoverHeader _exploreCoverHeader({
  String query = '',
  ExploreEventItem? featuredItem,
  List<Widget> actions = const <Widget>[],
  List<Widget>? heroActions,
  ValueChanged<String> onQueryChanged = _noopString,
  ValueChanged<ExploreEventItem> onFeaturedEventSelected =
      _noopFeaturedEventSelected,
}) {
  return ExploreDiscoveryCoverHeader(
    query: query,
    featuredItem: featuredItem,
    cityPickerState: _testCityPickerState(),
    onCitySelected: (_) {},
    actions: actions,
    heroActions: heroActions,
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
    _registerExploreDiscoveryWidgetsTests();
    _registerExploreClubCardsTests();
    _registerExploreClubDetailTests();
    _registerExploreScreenFiltersTests();
    _registerExploreMapTests();
    _registerExploreErrorsAndCreationTests();
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
        widget is CatchChip &&
        widget.label == label &&
        (active == null || widget.selected == active),
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
    latitude: 19.0435,
    longitude: 72.8204,
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

Finder _fieldChoice(String label, {bool? selected}) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CatchFieldChoiceChip &&
        widget.label == label &&
        (selected == null || widget.selected == selected),
  );
}

Finder _fieldOptionCard(String title, {bool? selected}) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is CatchOptionCard &&
        widget.title == title &&
        (selected == null || widget.selected == selected),
  );
}
