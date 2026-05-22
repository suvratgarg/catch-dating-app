import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clubs_list_view_model.freezed.dart';
part 'clubs_list_view_model.g.dart';

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
    }
  }

  void autoSelectCity(CityData city) {
    if (_userSelected) return;
    if (state != city) {
      state = city;
      ref.read(clubSearchQueryProvider.notifier).clear();
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

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.
///
/// **Pattern D variant:** Combines location-filtered clubs with client-side
/// search to produce a filtered list for the UI.
@riverpod
AsyncValue<List<Club>> filteredClubs(Ref ref) {
  final city = ref.watch(selectedClubCityProvider);
  final query = ref.watch(clubSearchQueryProvider);
  final clubsAsync = ref.watch(watchClubsByLocationProvider(city.name));

  return clubsAsync.whenData((clubs) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return clubs;
    }

    return clubs
        .where((club) => matchesClubSearchQuery(club, normalizedQuery))
        .toList(growable: false);
  });
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

  if (filteredAsync.isLoading) {
    return const AsyncLoading();
  }
  if (filteredAsync.hasError) {
    return AsyncError(
      filteredAsync.error!,
      filteredAsync.stackTrace ?? StackTrace.current,
    );
  }

  final clubs = filteredAsync.asData?.value ?? const <Club>[];
  if (clubs.isEmpty) {
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
      : clubs
            .where((club) => club.isHostedBy(uid))
            .map((club) => club.id)
            .toSet();
  final joinedClubIds = {...membershipClubIds, ...hostedClubIds};

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
