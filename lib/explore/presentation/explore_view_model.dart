import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/sentinels.dart';
import 'package:catch_dating_app/explore/presentation/explore_filter_logic.dart';
import 'package:catch_dating_app/explore/data/explore_search_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explore_view_model.freezed.dart';
part 'explore_view_model.g.dart';

enum ExploreTimeFilter { anytime, tonight, tomorrow, weekend, thisWeek }

enum ExploreDistanceFilter { any, oneKm, threeKm, fiveKm, tenKm }

double? exploreDistanceFilterKm(ExploreDistanceFilter filter) {
  return switch (filter) {
    ExploreDistanceFilter.any => null,
    ExploreDistanceFilter.oneKm => 1,
    ExploreDistanceFilter.threeKm => 3,
    ExploreDistanceFilter.fiveKm => 5,
    ExploreDistanceFilter.tenKm => 10,
  };
}

class ExploreTimeWindow {
  const ExploreTimeWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime value) {
    return !value.isBefore(start) && value.isBefore(end);
  }
}

ExploreTimeWindow? exploreTimeWindowFor(
  ExploreTimeFilter filter,
  DateTime now,
) {
  switch (filter) {
    case ExploreTimeFilter.anytime:
      return null;
    case ExploreTimeFilter.tonight:
      final today = _startOfDay(now);
      final baseDay = now.hour < 3
          ? today.subtract(const Duration(days: 1))
          : today;
      return ExploreTimeWindow(
        start: baseDay.add(const Duration(hours: 18)),
        end: baseDay.add(const Duration(days: 1, hours: 3)),
      );
    case ExploreTimeFilter.tomorrow:
      final start = _startOfDay(now).add(const Duration(days: 1));
      return ExploreTimeWindow(
        start: start,
        end: start.add(const Duration(days: 1)),
      );
    case ExploreTimeFilter.weekend:
      final today = _startOfDay(now);
      final daysFromFriday = now.weekday - DateTime.friday;
      final start = now.weekday >= DateTime.friday
          ? today.subtract(Duration(days: daysFromFriday))
          : today.add(Duration(days: DateTime.friday - now.weekday));
      return ExploreTimeWindow(
        start: start,
        end: start.add(const Duration(days: 3)),
      );
    case ExploreTimeFilter.thisWeek:
      return ExploreTimeWindow(
        start: now,
        end: now.add(const Duration(days: 7)),
      );
  }
}

/// Default time scope on cold load. The filter row reads as "live" rather
/// than empty by default-selecting the broadest useful window. `thisWeek`
/// catches every upcoming event without making the user act first, while
/// still narrowing the result set so the feed doesn't sprawl.
const ExploreTimeFilter defaultExploreTimeFilter = ExploreTimeFilter.thisWeek;

class ExploreFilterSelection {
  const ExploreFilterSelection({
    ExploreTimeFilter? timeFilter,
    bool thisWeekOnly = false,
    this.distanceFilter = ExploreDistanceFilter.any,
    this.highRatedOnly = false,
    this.joinedOnly = false,
    this.activityTag,
    this.area,
  }) : timeFilter =
           timeFilter ??
           (thisWeekOnly
               ? ExploreTimeFilter.thisWeek
               : defaultExploreTimeFilter);

  final ExploreTimeFilter timeFilter;
  final ExploreDistanceFilter distanceFilter;
  final bool highRatedOnly;
  final bool joinedOnly;
  final String? activityTag;
  final String? area;

  bool get thisWeekOnly => timeFilter == ExploreTimeFilter.thisWeek;

  /// True when the user has narrowed scope vs the cold-load default. Used to
  /// decide whether to show the "Clear" affordance — the default time filter
  /// is intentionally pre-selected on first load so the chip row reads as
  /// active, but that doesn't count as a user-applied filter.
  bool get hasActiveFilters =>
      timeFilter != defaultExploreTimeFilter ||
      distanceFilter != ExploreDistanceFilter.any ||
      highRatedOnly ||
      joinedOnly ||
      activityTag != null ||
      area != null;

  /// Active filters that actually narrow the **club** list. Distance is
  /// excluded on purpose: clubs carry no coordinates, so distance only narrows
  /// the events feed. Including it here would make a distance-only selection
  /// silently start applying the time window to the club list (and rebuild it)
  /// while doing nothing for distance.
  bool get hasActiveClubFilters =>
      timeFilter != defaultExploreTimeFilter ||
      highRatedOnly ||
      joinedOnly ||
      activityTag != null ||
      area != null;

