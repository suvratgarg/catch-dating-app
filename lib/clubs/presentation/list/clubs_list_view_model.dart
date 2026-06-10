import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/sentinels.dart';
import 'package:catch_dating_app/search/data/explore_search_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clubs_list_view_model.freezed.dart';
part 'clubs_list_view_model.g.dart';

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

class ClubBrowseFilterSelection {
  const ClubBrowseFilterSelection({
    ExploreTimeFilter? timeFilter,
    bool thisWeekOnly = false,
    this.distanceFilter = ExploreDistanceFilter.any,
    this.highRatedOnly = false,
    this.joinedOnly = false,
    this.hostedOnly = false,
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
  final bool hostedOnly;
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
      hostedOnly ||
      activityTag != null ||
      area != null;

  ClubBrowseFilterSelection copyWith({
    Object? timeFilter = unsetSentinel,
    Object? distanceFilter = unsetSentinel,
    bool? thisWeekOnly,
    bool? highRatedOnly,
    bool? joinedOnly,
    bool? hostedOnly,
    Object? activityTag = unsetSentinel,
    Object? area = unsetSentinel,
  }) {
    final nextTimeFilter = identical(timeFilter, unsetSentinel)
        ? _copyWithTimeFilter(this.timeFilter, thisWeekOnly)
        : timeFilter as ExploreTimeFilter;

    return ClubBrowseFilterSelection(
      timeFilter: nextTimeFilter,
      distanceFilter: identical(distanceFilter, unsetSentinel)
          ? this.distanceFilter
          : distanceFilter as ExploreDistanceFilter,
      highRatedOnly: highRatedOnly ?? this.highRatedOnly,
      joinedOnly: joinedOnly ?? this.joinedOnly,
      hostedOnly: hostedOnly ?? this.hostedOnly,
      activityTag: identical(activityTag, unsetSentinel)
          ? this.activityTag
          : activityTag as String?,
      area: identical(area, unsetSentinel) ? this.area : area as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ClubBrowseFilterSelection &&
            other.timeFilter == timeFilter &&
            other.distanceFilter == distanceFilter &&
            other.highRatedOnly == highRatedOnly &&
            other.joinedOnly == joinedOnly &&
            other.hostedOnly == hostedOnly &&
            other.activityTag == activityTag &&
            other.area == area;
  }

  @override
  int get hashCode => Object.hash(
    timeFilter,
    distanceFilter,
    highRatedOnly,
    joinedOnly,
    hostedOnly,
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
abstract class ClubsListViewModel with _$ClubsListViewModel {
  const ClubsListViewModel._();

  const factory ClubsListViewModel({
    required List<Club> joinedClubs,
    required List<Club> allClubs,
    @Default({}) Set<String> joinedClubIds,
    @Default({}) Set<String> hostedClubIds,
  }) = _ClubsListViewModel;

  bool get isEmpty => allClubs.isEmpty;

  factory ClubsListViewModel.partition({
    required List<Club> clubs,
    required Set<String> joinedClubIds,
    Set<String> hostedClubIds = const {},
  }) {
    final joinedClubs = <Club>[];
    final activeClubIds = <String>{};

    for (final club in clubs) {
      if (joinedClubIds.contains(club.id)) {
        joinedClubs.add(club);
        activeClubIds.add(club.id);
      }
    }

    return ClubsListViewModel(
      joinedClubs: List.unmodifiable(joinedClubs),
      allClubs: List.unmodifiable(clubs),
      joinedClubIds: activeClubIds,
      hostedClubIds: hostedClubIds.intersection(activeClubIds),
    );
  }
}

/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.
@Riverpod(keepAlive: true)
class SelectedClubCity extends _$SelectedClubCity {
  bool _userSelected = false;

  @override
  CityData build() => defaultCityDataForMarket();

  void setCity(CityData city) {
    _userSelected = true;
    ref.read(selectedClubCityWasUserSelectedProvider.notifier).markSelected();
    if (state != city) {
      state = city;
      ref.read(clubSearchQueryProvider.notifier).clear();
      ref.read(clubBrowseFiltersProvider.notifier).clearLocalScope();
    }
  }

  void autoSelectCity(CityData city) {
    if (_userSelected) return;
    if (state != city) {
      state = city;
      ref.read(clubSearchQueryProvider.notifier).clear();
      ref.read(clubBrowseFiltersProvider.notifier).clearLocalScope();
    }
  }

  void autoSelectCityByName(String? cityName) {
    final city = cityOptionByName(cityName)?.toCityData();
    if (city == null) return;
    autoSelectCity(city);
  }
}

@Riverpod(keepAlive: true)
class SelectedClubCityWasUserSelected
    extends _$SelectedClubCityWasUserSelected {
  @override
  bool build() => false;

  void markSelected() => state = true;
}

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.
@Riverpod(keepAlive: true)
class ClubSearchQuery extends _$ClubSearchQuery {
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

@Riverpod(keepAlive: true)
class ClubBrowseFilters extends _$ClubBrowseFilters {
  @override
  ClubBrowseFilterSelection build() => const ClubBrowseFilterSelection();

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

  void toggleHostedOnly() {
    state = state.copyWith(hostedOnly: !state.hostedOnly);
  }

  void toggleActivityTag(String tag) {
    final next = _normalizeFilterValue(tag);
    if (next == null) return;
    state = state.copyWith(
      activityTag: _sameFilterValue(state.activityTag, next) ? null : next,
    );
  }

  void toggleArea(String area) {
    final next = _normalizeFilterValue(area);
    if (next == null) return;
    state = state.copyWith(
      area: _sameFilterValue(state.area, next) ? null : next,
    );
  }

  void clearLocalScope() {
    if (state.activityTag == null && state.area == null) return;
    state = state.copyWith(activityTag: null, area: null);
  }

  void clear() {
    state = const ClubBrowseFilterSelection();
  }
}

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.
///
/// **Pattern D variant:** Combines location-filtered clubs with client-side
/// search to produce a filtered list for the UI.
@riverpod
AsyncValue<List<Club>> exploreSourceClubs(Ref ref) {
  final city = ref.watch(selectedClubCityProvider);
  final locationClubsAsync = ref.watch(watchClubsByLocationProvider(city.name));
  final uidAsync = ref.watch(uidProvider);

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
  if (!uidAsync.hasValue || uidAsync.hasError) {
    return AsyncData(List.unmodifiable(locationClubs));
  }
  final uid = uidAsync.asData?.value;
  if (uid == null) {
    return AsyncData(List.unmodifiable(locationClubs));
  }

  final hostedClubsAsync = ref.watch(watchClubsHostedByProvider(uid));
  final ownedClubsAsync = ref.watch(watchClubsOwnedByProvider(uid));

  if (hostedClubsAsync.isLoading || ownedClubsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (hostedClubsAsync.hasError) {
    return AsyncError(
      hostedClubsAsync.error!,
      hostedClubsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (ownedClubsAsync.hasError) {
    return AsyncError(
      ownedClubsAsync.error!,
      ownedClubsAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    mergeExploreSourceClubs(
      locationClubs: locationClubs,
      hostedClubs: hostedClubsAsync.asData?.value ?? const <Club>[],
      ownedClubs: ownedClubsAsync.asData?.value ?? const <Club>[],
    ),
  );
}

@riverpod
AsyncValue<List<Club>> filteredClubs(Ref ref) {
  final city = ref.watch(selectedClubCityProvider);
  final query = ref.watch(clubSearchQueryProvider);
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

  final uid = ref.watch(uidProvider).asData?.value;
  final pinnedClubs = uid == null
      ? const <Club>[]
      : sourceClubs
            .where((club) => club.isHostedBy(uid))
            .toList(growable: false);
  final localFallback = _localSearchWithPinnedClubs(
    sourceClubs: sourceClubs,
    pinnedClubs: pinnedClubs,
    normalizedQuery: normalizedQuery,
  );
  final searchAsync = ref.watch(
    exploreServerSearchProvider(query: query, cityName: city.name),
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
  return AsyncData(
    mergeSearchMatchesWithPinnedClubs(
      rankedMatches: rankedMatches,
      pinnedClubs: pinnedClubs,
    ),
  );
}

List<Club> mergeExploreSourceClubs({
  required List<Club> locationClubs,
  required List<Club> hostedClubs,
  required List<Club> ownedClubs,
}) {
  final byId = <String, Club>{};
  for (final club in locationClubs) {
    byId[club.id] = club;
  }
  for (final club in hostedClubs) {
    byId[club.id] = club;
  }
  for (final club in ownedClubs) {
    byId[club.id] = club;
  }
  return List.unmodifiable(byId.values);
}

List<Club> _localSearchWithPinnedClubs({
  required List<Club> sourceClubs,
  required List<Club> pinnedClubs,
  required String normalizedQuery,
}) {
  final localMatches = sourceClubs
      .where((club) => matchesClubSearchQuery(club, normalizedQuery))
      .toList(growable: false);
  return mergeSearchMatchesWithPinnedClubs(
    rankedMatches: localMatches,
    pinnedClubs: pinnedClubs,
  );
}

List<Club> mergeSearchMatchesWithPinnedClubs({
  required List<Club> rankedMatches,
  required List<Club> pinnedClubs,
}) {
  final byId = <String, Club>{};
  for (final club in rankedMatches) {
    byId[club.id] = club;
  }
  for (final club in pinnedClubs) {
    byId[club.id] = club;
  }
  return List.unmodifiable(byId.values);
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
/// [ClubsListViewModel] that partitions clubs into joined and discover
/// lists for the UI.
@riverpod
AsyncValue<ClubsListViewModel> clubsListViewModel(Ref ref) {
  final filteredAsync = ref.watch(filteredClubsProvider);
  final browseFilters = ref.watch(clubBrowseFiltersProvider);

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
    return const AsyncData(ClubsListViewModel(joinedClubs: [], allClubs: []));
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
  final hostedClubIds = uid == null
      ? <String>{}
      : sourceClubs
            .where((club) => club.isHostedBy(uid))
            .map((club) => club.id)
            .toSet();
  final joinedClubIds = {...membershipClubIds, ...hostedClubIds};
  final clubs = applyClubBrowseFilters(
    clubs: sourceClubs,
    filters: browseFilters,
    joinedClubIds: joinedClubIds,
    hostedClubIds: hostedClubIds,
  );

  return AsyncData(
    ClubsListViewModel.partition(
      clubs: clubs,
      joinedClubIds: joinedClubIds,
      hostedClubIds: hostedClubIds,
    ),
  );
}

/// **Pattern D: View-model provider**
///
/// Derives the create-club affordance from the server-owned hosted-club query.
/// The callable enforces the one-club invariant; this provider keeps the list
/// UI from offering a creation path after a host already has a club.
@riverpod
AsyncValue<bool> canCreateClub(Ref ref) {
  if (!AppConfig.appRole.isHost) {
    return const AsyncData(false);
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
  if (uid == null) {
    return const AsyncData(false);
  }

  final ownedAsync = ref.watch(watchClubsOwnedByProvider(uid));
  return ownedAsync.whenData((clubs) => clubs.isEmpty);
}

bool matchesClubSearchQuery(Club club, String normalizedQuery) {
  return club.name.toLowerCase().contains(normalizedQuery) ||
      club.area.toLowerCase().contains(normalizedQuery) ||
      club.hostName.toLowerCase().contains(normalizedQuery) ||
      club.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
}

List<Club> applyClubBrowseFilters({
  required List<Club> clubs,
  required ClubBrowseFilterSelection filters,
  required Set<String> joinedClubIds,
  required Set<String> hostedClubIds,
  DateTime? now,
}) {
  if (!filters.hasActiveFilters) return clubs;

  final referenceNow = now ?? DateTime.now();
  return clubs
      .where((club) {
        if (!_clubMatchesTimeFilter(club, filters.timeFilter, referenceNow)) {
          return false;
        }
        if (filters.highRatedOnly && club.rating < 4.5) {
          return false;
        }
        if (filters.joinedOnly && !joinedClubIds.contains(club.id)) {
          return false;
        }
        if (filters.hostedOnly && !hostedClubIds.contains(club.id)) {
          return false;
        }
        final activityTag = filters.activityTag;
        if (activityTag != null &&
            !club.tags.any((tag) => _sameFilterValue(tag, activityTag))) {
          return false;
        }
        final area = filters.area;
        if (area != null && !_sameFilterValue(club.area, area)) {
          return false;
        }
        return true;
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

bool _sameFilterValue(String? left, String right) {
  return left?.trim().toLowerCase() == right.trim().toLowerCase();
}