  ExploreFilterSelection copyWith({
    Object? timeFilter = unsetSentinel,
    Object? distanceFilter = unsetSentinel,
    bool? thisWeekOnly,
    bool? highRatedOnly,
    bool? joinedOnly,
    Object? activityTag = unsetSentinel,
    Object? area = unsetSentinel,
  }) {
    final nextTimeFilter = identical(timeFilter, unsetSentinel)
        ? _copyWithTimeFilter(this.timeFilter, thisWeekOnly)
        : timeFilter as ExploreTimeFilter;

    return ExploreFilterSelection(
      timeFilter: nextTimeFilter,
      distanceFilter: identical(distanceFilter, unsetSentinel)
          ? this.distanceFilter
          : distanceFilter as ExploreDistanceFilter,
      highRatedOnly: highRatedOnly ?? this.highRatedOnly,
      joinedOnly: joinedOnly ?? this.joinedOnly,
      activityTag: identical(activityTag, unsetSentinel)
          ? this.activityTag
          : activityTag as String?,
      area: identical(area, unsetSentinel) ? this.area : area as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExploreFilterSelection &&
            other.timeFilter == timeFilter &&
            other.distanceFilter == distanceFilter &&
            other.highRatedOnly == highRatedOnly &&
            other.joinedOnly == joinedOnly &&
            other.activityTag == activityTag &&
            other.area == area;
  }

  @override
  int get hashCode => Object.hash(
    timeFilter,
    distanceFilter,
    highRatedOnly,
    joinedOnly,
    activityTag,
    area,
  );
}

ExploreTimeFilter _copyWithTimeFilter(
  ExploreTimeFilter current,
  bool? thisWeekOnly,
) {
  if (thisWeekOnly == null) return current;
  return thisWeekOnly ? ExploreTimeFilter.thisWeek : ExploreTimeFilter.anytime;
}

@freezed
abstract class ExploreViewModel with _$ExploreViewModel {
  const ExploreViewModel._();

  const factory ExploreViewModel({
    required List<Club> joinedClubs,
    required List<Club> allClubs,
    @Default({}) Set<String> joinedClubIds,
  }) = _ExploreViewModel;

  bool get isEmpty => allClubs.isEmpty;

  factory ExploreViewModel.partition({
    required List<Club> clubs,
    required Set<String> joinedClubIds,
  }) {
    final joinedClubs = <Club>[];
    final activeClubIds = <String>{};

    for (final club in clubs) {
      if (joinedClubIds.contains(club.id)) {
        joinedClubs.add(club);
        activeClubIds.add(club.id);
      }
    }

    return ExploreViewModel(
      joinedClubs: List.unmodifiable(joinedClubs),
      allClubs: List.unmodifiable(clubs),
      joinedClubIds: activeClubIds,
    );
  }
}

/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.
// keepalive: selected city is user browse-session state shared by Explore list,
// map, and city controllers across tab switches.
@Riverpod(keepAlive: true)
class SelectedExploreCity extends _$SelectedExploreCity {
  bool _userSelected = false;

  @override
  CityData build() => defaultCityDataForMarket();

  void setCity(CityData city) {
    _userSelected = true;
    ref
        .read(selectedExploreCityWasUserSelectedProvider.notifier)
        .markSelected();
    if (state != city) {
      state = city;
      ref.read(exploreSearchQueryProvider.notifier).clear();
      ref.read(exploreFiltersProvider.notifier).clearLocalScope();
    }
  }

  void autoSelectCity(CityData city) {
    if (_userSelected) return;
    if (state != city) {
      state = city;
      ref.read(exploreSearchQueryProvider.notifier).clear();
      ref.read(exploreFiltersProvider.notifier).clearLocalScope();
    }
  }

  void autoSelectCityByName(String? cityName) {
    final city = cityOptionByName(cityName)?.toCityData();
    if (city == null) return;
    autoSelectCity(city);
  }
}

// keepalive: user-selected flag protects manual city choice from later
// auto-detection while browsing.
@Riverpod(keepAlive: true)
class SelectedExploreCityWasUserSelected
    extends _$SelectedExploreCityWasUserSelected {
  @override
  bool build() => false;

  void markSelected() => state = true;
}

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.
// keepalive: query text is browse-session state and should survive Explore
// route/chrome rebuilds.
@Riverpod(keepAlive: true)
class ExploreSearchQuery extends _$ExploreSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    final normalizedQuery = query.trimLeft();
    if (state != normalizedQuery) {
      state = normalizedQuery;
    }
  }

  void clear() => state = '';
}

/// The search query after a short typing pause, trimmed for use as the
/// server-search key.
///
/// Keeps a fast typist from firing one Cloud Function call per keystroke — we
/// issue at most one search per settled phrase. Local substring filtering stays
/// instant because it reads [exploreSearchQueryProvider] directly; only the
/// (networked) server search keys off this debounced value. Short/empty queries
/// settle immediately — a clear shouldn't lag, and [exploreServerSearch] ignores
/// queries under two characters anyway. Longer queries wait out a ~300ms pause;
/// if the query changes again the pending delay is cancelled (via onDispose), so
/// rapid typing collapses to a single server call. Trimming also means a trailing
/// space no longer mints a distinct search key for an otherwise identical query.
@riverpod
Future<String> debouncedExploreSearchQuery(Ref ref) async {
  final query = ref.watch(exploreSearchQueryProvider).trim();
  if (query.length < 2) return query;

  final completer = Completer<void>();
  // ~300ms typing-pause window before the query reaches the network.
  final timer = Timer(const Duration(milliseconds: 300), completer.complete);
  ref.onDispose(timer.cancel);
  await completer.future;
  return query;
}

// keepalive: filters are browse-session state shared by Explore list, map, and
// feed view models.
@Riverpod(keepAlive: true)
class ExploreFilters extends _$ExploreFilters {
  @override
  ExploreFilterSelection build() => const ExploreFilterSelection();

  void setTimeFilter(ExploreTimeFilter filter) {
    state = state.copyWith(timeFilter: filter);
  }

  void toggleTimeFilter(ExploreTimeFilter filter) {
    final isCurrentlyActive = state.timeFilter == filter;
    final next = isCurrentlyActive && filter != defaultExploreTimeFilter
        ? defaultExploreTimeFilter
        : filter;
    setTimeFilter(next);
  }

  void toggleThisWeekOnly() {
    toggleTimeFilter(ExploreTimeFilter.thisWeek);
  }

  void setDistanceFilter(ExploreDistanceFilter filter) {
    state = state.copyWith(distanceFilter: filter);
  }

  void toggleDistanceFilter(ExploreDistanceFilter filter) {
    final next = state.distanceFilter == filter
        ? ExploreDistanceFilter.any
        : filter;
    setDistanceFilter(next);
  }

  void toggleHighRatedOnly() {
    state = state.copyWith(highRatedOnly: !state.highRatedOnly);
  }

  void toggleJoinedOnly() {
    state = state.copyWith(joinedOnly: !state.joinedOnly);
  }

  void toggleActivityTag(String tag) {
    final next = _normalizeFilterValue(tag);
    if (next == null) return;
    state = state.copyWith(
      activityTag: exploreFilterValuesMatch(state.activityTag, next)
          ? null
          : next,
    );
  }

  void toggleArea(String area) {
    final next = _normalizeFilterValue(area);
    if (next == null) return;
    state = state.copyWith(
      area: exploreFilterValuesMatch(state.area, next) ? null : next,
    );
  }

  void clearLocalScope() {
    if (state.activityTag == null && state.area == null) return;
    state = state.copyWith(activityTag: null, area: null);
  }

  void clear() {
    state = const ExploreFilterSelection();
  }
}

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.
///
/// **Pattern D variant:** Combines location-filtered clubs with client-side
/// search to produce a filtered list for the UI.
@riverpod
AsyncValue<List<Club>> exploreSourceClubs(Ref ref) {
  final city = ref.watch(selectedExploreCityProvider);
  final locationClubsAsync = ref.watch(
    watchClubsByLocationProvider(city.effectiveMarketId),
  );

  if (locationClubsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (locationClubsAsync.hasError) {
    return AsyncError(
      locationClubsAsync.error!,
      locationClubsAsync.stackTrace ?? StackTrace.current,
    );
  }
  final locationClubs = locationClubsAsync.asData?.value ?? const <Club>[];
  return AsyncData(List.unmodifiable(locationClubs));
}

@riverpod
AsyncValue<List<Club>> filteredExploreClubs(Ref ref) {
  final city = ref.watch(selectedExploreCityProvider);
  final query = ref.watch(exploreSearchQueryProvider);
  final clubsAsync = ref.watch(exploreSourceClubsProvider);
  final normalizedQuery = query.trim().toLowerCase();

  if (clubsAsync.isLoading) return const AsyncLoading();
  if (clubsAsync.hasError) {
    return AsyncError(
      clubsAsync.error!,
      clubsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final sourceClubs = clubsAsync.asData?.value ?? const <Club>[];
  if (normalizedQuery.isEmpty) {
    return AsyncData(sourceClubs);
  }

  final localFallback = sourceClubs
      .where((club) => matchesExploreClubSearchQuery(club, normalizedQuery))
      .toList(growable: false);
  // Server search keys off the debounced query so typing doesn't fire a
  // Cloud Function call per keystroke. Until it settles, `localFallback`
  // (computed from the live query above) keeps results responsive.
  final debouncedQuery =
      ref.watch(debouncedExploreSearchQueryProvider).asData?.value ?? '';
  if (debouncedQuery.length < 2) {
    return AsyncData(localFallback);
  }
  final searchAsync = ref.watch(
    exploreServerSearchProvider(
      query: debouncedQuery,
      cityName: city.effectiveMarketId,
    ),
  );

  if (searchAsync.isLoading) {
    return AsyncData(localFallback);
  }
  if (searchAsync.hasError) {
    return AsyncData(localFallback);
  }

  final searchResult = searchAsync.asData?.value;
  if (searchResult == null) {
    return AsyncData(localFallback);
  }

  final searchedClubsAsync = ref.watch(
    watchClubsByIdsProvider(ClubsByIdQuery(searchResult.clubIds)),
  );
  if (searchedClubsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (searchedClubsAsync.hasError) {
    return AsyncData(localFallback);
  }

  final rankedMatches = _rankClubsById(
    ids: searchResult.clubIds,
    clubs: searchedClubsAsync.asData?.value ?? const <Club>[],
  );
  return AsyncData(rankedMatches);
}

List<Club> _rankClubsById({
  required List<String> ids,
  required List<Club> clubs,
}) {
  final byId = {for (final club in clubs) club.id: club};
  return [
    for (final id in ids)
      if (byId[id] != null) byId[id]!,
  ];
}

/// **Pattern D: View-model provider**
///
/// Combines the signed-in user, membership edges, and filtered club streams into
/// a
/// [ExploreViewModel] that partitions clubs into joined and discover
/// lists for the UI.
@riverpod
AsyncValue<ExploreViewModel> exploreViewModel(Ref ref) {
  final filteredAsync = ref.watch(filteredExploreClubsProvider);
  final browseFilters = ref.watch(exploreFiltersProvider);

  if (filteredAsync.isLoading) {
    return const AsyncLoading();
  }
  if (filteredAsync.hasError) {
    return AsyncError(
      filteredAsync.error!,
      filteredAsync.stackTrace ?? StackTrace.current,
    );
  }

  final sourceClubs = filteredAsync.asData?.value ?? const <Club>[];
  if (sourceClubs.isEmpty) {
    return const AsyncData(ExploreViewModel(joinedClubs: [], allClubs: []));
  }

  final uidAsync = ref.watch(uidProvider);
  if (uidAsync.isLoading) {
    return const AsyncLoading();
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }

  final uid = uidAsync.asData?.value;
  final membershipsAsync = uid == null
      ? const AsyncData<List<ClubMembership>>([])
      : ref.watch(watchActiveClubMembershipsForUserProvider(uid));

  if (membershipsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (membershipsAsync.hasError) {
    return AsyncError(
      membershipsAsync.error!,
      membershipsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final membershipClubIds =
      membershipsAsync.asData?.value
          .map((membership) => membership.clubId)
          .toSet() ??
      <String>{};
  final joinedClubIds = membershipClubIds;
  final clubs = applyExploreFilters(
    clubs: sourceClubs,
    filters: browseFilters,
    joinedClubIds: joinedClubIds,
  );

  return AsyncData(
    ExploreViewModel.partition(clubs: clubs, joinedClubIds: joinedClubIds),
  );
}

bool matchesExploreClubSearchQuery(Club club, String normalizedQuery) {
  return club.name.toLowerCase().contains(normalizedQuery) ||
      club.area.toLowerCase().contains(normalizedQuery) ||
      club.displayHostName.toLowerCase().contains(normalizedQuery) ||
      club.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
}

List<Club> applyExploreFilters({
  required List<Club> clubs,
  required ExploreFilterSelection filters,
  required Set<String> joinedClubIds,
  DateTime? now,
}) {
  if (!filters.hasActiveClubFilters) return clubs;

  final referenceNow = now ?? DateTime.now();
  return clubs
      .where((club) {
        if (!_clubMatchesTimeFilter(club, filters.timeFilter, referenceNow)) {
          return false;
        }
        return clubMatchesScopeFilters(
          club: club,
          filters: filters,
          joinedClubIds: joinedClubIds,
        );
      })
      .toList(growable: false);
}

bool _clubMatchesTimeFilter(Club club, ExploreTimeFilter filter, DateTime now) {
  if (filter == ExploreTimeFilter.anytime) return true;
  final nextEventAt = club.nextEventAt;
  if (nextEventAt == null || nextEventAt.isBefore(now)) return false;
  return exploreTimeWindowFor(filter, now)?.contains(nextEventAt) ?? true;
}

DateTime _startOfDay(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String? _normalizeFilterValue(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
